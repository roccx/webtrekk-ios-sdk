import Foundation


internal struct XmlTrackingConfigurationParser {

	internal func parse(xmlData: NSData) throws -> TrackingConfiguration {
		return try Parser(xmlData: xmlData).configuration
	}
}

/*

let viewControllerTypeName = try xmlPage.nonemptyStringAttribute("viewControllerType")

let pattern: NSRegularExpression
if viewControllerTypeName.hasPrefix("/") {
guard let patternString = viewControllerTypeName.firstMatchForRegularExpression("^/(.*)/$")?[1] else {
throw Error(message: "Invalid regular expression: missing trailing slash")
}

pattern = try NSRegularExpression(pattern: patternString, options: [])
}
else {
pattern = try NSRegularExpression(pattern: "\\b\(NSRegularExpression.escapedPatternForString(viewControllerTypeName))\\b", options: [])
}

let pageProperties = try parsePageProperties(xmlPage["pageProperties"])

config.autoTrackScreens.append(TrackerConfiguration.AutotrackedPage(
pageProperties: pageProperties,
pattern:		pattern
))
*/


private class Parser: NSObject {

	private var automaticallyTrackedPages: [TrackingConfiguration.Page]?
	private var automaticallyTracksAdvertisingId: Bool?
	private var automaticallyTracksAppName: Bool?
	private var automaticallyTracksAppUpdates: Bool?
	private var automaticallyTracksAppVersion: Bool?
	private var automaticallyTracksConnectionType: Bool?
	private var automaticallyTracksEventQueueSize: Bool?
	private var automaticallyTracksInterfaceOrientation: Bool?
	private var configurationUpdateUrl: NSURL?
	private var eventQueueLimit: Int?
	private var maximumSendDelay: NSTimeInterval?
	private var samplingRate: Int?
	private var serverUrl: NSURL?
	private var sessionTimeoutInterval: NSTimeInterval?
	private var version: Int?
	private var webtrekkId: String?

	private lazy var configuration: TrackingConfiguration = lazyPlaceholder()
	private var currentString = ""
	private var elementPath = [String]()
	private var error: ErrorType?
	private var parser: NSXMLParser
	private var state = State.initial
	private var stateStack = [State]()


	private init(xmlData: NSData) throws {
		self.parser = NSXMLParser(data: xmlData)

		super.init()

		parser.delegate = self
		parser.parse()
		parser.delegate = nil

		if let error = error {
			throw error
		}

		guard let serverUrl = serverUrl else {
			throw Error(message: "<trackDomain> element missing")
		}
		guard let webtrekkId = webtrekkId else {
			throw Error(message: "<trackId> element missing")
		}
		guard let version = version else {
			throw Error(message: "<version> element missing")
		}

		var configuration = TrackingConfiguration(webtrekkId: webtrekkId, serverUrl: serverUrl)
		configuration.version = version

		if let automaticallyTrackedPages = automaticallyTrackedPages {
			configuration.automaticallyTrackedPages = automaticallyTrackedPages
		}
		if let automaticallyTracksAdvertisingId = automaticallyTracksAdvertisingId {
			configuration.automaticallyTracksAdvertisingId = automaticallyTracksAdvertisingId
		}
		if let automaticallyTracksAppName = automaticallyTracksAppName {
			configuration.automaticallyTracksAppName = automaticallyTracksAppName
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
		if let automaticallyTracksEventQueueSize = automaticallyTracksEventQueueSize {
			configuration.automaticallyTracksEventQueueSize = automaticallyTracksEventQueueSize
		}
		if let automaticallyTracksInterfaceOrientation = automaticallyTracksInterfaceOrientation {
			configuration.automaticallyTracksInterfaceOrientation = automaticallyTracksInterfaceOrientation
		}
		if let configurationUpdateUrl = configurationUpdateUrl {
			configuration.configurationUpdateUrl = configurationUpdateUrl
		}
		if let eventQueueLimit = eventQueueLimit {
			configuration.eventQueueLimit = eventQueueLimit
		}
		if let maximumSendDelay = maximumSendDelay {
			configuration.maximumSendDelay = maximumSendDelay
		}
		if let samplingRate = samplingRate {
			configuration.samplingRate = samplingRate
		}
		if let sessionTimeoutInterval = sessionTimeoutInterval {
			configuration.sessionTimeoutInterval = sessionTimeoutInterval
		}
	}


	private func fail(message message: String) {
		guard error == nil else {
			return
		}

		let elementPath = self.elementPath.joinWithSeparator(".")
		error = Error(message: "<\(elementPath)> \(message)")
		parser.abortParsing()
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

		pushState(.simpleElement(completion))
	}


	private func pushState(state: State) {
		stateStack.append(self.state)
		self.state = state
	}


	private func warn(message message: String) {
		guard error == nil else {
			return
		}

		let elementPath = self.elementPath.joinWithSeparator(".")
		NSLog("%@", "Warning: <\(elementPath)> \(message)") // FIXME
	}



	private struct Error: ErrorType {

		private var message: String


		private init(message: String) {
			self.message = message
		}
	}



	private enum State {

		case automaticTracking
		case initial
		case root
		case simpleElement((String) -> Void)
		case unknown
	}
}


extension Parser: NSXMLParserDelegate {

	@objc
	private func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
		switch state {
		case let .simpleElement(completion):
			completion(currentString)

		case .automaticTracking, .initial, .root, .unknown: // FIXME
			break
		}

		currentString = ""
		elementPath.removeLast()

		popState()
	}


	@objc
	private func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
		elementPath.append(elementName)

		switch state {
		case .automaticTracking:
			// FIXME
			pushState(.unknown)

		case .initial:
			pushState(.root)

		case .root:
			switch (elementName) {
			case "automaticTracking":      pushState(.automaticTracking)
			case "configurationUpdateUrl": pushSimpleElement(configurationUpdateUrl) { value in self.configurationUpdateUrl = self.parseUrl(value, emptyAllowed: true) }
			case "maximumRequests":        pushSimpleElement(eventQueueLimit)        { value in self.eventQueueLimit = self.parseInt(value, allowedRange: 1 ..< .max) }
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
			warn(message: "unexpected element")
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
