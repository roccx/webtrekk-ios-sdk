import Foundation


internal struct XmlTrackerConfigurationParser {

	internal func parse(xml data: NSData) throws -> TrackerConfiguration {
		return try Parser(xml: data).configuration
	}
}



private class Parser: NSObject {

	private lazy var indexedPropertyAttributeNamePattern = try! NSRegularExpression(pattern: "^index(\\d+)$", options: [])

	private var automaticallyTracksAdvertisingId: Bool?
	private var automaticallyTracksAppUpdates: Bool?
	private var automaticallyTracksAppVersion: Bool?
	private var automaticallyTracksRequestQueueSize: Bool?
	private var configurationUpdateUrl: NSURL?
	private var maximumSendDelay: NSTimeInterval?
	private var requestQueueLimit: Int?
	private var samplingRate: Int?
	private var serverUrl: NSURL?
	private var sessionTimeoutInterval: NSTimeInterval?
	private var version: Int?
	private var webtrekkId: String?

	private lazy var configuration: TrackerConfiguration = lazyPlaceholder()
	private var currentString = ""
	private var elementPath = [String]()
	private var error: ErrorType?
	private var parser: NSXMLParser
	private var state = State.initial
	private var stateStack = [State]()

	#if !os(watchOS)
	private var automaticallyTrackedPages = Array<TrackerConfiguration.Page>()
	private var automaticallyTracksConnectionType: Bool?
	private var automaticallyTracksInterfaceOrientation: Bool?

	private var currentPage: TrackerConfiguration.Page?
	private var currentPageProperties: PageProperties?
	#endif


	private init(xml data: NSData) throws {
		self.parser = NSXMLParser(data: data)

		super.init()

		parser.delegate = self
		parser.parse()
		parser.delegate = nil

		if let error = error {
			throw error
		}

		guard let serverUrl = serverUrl else {
			throw Error(message: "<webtrekkConfiguration>.<trackDomain> element missing")
		}
		guard let webtrekkId = webtrekkId else {
			throw Error(message: "<webtrekkConfiguration>.<trackId> element missing")
		}
		guard let version = version else {
			throw Error(message: "<webtrekkConfiguration>.<version> element missing")
		}

		var configuration = TrackerConfiguration(webtrekkId: webtrekkId, serverUrl: serverUrl)
		configuration.version = version

		if let automaticallyTracksAdvertisingId = automaticallyTracksAdvertisingId {
			configuration.automaticallyTracksAdvertisingId = automaticallyTracksAdvertisingId
		}
		if let automaticallyTracksAppUpdates = automaticallyTracksAppUpdates {
			configuration.automaticallyTracksAppUpdates = automaticallyTracksAppUpdates
		}
		if let automaticallyTracksAppVersion = automaticallyTracksAppVersion {
			configuration.automaticallyTracksAppVersion = automaticallyTracksAppVersion
		}
		if let automaticallyTracksRequestQueueSize = automaticallyTracksRequestQueueSize {
			configuration.automaticallyTracksRequestQueueSize = automaticallyTracksRequestQueueSize
		}
		if let configurationUpdateUrl = configurationUpdateUrl {
			configuration.configurationUpdateUrl = configurationUpdateUrl
		}
		if let maximumSendDelay = maximumSendDelay {
			configuration.maximumSendDelay = maximumSendDelay
		}
		if let requestQueueLimit = requestQueueLimit {
			configuration.requestQueueLimit = requestQueueLimit
		}
		if let samplingRate = samplingRate {
			configuration.samplingRate = samplingRate
		}
		if let sessionTimeoutInterval = sessionTimeoutInterval {
			configuration.sessionTimeoutInterval = sessionTimeoutInterval
		}

		#if !os(watchOS)
			if !automaticallyTrackedPages.isEmpty {
				configuration.automaticallyTrackedPages = automaticallyTrackedPages
			}
			if let automaticallyTracksConnectionType = automaticallyTracksConnectionType {
				configuration.automaticallyTracksConnectionType = automaticallyTracksConnectionType
			}
			if let automaticallyTracksInterfaceOrientation = automaticallyTracksInterfaceOrientation {
				configuration.automaticallyTracksInterfaceOrientation = automaticallyTracksInterfaceOrientation
			}
		#endif

		self.configuration = configuration
	}


	private func buildSimpleElementState(currentValue: Any?, completion: (String) -> Void) -> State {
		guard currentValue == nil else {
			return fail(message: "specified multiple times")
		}

		return .simpleElement(completion: completion)
	}


	private func fail(message message: String) -> State {
		guard error == nil else {
			return .error
		}

		error = Error(message: "\(elementPathString) \(message)")
		parser.abortParsing()

		return .error
	}


	private var elementPathString: String {
		return elementPath.map({ "<\($0)>" }).joinWithSeparator(".")
	}


	private func parseBool(string: String) -> Bool? {
		switch (string) {
		case "true":  return true
		case "false": return false

		default:
			fail(message: "'\(string)' is not a valid boolean (expected 'true' or 'false')")
			return nil
		}
	}


	private func parseDouble(string: String, allowedRange: ClosedInterval<Double>) -> Double? {
		guard let value = Double(string) else {
			fail(message: "'\(string)' is not a valid number")
			return nil
		}

		if !allowedRange.contains(value) {
			fail(message: "value (\(value)) must be \(allowedRange.conditionText)")
			return nil
		}

		return value
	}


	private func parseIndexedProperties(attributes attributes: [String : String]) -> Set<IndexedProperty> {
		var indexedProperties = Set<IndexedProperty>()

		for (name, value) in attributes {
			guard let indexString = name.firstMatchForRegularExpression(indexedPropertyAttributeNamePattern)?[1], index = Int(indexString) else {
				continue
			}

			indexedProperties.insert(IndexedProperty(index: index, value: value))
		}

		return indexedProperties
	}


	private func parseInt(string: String, allowedRange: ClosedInterval<Int>) -> Int? {
		guard let value = Int(string) else {
			fail(message: "'\(string)' is not a valid integer")
			return nil
		}

		if !allowedRange.contains(value) {
			if allowedRange.end == .max {
				fail(message: "value (\(value)) must be larger than or equal to \(allowedRange.start)")
				return nil
			}
			if allowedRange.start == .min {
				fail(message: "value (\(value)) must be smaller than or equal to \(allowedRange.end)")
				return nil
			}

			fail(message: "value (\(value)) must be between \(allowedRange.start) (inclusive) and \(allowedRange.end) (inclusive)")
			return nil
		}

		return value
	}


	private func parseString(string: String, emptyAllowed: Bool) -> String? {
		if string.isEmpty {
			if !emptyAllowed {
				fail(message: "must not be empty")
			}

			return nil
		}

		return string
	}


	private func parseUrl(string: String, emptyAllowed: Bool) -> NSURL? {
		if string.isEmpty {
			if !emptyAllowed {
				fail(message: "must not be empty")
			}

			return nil
		}

		guard let value = NSURL(string: string) else {
			fail(message: "'\(string)' is not a valid URL")
			return nil
		}

		return value
	}


	private func popState() {
		state = stateStack.removeLast()
	}


	private func pushState(state: State) {
		stateStack.append(self.state)
		self.state = state
	}


	private func stateAfterStartingElement(elementName elementName: String, attributes: [String: String]) -> State {
		switch state {
		case .automaticTracking:
			return stateAfterStartingElementForAutomaticTracking(elementName: elementName, attributes: attributes)

		case .error:
			fatalError()

		case .initial:
			return .root

		case .root:
			return stateAfterStartingElementForRoot(elementName: elementName, attributes: attributes)

		case .simpleElement:
			warn(message: "unexpected element")
			return .unknown
			
		case .unknown:
			return .unknown

		default:
			break
		}

		#if !os(watchOS)
		switch state {
		case .automaticTrackingPage:
			return stateAfterStartingElementForAutomaticTrackingPage(elementName: elementName, attributes: attributes)

		case .automaticTrackingPages:
			return stateAfterStartingElementForAutomaticTrackingPages(elementName: elementName, attributes: attributes)

		case .pageProperties:
			return stateAfterStartingElementForPageProperties(elementName: elementName, attributes: attributes)

		default:
			break
		}
		#endif

		fatalError()
	}


	private func stateAfterStartingElementForAutomaticTracking(elementName elementName: String, attributes: [String: String]) -> State {
		switch (elementName) {
		case "advertisingIdentifier": return buildSimpleElementState(automaticallyTracksAdvertisingId)        { value in self.automaticallyTracksAdvertisingId = self.parseBool(value) }
		case "appUpdates":            return buildSimpleElementState(automaticallyTracksAppUpdates)           { value in self.automaticallyTracksAppUpdates = self.parseBool(value) }
		case "appVersion":            return buildSimpleElementState(automaticallyTracksAppVersion)           { value in self.automaticallyTracksAppVersion = self.parseBool(value) }
		case "requestQueueSize":      return buildSimpleElementState(automaticallyTracksRequestQueueSize)     { value in self.automaticallyTracksRequestQueueSize = self.parseBool(value) }
		default: break
		}

		#if !os(watchOS)
			switch (elementName) {
			case "connectionType":        return buildSimpleElementState(automaticallyTracksConnectionType)       { value in self.automaticallyTracksConnectionType = self.parseBool(value) }
			case "interfaceOrientation":  return buildSimpleElementState(automaticallyTracksInterfaceOrientation) { value in self.automaticallyTracksInterfaceOrientation = self.parseBool(value) }
			case "pages":                 return .automaticTrackingPages
			default: break
			}
		#endif

		warn(message: "unknown element")
		return .unknown
	}


	#if !os(watchOS)
	private func stateAfterStartingElementForAutomaticTrackingPage(elementName elementName: String, attributes: [String: String]) -> State {
		guard var currentPage = currentPage else {
			return fail(message: "internal error")
		}

		switch (elementName) {
		case "customProperties":
			currentPage.customProperties = attributes
			self.currentPage = currentPage

			return .simpleElement(completion: nil)

		case "pageProperties":
			if let name = attributes["name"]?.nonEmpty {
				currentPageProperties = PageProperties(name: name)
				return .pageProperties
			}
			else {
				return fail(message: "missing attribute 'name'")
			}

		default:
			warn(message: "unknown element in page '\(currentPage.pageProperties.viewControllerTypeName ?? "?")'")
			return .unknown
		}
	}


	private func stateAfterStartingElementForAutomaticTrackingPages(elementName elementName: String, attributes: [String: String]) -> State {
		if elementName == "page" {
			if let viewControllerTypeName = attributes["viewControllerType"]?.nonEmpty {
				let patternString: String
				if viewControllerTypeName.hasPrefix("/") {
					guard let _patternString = viewControllerTypeName.firstMatchForRegularExpression("^/(.*)/$")?[1] else {
						return fail(message: "invalid regular expression: missing trailing slash")
					}

					patternString = _patternString
				}
				else {
					patternString = "\\b\(NSRegularExpression.escapedPatternForString(viewControllerTypeName))\\b"
				}

				do {
					let pattern = try NSRegularExpression(pattern: patternString, options: [])

					currentPage = TrackerConfiguration.Page(viewControllerTypeNamePattern: pattern, pageProperties: PageProperties(viewControllerTypeName: viewControllerTypeName))
					return .automaticTrackingPage
				}
				catch let error {
					return fail(message: "invalid regular expression: \(error)")
				}
			}
			else {
				return fail(message: "missing attribute 'viewControllerType'")
			}
		}
		else {
			warn(message: "unknown element")
			return .unknown
		}
	}


	private func stateAfterStartingElementForPageProperties(elementName elementName: String, attributes: [String: String]) -> State {
		guard var pageProperties = currentPageProperties else {
			return fail(message: "internal error")
		}

		switch (elementName) {
		case "details":
			guard pageProperties.details == nil else {
				return fail(message: "specified multiple times")
			}

			pageProperties.details = parseIndexedProperties(attributes: attributes)

		case "groups":
			guard pageProperties.groups == nil else {
				return fail(message: "specified multiple times")
			}

			pageProperties.groups = parseIndexedProperties(attributes: attributes)

		default:
			warn(message: "unknown element")
			return .unknown
		}

		currentPageProperties = pageProperties

		return .simpleElement(completion: nil)
	}
	#endif


	private func stateAfterStartingElementForRoot(elementName elementName: String, attributes: [String: String]) -> State {
		switch (elementName) {
		case "automaticTracking":
			return .automaticTracking

		case "configurationUpdateUrl":
			return buildSimpleElementState(configurationUpdateUrl) { value in self.configurationUpdateUrl = self.parseUrl(value, emptyAllowed: true) }

		case "maxRequests":
			return buildSimpleElementState(requestQueueLimit) { value in self.requestQueueLimit = self.parseInt(value, allowedRange: TrackerConfiguration.allowedRequestQueueLimits) }

		case "sampling":
			return buildSimpleElementState(samplingRate) { value in self.samplingRate = self.parseInt(value, allowedRange: TrackerConfiguration.allowedSamplingRates) }

		case "trackDomain":
			return buildSimpleElementState(serverUrl) { value in self.serverUrl = self.parseUrl(value, emptyAllowed: false) }

		case "trackId":
			return buildSimpleElementState(webtrekkId) { value in self.webtrekkId = self.parseString(value, emptyAllowed: false) }

		case "version":
			return buildSimpleElementState(version) { value in self.version = self.parseInt(value, allowedRange: TrackerConfiguration.allowedVersions) }

		case "sendDelay":
			return buildSimpleElementState(maximumSendDelay) { value in self.maximumSendDelay = self.parseDouble(value, allowedRange: TrackerConfiguration.allowedMaximumSendDelays) }

		case "sessionTimeoutInterval":
			return buildSimpleElementState(sessionTimeoutInterval) { value in self.sessionTimeoutInterval = self.parseDouble(value, allowedRange: TrackerConfiguration.allowedSessionTimeoutIntervals) }

		default:
			warn(message: "unknown element")
			return .unknown
		}
	}


	private func warn(message message: String) {
		guard error == nil else {
			return
		}

		logWarning("\(elementPathString) \(message)")
	}



	private struct Error: CustomStringConvertible, ErrorType {

		private var message: String


		private init(message: String) {
			self.message = message
		}


		private var description: String {
			return message
		}
	}



	private enum State {

		case automaticTracking
		case error
		case initial
		case root
		case simpleElement(completion: ((String) -> Void)?)
		case unknown

		#if !os(watchOS)
		case automaticTrackingPage
		case automaticTrackingPages
		case pageProperties
		#endif
	}
}


extension Parser: NSXMLParserDelegate {

	@objc
	private func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		currentString = currentString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

		switch state {
		case .error:
			fatalError()

		case let .simpleElement(completion):
			completion?(currentString)

		default:
			break
		}

		#if !os(watchOS)
			switch state {
			case .automaticTrackingPage:
				guard var currentPage = currentPage else {
					fail(message: "internal error")
					return
				}
				self.currentPage = nil

				guard let currentPageProperties = currentPageProperties else {
					fail(message: "<pageProperties> element missing")
					return
				}
				self.currentPageProperties = nil

				currentPage.pageProperties = currentPageProperties

				automaticallyTrackedPages.append(currentPage)

			default:
				break
			}
		#endif

		currentString = ""
		elementPath.removeLast()

		popState()
	}


	@objc
	private func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName: String?, attributes: [String : String]) {
		currentString = ""
		elementPath.append(elementName)

		pushState(stateAfterStartingElement(elementName: elementName, attributes: attributes))
	}


	@objc
	private func parser(parser: NSXMLParser, foundCharacters string: String) {
		currentString += string
	}


	@objc
	private func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
		if error == nil {
			error = parseError
		}

		parser.abortParsing()
	}
}
