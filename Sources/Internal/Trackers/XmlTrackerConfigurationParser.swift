//The MIT License (MIT)
//
//Copyright (c) 2016 Webtrekk GmbH
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
//"Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
//distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject
//to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Created by Widgetlabs
//

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

		var parameters = [PropertyName: PropertyValue]()
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
			throw TrackerError(message: "\(xmlElement.path.joinWithSeparator(".")) needs to be globalTrackingParameter")
		}
		guard !xmlElement.children.isEmpty else {
			return
		}
		globalScreenTrackingParameter = parseScreenTrackingParameter(xmlElement)
	}


	private func readFromRootElement(xmlElement: XmlElement) throws -> TrackerConfiguration {
		guard xmlElement.name == "webtrekkConfiguration" else {
			throw TrackerError(message: "\(xmlElement.path.joinWithSeparator(".")) root node needs to be webtrekkConfiguration")
		}
		guard !xmlElement.children.isEmpty else {
			throw TrackerError(message: "\(xmlElement.path.joinWithSeparator(".")) webtrekkConfiguration can not be empty")
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
			}
			catch let error as TrackerError {
				throw TrackerError(message: "\(xmlElement.path.joinWithSeparator(".")): \(error.message)")
			}
		}

		guard let webtrekkId = webtrekkId, serverUrl = serverUrl else {
			throw TrackerError(message: "trackId and trackDomain must be set.")
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
				ipAddress: globalParameter.parameters[.ipAddress]?.serialized(),
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
			throw TrackerError(message: "\(xmlElement.path.joinWithSeparator(".")) nodes needs to be screen")
		}
		guard !xmlElement.children.isEmpty else {
			throw TrackerError(message: "\(xmlElement.path.joinWithSeparator(".")) node can not be empty")
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

		guard let viewControllerTypeName = viewControllerType else {
			throw TrackerError(message: "$\(xmlElement.path).classname needs to be set")
		}

		let patternString: String
		if viewControllerTypeName.hasPrefix("/") {
			guard let _patternString = viewControllerTypeName.firstMatchForRegularExpression("^/(.*)/$")?[1] else {
				throw TrackerError(message: "invalid regular expression: missing trailing slash")
			}
			patternString = _patternString
		}
		else {
			patternString = "\\b\(NSRegularExpression.escapedPatternForString(viewControllerTypeName))\\b"
		}

		var page: TrackerConfiguration.Page
		do {
			let pattern = try NSRegularExpression(pattern: patternString, options: [])
			page = TrackerConfiguration.Page(viewControllerTypeNamePattern: pattern, pageProperties: PageProperties(name: pageName))
		}
		catch let error {
			throw TrackerError(message: "invalid regular expression: \(error)")
		}

		if let screenParameter = screenTrackingParameter {
			page.actionProperties = screenParameter.actionProperties()
			page.advertisementProperties = screenParameter.advertisementProperties()
			page.ecommerceProperties = screenParameter.ecommerceProperties()
			page.ipAddress = screenParameter.parameters[.ipAddress]?.serialized()
			page.mediaProperties = screenParameter.mediaProperties()
			page.pageProperties = page.pageProperties.merged(over: screenParameter.pageProperties())
			page.sessionDetails = screenParameter.sessionDetails()
			page.userProperties = screenParameter.userProperties()
		}

		automaticallyTrackedPages.append(page)
	}


	private func readFromScreenTrackingParameterElement(xmlElement: XmlElement) throws -> ScreenTrackingParameter? {
		guard xmlElement.name == "screenTrackingParameter" else {
			throw TrackerError(message: "screenTrackingParameter nodes needs to be screenTrackingParameter")
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

	private func readFromParameterElement(xmlElement: XmlElement) -> (PropertyName, PropertyValue)? {
		guard xmlElement.name == "parameter" else {
			return nil
		}
		guard let parameterName = xmlElement.attributes["id"] else {
			return nil
		}
		if let propertyName = PropertyName(rawValue: parameterName) {
            if let key = xmlElement.attributes["key"] {
                return (propertyName, value: .key(key))
            }else{
                return (propertyName, value: .value(xmlElement.text))
            }
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
			throw TrackerError(message: "'\(string)' is not a valid boolean (expected 'true' or 'false')")
		}
	}


	private func parseDouble(string: String, allowedRange: ClosedInterval<Double>) throws -> Double? {
		guard let value = Double(string) else {
			throw TrackerError(message: "'\(string)' is not a valid number")
		}

		if !allowedRange.contains(value) {
			throw TrackerError(message: "value (\(value)) must be \(allowedRange.conditionText)")
		}

		return value
	}


	private func parseInt(string: String, allowedRange: ClosedInterval<Int>) throws -> Int? {
		guard let value = Int(string) else {
			throw TrackerError(message: "'\(string)' is not a valid integer")
		}

		if !allowedRange.contains(value) {
			if allowedRange.end == .max {
				throw TrackerError(message: "value (\(value)) must be larger than or equal to \(allowedRange.start)")
			}
			if allowedRange.start == .min {
				throw TrackerError(message: "value (\(value)) must be smaller than or equal to \(allowedRange.end)")
			}

			throw TrackerError(message: "value (\(value)) must be between \(allowedRange.start) (inclusive) and \(allowedRange.end) (inclusive)")
		}

		return value
	}


	private func parseString(string: String, emptyAllowed: Bool) throws -> String? {
		if string.isEmpty {
			if !emptyAllowed {
				throw TrackerError(message: "must not be empty")
			}

			return nil
		}

		return string
	}


	private func parseUrl(string: String, emptyAllowed: Bool) throws -> NSURL? {
		if string.isEmpty {
			if !emptyAllowed {
				throw TrackerError(message: "must not be empty")
			}

			return nil
		}

		guard let value = NSURL(string: string) else {
			throw TrackerError(message: "'\(string)' is not a valid URL")
		}

		return value
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
		var parameters: [PropertyName: PropertyValue]

		init(categories: [String: [Int: CategoryElement]], parameters: [PropertyName: PropertyValue]) {
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
			if let id = parameters[.advertisementId]?.serialized() {
				advertisementId = id
			}
			var advertisementAction: String? = nil
			if let action = parameters[.advertisementAction]?.serialized() {
				advertisementAction = action
			}
			var details: [Int: TrackingValue]? = nil
			if let elements = categories["adParameter"], advertisementDetails = resolved(elements) {
				details = advertisementDetails
			}

			return AdvertisementProperties(id: advertisementId, action: advertisementAction, details: details)
		}

		
		private func ecommerceProperties() -> EcommerceProperties {
        
            var ecommerceProperties = EcommerceProperties()
			
            if let currencyCodeConfig = parameters[.currencyCode] {
				ecommerceProperties.currencyCodeConfig = currencyCodeConfig
			}
            
			if let orderNumberConfig = parameters[.orderNumber] {
				ecommerceProperties.orderNumberConfig = orderNumberConfig
			}
            
			if let statusConfig = parameters[.productStatus] {
                ecommerceProperties.statusConfig = statusConfig
			}

            if let totalValueConfig = parameters[.totalValue] {
                ecommerceProperties.totalValueConfig = totalValueConfig
            }

            if let voucherValueConfig = parameters[.voucherValue] {
                ecommerceProperties.voucherValueConfig = voucherValueConfig
            }
        
			if let elements = categories["ecomParameter"], ecommerceDetails = resolved(elements) {
				ecommerceProperties.details = ecommerceDetails
			}

			if let productConf = productProperties() {
				ecommerceProperties.productConf = productConf
			}

			return ecommerceProperties
		}


		private func mediaProperties() -> MediaProperties {
			return MediaProperties(name: nil, groups: categories["mediaCategories"].flatMap { resolved($0) })
		}


		private func pageProperties() -> PageProperties {
			var pageProperties = PageProperties(name: nil)
			if let internalSearchConfig = parameters[.internalSearch] {
                pageProperties.internalSearchConfig = internalSearchConfig
			}
			if let url = parameters[.pageUrl]?.serialized() {
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
            
            var productNameConfig: PropertyValue? = nil
			if let nameConfig = parameters[.productName] {
				productNameConfig = nameConfig
			}
			var productPriceConfig: PropertyValue? = nil
			if let priceConfig = parameters[.productPrice] {
				productPriceConfig = priceConfig
            }
			var productQuantityConfig: PropertyValue? = nil
			if let quantityConfig = parameters[.productQuantity] {
				productQuantityConfig = quantityConfig
			}
			var productCategories: [Int: TrackingValue]? = nil
			if let elements = categories["productCategories"], productCategoriesElements = resolved(elements) {
				productCategories = productCategoriesElements
			}

			guard productNameConfig != nil || productPriceConfig != nil || productQuantityConfig != nil || productCategories != nil else {
				return nil
			}

			return EcommerceProperties.Product(nameConfig: productNameConfig, categories: productCategories, priceConfig: productPriceConfig, quantityConfig: productQuantityConfig)
		}


		private func sessionDetails() -> [Int: TrackingValue] {
			return categories["sessionParameter"].flatMap { resolved($0) } ?? [:]
		}


		private func userProperties() -> UserProperties {
			var userProperties = UserProperties(birthday: nil)
			if let categoryElements = categories["userCategories"], details = resolved(categoryElements) {
				userProperties.details = details
			}
			if let bithdayConfig = parameters[.birthday]  {
				userProperties.birthdayConfig = bithdayConfig
			}
			if let city = parameters[.city]?.serialized() {
				userProperties.city = city
			}
			if let country = parameters[.country]?.serialized() {
				userProperties.country = country
			}
			if let idConfig = parameters[.customerId] {
				userProperties.idConfig = idConfig
			}
			if let emailAddressConfig = parameters[.emailAddress] {
				userProperties.emailAddressConfig = emailAddressConfig
			}
			if let emailReceiverIdConfig = parameters[.emailReceiverId] {
				userProperties.emailReceiverIdConfig = emailReceiverIdConfig
			}
			if let firstName = parameters[.firstName]?.serialized() {
				userProperties.city = firstName
			}
			if let genderConfig = parameters[.gender] {
                userProperties.genderConfig = genderConfig
            }
			if let lastName = parameters[.lastName]?.serialized() {
				userProperties.city = lastName
			}
			if let newsletterSubscribed = parameters[.newsletterSubscribed]?.serialized() {
				userProperties.city = newsletterSubscribed
			}
			if let phoneNumber = parameters[.phoneNumber]?.serialized() {
				userProperties.city = phoneNumber
			}
			if let street = parameters[.street]?.serialized() {
				userProperties.city = street
			}
			if let streetNumber = parameters[.streetNumber]?.serialized() {
				userProperties.city = streetNumber
			}
			if let zipCode = parameters[.zipCode]?.serialized() {
				userProperties.zipCode = zipCode
			}
			return userProperties
		}
	}



	struct CategoryElement {
		internal var key: String?
		internal var value: String
	}
}
