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
		var categories = [String: [Int: CategoryElement]]()

		var parameters = [PropertyName: String]()
		for child in xmlElement.children {
			switch child.name {
			case "parameter":
				guard let element = readFromParameterElement(child) else {
					break
				}
				parameters[element.0] = element.1

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

		if let globalParameter = globalScreenTrackingParameter {
			trackerConfiguration.globalProperties = GlobalProperties(
				actionProperties: globalParameter.actionProperties(),
				advertisementProperties: globalParameter.advertisementProperties(),
				ecommerceProperties: globalParameter.ecommerceProperties(),
				mediaProperties: globalParameter.mediaProperties(),
				pageProperties: globalParameter.pageProperties(),
				sessionDetails: globalParameter.sessionDetails(),
				userProperties: globalParameter.userProperties()
			)
		}

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
			default: break
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
			throw Error(message: "$\(xmlElement.path).classname needs to be set")
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

		if let screenParameter = screenTrackingParameter {
			page.actionProperties = screenParameter.actionProperties()
			page.advertisementProperties = screenParameter.advertisementProperties()
			page.ecommerceProperties = screenParameter.ecommerceProperties()
			page.mediaProperties = screenParameter.mediaProperties()
			page.pageProperties = screenParameter.pageProperties()
			page.sessionDetails = screenParameter.sessionDetails()
			page.userProperties = screenParameter.userProperties()
		}

		page.pageProperties.name = pageName?.nonEmpty

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


	private func readFromCategoryElement(xmlElement: XmlElement) -> [Int: CategoryElement]? {
		guard !xmlElement.children.isEmpty else {
			return nil
		}
		var xmlCategoryElements = [Int: CategoryElement]()
		for child in xmlElement.children where child.name == "parameter" {
			guard let indexString = child.attributes["id"], index = Int(indexString) else {
				continue
			}
			xmlCategoryElements[index] = CategoryElement(key: child.attributes["key"], value: child.text)
		}
		return xmlCategoryElements
	}

	private func readFromParameterElement(xmlElement: XmlElement) -> (PropertyName, String)? {
		guard xmlElement.name == "parameter" else {
			return nil
		}
		guard let parameterName = xmlElement.attributes["id"] else {
			return nil
		}
		if let propertyName = PropertyName(rawValue: parameterName) {
			return (propertyName, value: xmlElement.text)
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


	private enum PropertyName:String {
		case advertisementId = "ADVERTISEMENT"
		case advertisementAction = "ADVERTISEMENT_ACTION"
		case birthday = "BIRTHDAY"
		case city = "CITY"
		case country = "COUNTRY"
		case currencyCode = "CURRENCY"
		case customerId = "CUSTOMER_ID"
		case emailAddress = "EMAIL"
		case emailReceiverId = "EMAIL_RID"
		case firstName = "GNAME"
		case gender = "GENDER"
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


	private class ScreenTrackingParameter {
		var categories: [String: [Int: CategoryElement]]
		var parameters: [PropertyName: String]

		init(categories: [String: [Int: CategoryElement]], parameters: [PropertyName: String]) {
			self.categories = categories
			self.parameters = parameters
		}

		private func resolved(elements: [Int: CategoryElement]) -> [Int: TrackingValue]? {
			var result = [Int: TrackingValue]()
			for (index, element) in elements {
				if let key = element.key {
					switch key {
					case  "advertiserId":        result[index] = .defaultVariable(.advertisingId)
					case  "advertisingOptOut":   result[index] = .defaultVariable(.advertisingTrackingEnabled)
					case  "appVersion":          result[index] = .defaultVariable(.appVersion)
					case  "connectionType":      result[index] = .defaultVariable(.connectionType)
					case  "screenOrientation":   result[index] = .defaultVariable(.interfaceOrientation)
					case  "appUpdated":          result[index] = .defaultVariable(.isFirstEventAfterAppUpdate)
					case  "requestUrlStoreSize": result[index] = .defaultVariable(.requestQueueSize)
					default:                     result[index] = .customVariable(name: key)
					}
				}
				else {
					result[index] = .constant(element.value)
				}
			}
			return result.isEmpty ? nil : result
		}


		private func actionProperties() -> ActionProperties {
			return ActionProperties(name: nil, details: categories["actionParameter"].flatMap { resolved($0) })
		}


		private func advertisementProperties() -> AdvertisementProperties {
			var advertisementId: String? = nil
			if let id = parameters[.advertisementId] {
				advertisementId = id
			}
			var advertisementAction: String? = nil
			if let action = parameters[.advertisementAction] {
				advertisementAction = action
			}
			var details: [Int: TrackingValue]? = nil
			if let elements = categories["adParameter"], advertisementDetails = resolved(elements) {
				details = advertisementDetails
			}

			return AdvertisementProperties(id: advertisementId, action: advertisementAction, details: details)
		}

		
		private func ecommerceProperties() -> EcommerceProperties {
			var currencyCode: String? = nil
			if let code = parameters[.currencyCode] {
				currencyCode = code
			}
			var orderNumber: String? = nil
			if let number = parameters[.orderNumber] {
				orderNumber = number
			}
			var product: EcommerceProperties.Product? = nil
			if let productProperties = productProperties() {
				product = productProperties
			}
			var status: EcommerceProperties.Status? = nil
			if let statusString = parameters[.productStatus] {
				switch statusString {
				case "conf": status = .purchased
				case "add":  status = .addedToBasket
				case "view": status = .viewed
				default:         break
				}
			}

			var totalValue: String? = nil
			if let value = parameters[.totalValue] {
				totalValue = value
			}
			var voucherValue: String? = nil
			if let value = parameters[.voucherValue] {
				voucherValue = value
			}
			var details: [Int: TrackingValue]? = nil
			if let elements = categories["ecomParameter"], ecommerceDetails = resolved(elements) {
				details = ecommerceDetails
			}

			var ecommerceProperties = EcommerceProperties(currencyCode: currencyCode, details: details, orderNumber: orderNumber, status: status, totalValue: totalValue, voucherValue: voucherValue)
			guard let productToAdd = product else {
				return ecommerceProperties
			}
			ecommerceProperties.products = [productToAdd]

			return ecommerceProperties
		}


		private func mediaProperties() -> MediaProperties {
			return MediaProperties(name: nil, groups: categories["mediaCategories"].flatMap { resolved($0) })
		}


		private func pageProperties() -> PageProperties {
			var pageProperties = PageProperties(name: nil)
			if let internalSearch = parameters[.internalSearch] {
				pageProperties.internalSearch = internalSearch
			}
			if let url = parameters[.pageUrl] {
				pageProperties.url = url
			}
			if let elements = categories["pageParameter"], pageDetails = resolved(elements) {
				pageProperties.details = pageDetails
			}
			if let elements = categories["pageCategories"], pageGroups = resolved(elements) {
				pageProperties.groups = pageGroups
			}

			return pageProperties
		}


		private func productProperties() -> EcommerceProperties.Product? {
			var productName: String? = nil
			if let name = parameters[.productName]?.nonEmpty {
				productName = name
			}
			var productPrice: String? = nil
			if let price = parameters[.productPrice]?.nonEmpty {
				productPrice = price
			}
			var productQuantity: Int? = nil
			if let quantityString = parameters[.productQuantity]?.nonEmpty, quantity = Int(quantityString) {
				productQuantity = quantity
			}
			var productCategories: [Int: TrackingValue]? = nil
			if let elements = categories["productCategories"], productCategoriesElements = resolved(elements) {
				productCategories = productCategoriesElements
			}

			guard productName != nil || productPrice != nil || productQuantity != nil || productCategories != nil else {
				return nil
			}

			return EcommerceProperties.Product(name: productName ?? "", categories: productCategories, price: productPrice, quantity: productQuantity)
		}


		private func sessionDetails() -> [Int: TrackingValue] {
			return categories["sessionParameter"].flatMap { resolved($0) } ?? [:]
		}


		private func userProperties() -> UserProperties {
			var userProperties = UserProperties()
			if let categoryElements = categories["userCategories"], details = resolved(categoryElements) {
				userProperties.details = details
			}
			if let str = parameters[.birthday] where str.characters.count == 8,
			   let year = Int(str.substringWithRange(str.startIndex...str.startIndex.advancedBy(3))),
			   let month = Int(str.substringWithRange(str.startIndex.advancedBy(4)...str.startIndex.advancedBy(5))),
			   let day = Int(str.substringWithRange(str.startIndex.advancedBy(6)..<str.endIndex)) {
				userProperties.birthday = UserProperties.Birthday(day: day, month: month, year: year)
			}
			if let city = parameters[.city] {
				userProperties.city = city
			}
			if let country = parameters[.country] {
				userProperties.country = country
			}
			if let customerId = parameters[.customerId] {
				userProperties.id = customerId
			}
			if let emailAddress = parameters[.emailAddress] {
				userProperties.emailAddress = emailAddress
			}
			if let emailReceiverId = parameters[.emailReceiverId] {
				userProperties.emailReceiverId = emailReceiverId
			}
			if let firstName = parameters[.firstName] {
				userProperties.city = firstName
			}
			if let gender = parameters[.gender] {
				switch gender.lowercaseString {
				case "male": userProperties.gender = .male
				case "femal": userProperties.gender = .female
				default: break
				}
			}
			if let ipAddress = parameters[.ipAddress] {
				userProperties.ipAddress = ipAddress
			}
			if let lastName = parameters[.lastName] {
				userProperties.city = lastName
			}
			if let newsletterSubscribed = parameters[.newsletterSubscribed] {
				userProperties.city = newsletterSubscribed
			}
			if let phoneNumber = parameters[.phoneNumber] {
				userProperties.city = phoneNumber
			}
			if let street = parameters[.street] {
				userProperties.city = street
			}
			if let streetNumber = parameters[.streetNumber] {
				userProperties.city = streetNumber
			}
			if let zipCode = parameters[.zipCode] {
				userProperties.city = zipCode
			}
			return userProperties
		}
	}



	struct CategoryElement {
		internal var key: String?
		internal var value: String
	}
}
