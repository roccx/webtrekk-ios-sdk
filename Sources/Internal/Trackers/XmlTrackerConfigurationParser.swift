import Foundation


internal class XmlTrackerConfigurationParser {

	private var autoTracked: Bool?
	private var automaticallyTracksAdvertisingId: Bool?
	private var automaticallyTracksAdvertisingOptOut: Bool?
	private var automaticallyTracksAppUpdates: Bool?
	private var automaticallyTracksAppVersion: Bool?
	private var automaticallyTracksRequestQueueSize: Bool?
	private var configurationUpdateUrl: NSURL?
	private var enableRemoteConfiguration: Bool?
	private var maximumSendDelay: NSTimeInterval?
	private var requestQueueLimit: Int?
	private var resendOnStartEventTime: NSTimeInterval?
	private var samplingRate: Int?
	private var serverUrl: NSURL?
	private var version: Int?
	private var webtrekkId: String?


	#if !os(watchOS)
	private var automaticallyTrackedPages = Array<TrackerConfiguration.Page>()
	private var automaticallyTracksConnectionType: Bool?
	private var automaticallyTracksInterfaceOrientation: Bool?
	#endif

	private var globalScreenTrackingParameter: ScreenTrackingParameter?


	internal func parse(xml data: NSData) throws -> TrackerConfiguration {
		return try readFromRootElement(XmlParser().parse(xml: data))
	}


	private func parseScreenTrackingParameter(xmlElement: XmlElement) -> ScreenTrackingParameter {
		var categories = [String: [CategoryElement]]()

		var parameters = [PropertyElement]()
		for child in xmlElement.children {
			switch child.name {
			case "parameter":
				guard let element = readFromParameterElement(child) else {
					break
				}
				parameters.append(element)

			case "actionParameter":   categories["actionParameter"] = readFromCategoryElement(child)
			case "adParameter":       categories["adParameter"] = readFromCategoryElement(child)
			case "ecomParameter":     categories["ecomParameter"] = readFromCategoryElement(child)
			case "mediaCategories":   categories["mediaCategories"] = readFromCategoryElement(child)
			case "pageCategories":    categories["pageCategories"] = readFromCategoryElement(child)
			case "pageParameter":     categories["pageParameter"] = readFromCategoryElement(child)
			case "productCategories": categories["productCategories"] = readFromCategoryElement(child)
			case "sessionParameter":  categories["sessionParameter"] = readFromCategoryElement(child)
			case "userCategories":    categories["userCategories"] = readFromCategoryElement(child)

			default: break
			}
		}
		return ScreenTrackingParameter(categories: categories, parameters: parameters)
	}


	private func readFromGlobalElement(xmlElement: XmlElement) throws {
		guard xmlElement.name == "globalTrackingParameter" else {
			throw Error(message: "\(xmlElement.path.joinWithSeparator(".")) needs to be globalTrackingParameter")
		}
		guard !xmlElement.children.isEmpty else {
			return
		}
		globalScreenTrackingParameter = parseScreenTrackingParameter(xmlElement)
	}


	private func readFromRootElement(xmlElement: XmlElement) throws -> TrackerConfiguration {
		guard xmlElement.name == "webtrekkConfiguration" else {
			throw Error(message: "\(xmlElement.path.joinWithSeparator(".")) root node needs to be webtrekkConfiguration")
		}
		guard !xmlElement.children.isEmpty else {
			throw Error(message: "\(xmlElement.path.joinWithSeparator(".")) webtrekkConfiguration can not be empty")
		}
		for child in xmlElement.children {
			do {
				switch child.name {
				case "enableRemoteConfiguration": enableRemoteConfiguration = try parseBool(child.text)
				case "maxRequests":               requestQueueLimit = try parseInt(child.text, allowedRange: TrackerConfiguration.allowedRequestQueueLimits)
				case "resendOnStartEventTime":    resendOnStartEventTime = try parseDouble(child.text, allowedRange: TrackerConfiguration.allowedResendOnStartEventTimes)
				case "sampling":                  samplingRate = try parseInt(child.text, allowedRange: TrackerConfiguration.allowedSamplingRates)
				case "sendDelay":                 maximumSendDelay = try parseDouble(child.text, allowedRange: TrackerConfiguration.allowedMaximumSendDelays)
				case "trackingConfigurationUrl":  configurationUpdateUrl = try parseUrl(child.text, emptyAllowed: true)
				case "trackDomain":               serverUrl = try parseUrl(child.text, emptyAllowed: false)
				case "trackId":                   webtrekkId = try parseString(child.text, emptyAllowed: false)
				case "version":                   version = try parseInt(child.text, allowedRange: TrackerConfiguration.allowedVersions)

				case "autoTracked":                  autoTracked = try parseBool(child.text)
				case "autoTrackAdvertiserId":        automaticallyTracksAdvertisingId = try parseBool(child.text)
				case "autoTrackAdvertisementOptOut": automaticallyTracksAdvertisingOptOut = try parseBool(child.text)
				case "autoTrackAppUpdate":           automaticallyTracksAppUpdates = try parseBool(child.text)
				case "autoTrackAppVersionName":      automaticallyTracksAppVersion = try parseBool(child.text)
				case "autoTrackRequestUrlStoreSize": automaticallyTracksRequestQueueSize = try parseBool(child.text)

				case "globalTrackingParameter" : try readFromGlobalElement(child)

				default:
					#if !os(watchOS)
						switch child.name {
						case "autoTrackConnectionType":    automaticallyTracksConnectionType = try parseBool(child.text)
						case "autoTrackScreenOrientation": automaticallyTracksInterfaceOrientation = try parseBool(child.text)
						case "screen": try readFromScreenElement(child)
						default: break
						}
					#endif
					// TODO: Log not found elements?
				}
			} catch let generalError{
				guard let error = generalError as? Error else {
					throw generalError
				}
				throw Error(message: "\(xmlElement.path.joinWithSeparator(".")): \(error.message)")
			}
		}

		guard let webtrekkId = webtrekkId, serverUrl = serverUrl else {
			throw Error(message: "trackId and trackDomain needs to be set.")
		}

		var trackerConfiguration = TrackerConfiguration(webtrekkId: webtrekkId, serverUrl: serverUrl)

		if let configurationUpdateUrl = configurationUpdateUrl {
			trackerConfiguration.configurationUpdateUrl = configurationUpdateUrl
		}

		if let enableRemoteConfiguration = enableRemoteConfiguration where !enableRemoteConfiguration {
			trackerConfiguration.configurationUpdateUrl = nil
		}

		if let requestQueueLimit = requestQueueLimit {
			trackerConfiguration.requestQueueLimit = requestQueueLimit
		}

		if let resendOnStartEventTime = resendOnStartEventTime {
			trackerConfiguration.resendOnStartEventTime = resendOnStartEventTime
		}

		if let samplingRate = samplingRate {
			trackerConfiguration.samplingRate = samplingRate
		}

		if let maximumSendDelay = maximumSendDelay {
			trackerConfiguration.maximumSendDelay = maximumSendDelay
		}

		if let version = version {
			trackerConfiguration.version = version
		}

		if let automaticallyTracksAdvertisingId = automaticallyTracksAdvertisingId {
			trackerConfiguration.automaticallyTracksAdvertisingId = automaticallyTracksAdvertisingId
		}

		if let automaticallyTracksAdvertisingOptOut = automaticallyTracksAdvertisingOptOut {
			trackerConfiguration.automaticallyTracksAdvertisingOptOut = automaticallyTracksAdvertisingOptOut
		}

		if let automaticallyTracksAppUpdates = automaticallyTracksAppUpdates {
			trackerConfiguration.automaticallyTracksAppUpdates = automaticallyTracksAppUpdates
		}

		if let automaticallyTracksAppVersion = automaticallyTracksAppVersion {
			trackerConfiguration.automaticallyTracksAppVersion = automaticallyTracksAppVersion
		}

		if let automaticallyTracksRequestQueueSize = automaticallyTracksRequestQueueSize {
			trackerConfiguration.automaticallyTracksRequestQueueSize = automaticallyTracksRequestQueueSize
		}
		#if !os(watchOS)
			if let automaticallyTracksConnectionType = automaticallyTracksConnectionType {
				trackerConfiguration.automaticallyTracksConnectionType = automaticallyTracksConnectionType
			}

			if let automaticallyTracksInterfaceOrientation = automaticallyTracksInterfaceOrientation {
				trackerConfiguration.automaticallyTracksInterfaceOrientation = automaticallyTracksInterfaceOrientation
			}
			trackerConfiguration.automaticallyTrackedPages = automaticallyTrackedPages
		#endif
		
		trackerConfiguration.globalScreenTrackingParameter = globalScreenTrackingParameter

		return trackerConfiguration
	}


	#if !os(watchOS)
	private func readFromScreenElement(xmlElement: XmlElement) throws {
		guard xmlElement.name == "screen" else {
			throw Error(message: "\(xmlElement.path.joinWithSeparator(".")) nodes needs to be screen")
		}
		guard !xmlElement.children.isEmpty else {
			throw Error(message: "\(xmlElement.path.joinWithSeparator(".")) node can not be empty")
		}
		// TODO: create screen here and append afterwards to array of screens
		var viewControllerType: String?
		var pageName: String?
		var autoTracked: Bool?
		var screenTrackingParameter: ScreenTrackingParameter?
		for child in xmlElement.children {
			switch child.name {
			case "classname": viewControllerType = try parseString(child.text, emptyAllowed: false)
			case "mappingname": pageName = try parseString(child.text, emptyAllowed: false)
			case "autoTracked": autoTracked = try parseBool(child.text)
			case "screenTrackingParameter": screenTrackingParameter = try readFromScreenTrackingParameterElement(child)
			default: break // TODO: handle not covered cases
			}
		}

		// if autotracked is not set it is assumed enabled
		if let globalAutoTracked = self.autoTracked where !globalAutoTracked {
			if let screenAutoTracked = autoTracked where screenAutoTracked {
				autoTracked = true
			}
			else {
				autoTracked = false
			}
		}
		autoTracked = autoTracked ?? true

		guard let isTrackingEnabled = autoTracked where isTrackingEnabled else {
			return
		}

		guard let viewControllerTypeName = viewControllerType else{
			throw Error(message: "classname needs to be set")
		}

		let patternString: String
		if viewControllerTypeName.hasPrefix("/") {
			guard let _patternString = viewControllerTypeName.firstMatchForRegularExpression("^/(.*)/$")?[1] else {
				throw Error(message: "invalid regular expression: missing trailing slash")
			}
			patternString = _patternString
		}
		else {
			patternString = "\\b\(NSRegularExpression.escapedPatternForString(viewControllerTypeName))\\b"
		}
		var page: TrackerConfiguration.Page
		do {
			let pattern = try NSRegularExpression(pattern: patternString, options: [])
			page = TrackerConfiguration.Page(viewControllerTypeNamePattern: pattern, pageProperties: PageProperties(viewControllerTypeName: viewControllerTypeName))
		}
		catch let error {
			throw Error(message: "invalid regular expression: \(error)")
		}

		if let pageName = pageName {
			page.pageProperties.name = pageName
		}
		page.screenTrackingParameter = screenTrackingParameter
		automaticallyTrackedPages.append(page)
	}


	private func readFromScreenTrackingParameterElement(xmlElement: XmlElement) throws -> ScreenTrackingParameter? {
		guard xmlElement.name == "screenTrackingParameter" else {
			throw Error(message: "screenTrackingParameter nodes needs to be screenTrackingParameter")
		}
		guard !xmlElement.children.isEmpty else {
			return nil
		}

		return parseScreenTrackingParameter(xmlElement)
	}
	#endif


	private func readFromCategoryElement(xmlElement: XmlElement) -> [CategoryElement]? {
		guard !xmlElement.children.isEmpty else {
			return nil
		}
		var xmlCategoryElements = [CategoryElement]()
		for child in xmlElement.children where child.name == "parameter" {
			guard let indexString = child.attributes["id"], index = Int(indexString) else {
				continue
			}
			xmlCategoryElements.append(CategoryElement(index: index, key: child.attributes["key"], value: child.text))
		}
		return xmlCategoryElements
	}

	private func readFromParameterElement(xmlElement: XmlElement) -> PropertyElement? {
		guard xmlElement.name == "parameter" else {
			return nil
		}
		guard let parameterName = xmlElement.attributes["id"] else {
			return nil
		}
		if let propertyName = PropertyName(rawValue: parameterName) {
			return PropertyElement(name: propertyName, key: xmlElement.attributes["id"], value: xmlElement.text)
		}
		else {
			// TODO: PropertyName is not defined yet, log or throw?
			return nil
		}
	}


	private func parseBool(string: String) throws -> Bool?{
		switch (string) {
		case "true":  return true
		case "false": return false

		default:
			throw Error(message: "'\(string)' is not a valid boolean (expected 'true' or 'false')")
		}
	}


	private func parseDouble(string: String, allowedRange: ClosedInterval<Double>) throws -> Double? {
		guard let value = Double(string) else {
			throw Error(message: "'\(string)' is not a valid number")
		}

		if !allowedRange.contains(value) {
			throw Error(message: "value (\(value)) must be \(allowedRange.conditionText)")
		}

		return value
	}


	private func parseInt(string: String, allowedRange: ClosedInterval<Int>) throws -> Int? {
		guard let value = Int(string) else {
			throw Error(message: "'\(string)' is not a valid integer")
		}

		if !allowedRange.contains(value) {
			if allowedRange.end == .max {
				throw Error(message: "value (\(value)) must be larger than or equal to \(allowedRange.start)")
			}
			if allowedRange.start == .min {
				throw Error(message: "value (\(value)) must be smaller than or equal to \(allowedRange.end)")
			}

			throw Error(message: "value (\(value)) must be between \(allowedRange.start) (inclusive) and \(allowedRange.end) (inclusive)")
		}

		return value
	}


	private func parseString(string: String, emptyAllowed: Bool) throws -> String? {
		if string.isEmpty {
			if !emptyAllowed {
				throw Error(message: "must not be empty")
			}

			return nil
		}

		return string
	}


	private func parseUrl(string: String, emptyAllowed: Bool) throws -> NSURL? {
		if string.isEmpty {
			if !emptyAllowed {
				throw Error(message: "must not be empty")
			}

			return nil
		}

		guard let value = NSURL(string: string) else {
			throw Error(message: "'\(string)' is not a valid URL")
		}

		return value
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
}

public struct PropertyElement {
	var name: PropertyName
	var key: String?
	var value: String
}

public enum PropertyName:String {
	case advertisementId = "ADVERTISEMENT"
	case advertisementAction = "ADVERTISEMENT_ACTION"
	case birthday = "BIRTHDAY"
	case city = "CITY"
	case country = "COUNTRY"
	case currencyCode = "CURRENCY"
	case customerId = "CUSTOMER_ID"
	case emailAddress = "EMAIL"
	case emailReceiverId = "EMAIL_RID"
	case gender = "GENDER"
	case firstName = "GNAME"
	case internalSearch = "INTERN_SEARCH"
	case ipAddress = "IP_ADDRESS"
	case lastName = "SNAME"
	case newsletterSubscribed = "NEWSLETTER"
	case orderNumber = "ORDER_NUMBER"
	case pageUrl = "PAGE_URL"
	case phoneNumber = "PHONE"
	case productName = "PRODUCT"
	case productPrice = "PRODUCT_COST"
	case productQuantity = "PRODUCT_COUNT"
	case productStatus = "PRODUCT_STATUS"
	case street = "STREET"
	case streetNumber = "STREETNUMBER"
	case totalValue = "ORDER_TOTAL"
	case voucherValue = "VOUCHER_VALUE"
	case zipCode = "ZIP"
}

public class ScreenTrackingParameter {
	let categories: [String: [CategoryElement]]
	let parameters: [PropertyElement]

	init(categories: [String: [CategoryElement]], parameters: [PropertyElement]) {
		self.categories = categories
		self.parameters = parameters
	}
}



public struct CategoryElement {
	internal var index: Int
	internal var key: String?
	internal var value: String
}

internal extension TrackerConfiguration {
	private struct AssociatedKeys {

		private static var globalScreenTrackingParameter = UInt8()
		private static var automaticTracker = UInt8()
	}

	@nonobjc
	internal var globalScreenTrackingParameter: ScreenTrackingParameter? {
		get { return objc_getAssociatedObject(self.webtrekkId, &AssociatedKeys.globalScreenTrackingParameter) as? ScreenTrackingParameter }
		set { objc_setAssociatedObject(self.webtrekkId, &AssociatedKeys.globalScreenTrackingParameter, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}
}