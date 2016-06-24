import Foundation


internal struct XmlTrackerConfigurationParser {

	internal func parse(xml data: NSData) throws -> TrackerConfiguration {
		return try Parser(xml: data).configuration
	}
}



private class Parser: NSObject {

	private var automaticallyTrackedPages = Array<TrackerConfiguration.Page>()
	private var automaticallyTracksAdvertisingId: Bool?
	private var automaticallyTracksAppUpdates: Bool?
	private var automaticallyTracksAppVersion: Bool?
	private var automaticallyTracksConnectionType: Bool?
	private var automaticallyTracksInterfaceOrientation: Bool?
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
	private var currentPageProperties: PageProperties?
	private var currentString = ""
	private var elementPath = [String]()
	private var error: ErrorType?
	private var parser: NSXMLParser
	private var state = State.initial
	private var stateStack = [State]()


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

		if !automaticallyTrackedPages.isEmpty {
			configuration.automaticallyTrackedPages = automaticallyTrackedPages
		}
		if let automaticallyTracksAdvertisingId = automaticallyTracksAdvertisingId {
			configuration.automaticallyTracksAdvertisingId = automaticallyTracksAdvertisingId
		}
		if let automaticallyTracksAppUpdates = automaticallyTracksAppUpdates {
			configuration.automaticallyTracksAppUpdates = automaticallyTracksAppUpdates
		}
		if let automaticallyTracksAppVersion = automaticallyTracksAppVersion {
			configuration.automaticallyTracksAppVersion = automaticallyTracksAppVersion
		}
		if let automaticallyTracksConnectionType = automaticallyTracksConnectionType {
			configuration.automaticallyTracksConnectionType = automaticallyTracksConnectionType
		}
		if let automaticallyTracksInterfaceOrientation = automaticallyTracksInterfaceOrientation {
			configuration.automaticallyTracksInterfaceOrientation = automaticallyTracksInterfaceOrientation
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

		self.configuration = configuration
	}


	private func fail(message message: String) {
		guard error == nil else {
			return
		}

		error = Error(message: "\(elementPathString) \(message)")
		parser.abortParsing()
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


	private func parseDouble(string: String, allowedRange: HalfOpenInterval<Double>) -> Double? {
		guard let value = Double(string) else {
			fail(message: "'\(string)' is not a valid number")
			return nil
		}

		if !allowedRange.contains(value) {
			if allowedRange.end.isInfinite {
				fail(message: "value (\(value)) must be larger than or equal to \(allowedRange.start)")
				return nil
			}
			if allowedRange.start.isInfinite {
				fail(message: "value (\(value)) must be smaller than \(allowedRange.end)")
				return nil
			}

			fail(message: "value (\(value)) must be between \(allowedRange.start) (inclusive) and \(allowedRange.end) (exclusive)")
			return nil
		}

		return value
	}


	private func parseInt(string: String, allowedRange: HalfOpenInterval<Int>) -> Int? {
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
				fail(message: "value (\(value)) must be smaller than \(allowedRange.end)")
				return nil
			}

			fail(message: "value (\(value)) must be between \(allowedRange.start) (inclusive) and \(allowedRange.end) (exclusive)")
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


	private func pushSimpleElement(currentValue: Any?, completion: (String) -> Void) {
		guard currentValue == nil else {
			fail(message: "specified multiple times")
			return
		}

		pushState(.simpleElement(completion: completion))
	}


	private func pushState(state: State) {
		stateStack.append(self.state)
		self.state = state
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
		case automaticTrackingPage(viewControllerTypeName: String, viewControllerTypeNamePattern: NSRegularExpression)
		case automaticTrackingPages
		case initial
		case pageProperties(name: String)
		case root
		case simpleElement(completion: (String) -> Void)
		case unknown
	}
}


extension Parser: NSXMLParserDelegate {

	@objc
	private func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		currentString = currentString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

		switch state {
		case let .automaticTrackingPage(_, viewControllerTypePattern):
			if let pageProperties = currentPageProperties {
				automaticallyTrackedPages.append(TrackerConfiguration.Page(viewControllerTypeNamePattern: viewControllerTypePattern, pageProperties: pageProperties))

				currentPageProperties = nil
			}
			else {
				fail(message: "<pageProperties> element missing")
			}

		case let .simpleElement(completion):
			completion(currentString)

		case .automaticTracking, .automaticTrackingPages, .initial, .pageProperties, .root, .unknown:
			break
		}

		currentString = ""
		elementPath.removeLast()

		popState()
	}


	@objc
	private func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName: String?, attributes: [String : String]) {
		currentString = ""
		elementPath.append(elementName)

		switch state {
		case .automaticTracking:
			switch (elementName) {
			case "advertisingIdentifier": pushSimpleElement(automaticallyTracksAdvertisingId)        { value in self.automaticallyTracksAdvertisingId = self.parseBool(value) }
			case "appUpdates":            pushSimpleElement(automaticallyTracksAppUpdates)           { value in self.automaticallyTracksAppUpdates = self.parseBool(value) }
			case "appVersion":            pushSimpleElement(automaticallyTracksAppVersion)           { value in self.automaticallyTracksAppVersion = self.parseBool(value) }
			case "connectionType":        pushSimpleElement(automaticallyTracksConnectionType)       { value in self.automaticallyTracksConnectionType = self.parseBool(value) }
			case "interfaceOrientation":  pushSimpleElement(automaticallyTracksInterfaceOrientation) { value in self.automaticallyTracksInterfaceOrientation = self.parseBool(value) }
			case "requestQueueSize":      pushSimpleElement(automaticallyTracksRequestQueueSize)     { value in self.automaticallyTracksRequestQueueSize = self.parseBool(value) }
			case "pages":                 pushState(.automaticTrackingPages)

			default:
				warn(message: "unknown element")
				pushState(.unknown)
			}

		case let .automaticTrackingPage(viewControllerTypeName):
			switch (elementName) {
			case "pageProperties":
				if let name = attributes["name"]?.nonEmpty {
					currentPageProperties = PageProperties(name: name)
					pushState(.pageProperties(name: name))
				}
				else {
					fail(message: "missing attribute 'name'")
					pushState(.unknown)
				}

			default:
				warn(message: "unknown element in page '\(viewControllerTypeName)'")
				pushState(.unknown)
			}

		case .automaticTrackingPages:
			if elementName == "page" {
				if let viewControllerTypeName = attributes["viewControllerType"]?.nonEmpty {
					let patternString: String?
					if viewControllerTypeName.hasPrefix("/") {
						if let _patternString = viewControllerTypeName.firstMatchForRegularExpression("^/(.*)/$")?[1] {
							patternString = _patternString
						}
						else {
							fail(message: "invalid regular expression: missing trailing slash")
							patternString = nil
						}
					}
					else {
						patternString = "\\b\(NSRegularExpression.escapedPatternForString(viewControllerTypeName))\\b"
					}

					if let patternString = patternString {
						let pattern: NSRegularExpression?
						do {
							pattern = try NSRegularExpression(pattern: patternString, options: [])
						}
						catch let error {
							fail(message: "invalid regular expression: \(error)")
							pattern = nil
						}

						if let pattern = pattern {
							pushState(.automaticTrackingPage(viewControllerTypeName: viewControllerTypeName, viewControllerTypeNamePattern: pattern))
						}
					}
				}
				else {
					fail(message: "missing attribute 'viewControllerType'")
					pushState(.unknown)
				}
			}
			else {
				warn(message: "unknown element")
				pushState(.unknown)
			}

		case .initial:
			pushState(.root)

		case let .pageProperties(name):
			warn(message: "not yet implemented") // FIXME
			pushState(.unknown)

		case .root:
			switch (elementName) {
			case "automaticTracking":      pushState(.automaticTracking)
			case "configurationUpdateUrl": pushSimpleElement(configurationUpdateUrl) { value in self.configurationUpdateUrl = self.parseUrl(value, emptyAllowed: true) }
			case "maxRequests":            pushSimpleElement(requestQueueLimit)      { value in self.requestQueueLimit = self.parseInt(value, allowedRange: 1 ..< .max) }
			case "sampling":               pushSimpleElement(samplingRate)           { value in self.samplingRate = self.parseInt(value, allowedRange: 0 ..< .max) }
			case "trackDomain":            pushSimpleElement(serverUrl)              { value in self.serverUrl = self.parseUrl(value, emptyAllowed: false) }
			case "trackId":                pushSimpleElement(webtrekkId)             { value in self.webtrekkId = self.parseString(value, emptyAllowed: false) }
			case "version":                pushSimpleElement(version)                { value in self.version = self.parseInt(value, allowedRange: 1 ..< .max) }
			case "sendDelay":              pushSimpleElement(maximumSendDelay)       { value in self.maximumSendDelay = self.parseDouble(value, allowedRange: 5 ..< .infinity) }
			case "sessionTimeoutInterval": pushSimpleElement(sessionTimeoutInterval) { value in self.sessionTimeoutInterval = self.parseDouble(value, allowedRange: 5 ..< .infinity) }

			default:
				warn(message: "unknown element")
				pushState(.unknown)
			}

		case .simpleElement:
			fail(message: "unexpected element")
			pushState(.unknown)

		case .unknown:
			pushState(.unknown)
		}
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
