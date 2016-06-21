import CoreGraphics
import Foundation


internal final class BackupManager {

	private let fileManager: FileManager

	internal var logger: Webtrekk.Logger


	internal init(fileManager: FileManager, logger: Webtrekk.Logger) {
		self.fileManager = fileManager
		self.logger = logger
	}


	internal func saveEvents(events: [TrackingEvent], to file: NSURL) {
		let jsonEvents = events.map { $0.toJson() }

		do {
			let data = try NSJSONSerialization.dataWithJSONObject(jsonEvents, options: [])
			fileManager.saveData(toFileUrl: file, data: data)
		}
		catch let error {
			logger.logError("Cannot save pending events to disk: \(error)")
		}

		logger.logInfo("Stored \(jsonEvents.count) to disc.")
	}


	internal func loadEvents(from file: NSURL) -> [TrackingEvent] {
		guard let data = fileManager.restoreData(fromFileUrl: file) else {
			return []
		}
		guard let jsonEvents: [[String: AnyObject]] = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [[String: AnyObject]] else {
			logger.logInfo("Data was not a valid json to be restored.")

			return []
		}

		var events = [TrackingEvent]()
		events.reserveCapacity(jsonEvents.count)

		for jsonEvent in jsonEvents {
			guard let event = TrackingEvent(json: jsonEvent) else {
				logger.logError("Cannot load pending event from disk: \(jsonEvent)")
				continue
			}

			events.append(event)
		}

		return events
	}
}



private extension TrackingEvent {

	private init?(json: [String : AnyObject]) {
		return nil // FIXME
	}


	private func toJson() -> [String : AnyObject] {
		var result = [String : AnyObject]()
		
		return result // FIXME
	}
}







internal protocol Backupable {
	func toJson() -> [String: AnyObject]
	static func fromJson(json: [String: AnyObject]) -> Self?
}

extension AutoTrackedScreen: Backupable {
	internal func toJson() -> [String : AnyObject] {
		var items = [String: AnyObject]()
		items["className"] = className
		items["mappingName"] = mappingName
		items["enabled"] = enabled
		items["pageTracking"] = pageTracking?.toJson()
		return items
	}


	static func fromJson(json: [String: AnyObject]) -> AutoTrackedScreen? {
		var autoTrackedScreen: AutoTrackedScreen
		guard let className = json["className"] as? String, let mappingName = json["mappingName"] as? String else {
			return nil
		}
		autoTrackedScreen = AutoTrackedScreen(className: className, mappingName: mappingName)

		if let enabled = json["enabled"] as? Bool {
			autoTrackedScreen.enabled = enabled
		}
		if let pageJson = json["parameters"] as? [String: AnyObject], let pageTracking = PageTracking.fromJson(pageJson) {
			autoTrackedScreen.pageTracking = pageTracking
		}
		return autoTrackedScreen
	}
}

extension TrackerConfiguration: Backupable {
	internal func toJson() -> [String : AnyObject] {
		var items = [String: AnyObject]()
		items["appVersion"] = appVersion
		items["maxRequests"] = maxRequests
		items["samplingRate"] = samplingRate
		items["sendDelay"] = sendDelay
		items["version"] = version
		items["optedOut"] = optedOut
		items["serverUrl"] = serverUrl
		items["trackingId"] = trackingId
		items["autoTrack"] = autoTrack
		items["autoTrackAdvertiserId"] = autoTrackAdvertiserId
		items["autoTrackApiLevel"] = autoTrackApiLevel
		items["autoTrackAppUpdate"] = autoTrackAppUpdate
		items["autoTrackAppVersionName"] = autoTrackAppVersionName
		items["autoTrackAppVersionCode"] = autoTrackAppVersionCode
		items["autoTrackConnectionType"] = autoTrackConnectionType
		items["autoTrackRequestUrlStoreSize"] = autoTrackRequestUrlStoreSize
		items["autoTrackScreenOrientation"] = autoTrackScreenOrientation
		items["enableRemoteConfiguration"] = enableRemoteConfiguration
		items["remoteConfigurationUrl"] = remoteConfigurationUrl
		items["configFilePath"] = configFilePath

		if !autoTrackScreens.isEmpty {
			items["autoTrackScreens"] = autoTrackScreens.map({["index":$0.0, "value": $0.1.toJson()]})
		}
		return items
	}

	static func fromJson(json: [String: AnyObject]) -> TrackerConfiguration? {
		var config: TrackerConfiguration
		guard let trackingId = json["trackingId"] as? String, let serverUrl = json["serverUrl"] as? String else {
			return nil
		}
		if let configFilePath = json["configFilePath"] as? String {
			config = TrackerConfiguration(configFilePath: configFilePath, serverUrl: serverUrl, trackingId: trackingId)
		}
		else {
			config = TrackerConfiguration(serverUrl: serverUrl, trackingId: trackingId)
		}

		if let appVersion = json["appVersion"] as? String {
			config.appVersion = appVersion
		}
		if let maxRequests = json["maxRequests"] as? Int {
			config.maxRequests = maxRequests
		}
		if let samplingRate = json["samplingRate"] as? Int {
			config.samplingRate = samplingRate
		}
		if let sendDelay = json["sendDelay"] as? Int {
			config.sendDelay = NSTimeInterval(sendDelay)
		}
		if let version = json["version"] as? Int {
			config.version = version
		}
		if let optedOut = json["optedOut"] as? Bool {
			config.optedOut = optedOut
		}

		if let autoTrack = json["autoTrack"] as? Bool {
			config.autoTrack = autoTrack
		}
		if let autoTrackAdvertiserId = json["autoTrackAdvertiserId"] as? Bool {
			config.autoTrackAdvertiserId = autoTrackAdvertiserId
		}
		if let autoTrackApiLevel = json["autoTrackApiLevel"] as? Bool {
			config.autoTrackApiLevel = autoTrackApiLevel
		}
		if let autoTrackAppUpdate = json["autoTrackAppUpdate"] as? Bool {
			config.autoTrackAppUpdate = autoTrackAppUpdate
		}
		if let autoTrackAppVersionName = json["autoTrackAppVersionName"] as? Bool {
			config.autoTrackAppVersionName = autoTrackAppVersionName
		}
		if let autoTrackAppVersionCode = json["autoTrackAppVersionCode"] as? Bool {
			config.autoTrackAppVersionCode = autoTrackAppVersionCode
		}
		if let autoTrackConnectionType = json["autoTrackConnectionType"] as? Bool {
			config.autoTrackConnectionType = autoTrackConnectionType
		}
		if let autoTrackRequestUrlStoreSize = json["autoTrackRequestUrlStoreSize"] as? Bool {
			config.autoTrackRequestUrlStoreSize = autoTrackRequestUrlStoreSize
		}
		if let autoTrackScreenOrientation = json["autoTrackScreenOrientation"] as? Bool {
			config.autoTrackScreenOrientation = autoTrackScreenOrientation
		}
		if let enableRemoteConfiguration = json["enableRemoteConfiguration"] as? Bool {
			config.enableRemoteConfiguration = enableRemoteConfiguration
		}
		if let remoteConfigurationUrl = json["remoteConfigurationUrl"] as? String {
			config.remoteConfigurationUrl = remoteConfigurationUrl
		}
		if let autoScreenDic = json["autoTrackScreens"] as? [[String: AnyObject]] {
			for item in autoScreenDic {
				guard let index = item["index"] as? String, let value = item["value"] as? [String: AnyObject] else {
					continue
				}
				config.autoTrackScreens[index] =  AutoTrackedScreen.fromJson(value)
			}
		}
		return config
	}
}

extension Event: Backupable {
	internal func toJson() -> [String : AnyObject] {
		var items = [String: AnyObject]()
		items["general"] = general.toJson()
		items["pixel"] = pixel.toJson()

		if let action = action {
			items["action"] = action.toJson()
		}
		else if let media = media {
			items["media"] = media.toJson()
		}
		else if let page = page {
			items["page"] = page.toJson()
		}


		items["custom"] = custom.map({["index":$0.0, "value": $0.1]})
		if let customer = customer {
			items["customer"] = customer.toJson()
		}
		if let ecommerce = ecommerce {
			items["ecommerce"] = ecommerce.toJson()
		}
		items["products"] = products.map({$0.toJson()})

		items["autoTracking"] = autoTracking.map({["index":$0.0, "value": $0.1]})
		items["crossDevice"] = crossDevice.map({["index":$0.0, "value": $0.1]})

		if let baseUrl = baseUrl {
			items["baseUrl"] = baseUrl.absoluteString
		}

		return items
	}

	internal static func fromJson(json: [String : AnyObject]) -> Event? {
		return Event(json: json)
	}
}

internal extension Event {
	internal init?(json: [String: AnyObject]) {
		guard let pixelJson = json["pixel"] as? [String: AnyObject], pixel = PixelParameter.fromJson(pixelJson),
			generalJson = json["general"] as? [String: AnyObject], general = GeneralParameter.fromJson(generalJson)
			else {
				return nil
		}

		var action: ActionParameter? = nil
		var media: MediaParameter? = nil
		var page: PageParameter? = nil
		var baseUrl: NSURL? = nil
		var ecommerce: EcommerceParameter? = nil
		var customer: CustomerParameter? = nil

		if let actionJson = json["action"] as? [String: AnyObject], let value = ActionParameter.fromJson(actionJson) {
			action = value
		}
		else if let mediaJson = json["media"] as? [String: AnyObject], let value = MediaParameter.fromJson(mediaJson) {
			media = value
		}
		else if let pageJson = json["page"] as? [String: AnyObject], let value = PageParameter.fromJson(pageJson) {
			page = value
		}
		else {
			return nil
		}

		if let customDic = json["custom"] as? [[String: AnyObject]] {
			for item in customDic {
				if let key = item["index"] as? String {
					custom[key] =  item["value"] as? String
				}
			}
		}
		if let customerJson = json["customer"] as? [String: AnyObject], let value = CustomerParameter.fromJson(customerJson) {
			customer = value
		}
		if let ecommerceJson = json["ecommerce"] as? [String: AnyObject], let value = EcommerceParameter.fromJson(ecommerceJson) {
			ecommerce = value
		}
		if let productJson = json["products"] as? [[String: AnyObject]] {
			self.products = productJson.map({ProductParameter.fromJson($0)}).filterNonNil()
		}

		if let autotrackingDic = json["autoTracking"] as? [[String: AnyObject]] {
			for item in autotrackingDic {
				if let key = item["index"] as? String {
					autoTracking[key] =  item["value"] as? String
				}
			}
		}
		if let crossDeviceDic = json["crossDevice"] as? [[String: AnyObject]] {
			for item in crossDeviceDic {
				if let key = item["index"] as? String {
					crossDevice[key] =  item["value"] as? String
				}
			}
		}

		if let baseUrlString = json["baseUrl"] as? String, value = NSURL(string: baseUrlString) {
			baseUrl = value
		}

		self.pixel = pixel
		self.general = general

		self.action = action
		self.media = media
		self.page = page

		self.ecommerce = ecommerce
		self.customer = customer
		self.baseUrl = baseUrl
	}
}

extension ActionTracking: Backupable {
	internal func toJson() -> [String : AnyObject] {
		var items = [String: AnyObject]()
		if let ecommerceParameter = ecommerceParameter {
			items["ecommerceParameter"] = ecommerceParameter.toJson()
		}
		items["customParameters"] = customParameters.map({["index":$0.0, "value": $0.1]})
		if let customerParameter = customerParameter {
			items["customerParameter"] = customerParameter.toJson()
		}
		items["generalParameter"] = generalParameter.toJson()
		items["pixelParameter"] = pixelParameter.toJson()
		items["productParameters"] = productParameters.map({$0.toJson()})
		items["actionParameter"] = actionParameter!.toJson()
		return items
	}

	internal static func fromJson(json: [String: AnyObject]) -> ActionTracking? {
		guard let actionParameterJson = json["actionParameter"] as? [String: AnyObject], let actionParameter = ActionParameter.fromJson(actionParameterJson) else {
			return nil
		}
		var tracking = ActionTracking(actionParameter: actionParameter)

		guard let pixelParameterJson = json["pixelParameter"] as? [String: AnyObject], let pixelParameter = PixelParameter.fromJson(pixelParameterJson) else {
			return nil
		}
		tracking.pixelParameter = pixelParameter

		guard let generalParameterJson = json["generalParameter"] as? [String: AnyObject], let generalParameter = GeneralParameter.fromJson(generalParameterJson) else {
			return nil
		}
		tracking.generalParameter = generalParameter

		if let customerParameterJson = json["customerParameter"] as? [String: AnyObject], let customerParameter = CustomerParameter.fromJson(customerParameterJson) {
			tracking.customerParameter = customerParameter
		}

		if let ecommerceParameterJson = json["ecommerceParameter"] as? [String: AnyObject], let ecommerceParameter = EcommerceParameter.fromJson(ecommerceParameterJson) {
			tracking.ecommerceParameter = ecommerceParameter
		}

		if let productParametersJson = json["productParameters"] as? [[String: AnyObject]] {
			tracking.productParameters = productParametersJson.map({ProductParameter.fromJson($0)!})
		}

		if let customDic = json["customParameters"] as? [[String: AnyObject]] {
			for item in customDic {
				tracking.customParameters[item["index"] as! String] =  item["value"] as? String
			}
		}

		return tracking
	}
}

extension PageTracking: Backupable {
	internal func toJson() -> [String : AnyObject] {
		var items = [String: AnyObject]()
		if let ecommerceParameter = ecommerceParameter {
			items["ecommerceParameter"] = ecommerceParameter.toJson()
		}
		items["customParameters"] = customParameters.map({["index":$0.0, "value": $0.1]})
		if let customerParameter = customerParameter {
			items["customerParameter"] = customerParameter.toJson()
		}
		items["generalParameter"] = generalParameter.toJson()
		items["pixelParameter"] = pixelParameter.toJson()
		items["productParameters"] = productParameters.map({$0.toJson()})
		items["pageParameter"] = pageParameter!.toJson()
		return items
	}


	internal static func fromJson(json: [String: AnyObject]) -> PageTracking? {
		guard let pageParameterJson = json["pageParameter"] as? [String: AnyObject], let pageParameter = PageParameter.fromJson(pageParameterJson) else {
			return nil
		}

		guard let pixelParameterJson = json["pixelParameter"] as? [String: AnyObject], let pixelParameter = PixelParameter.fromJson(pixelParameterJson) else {
			return nil
		}

		guard let generalParameterJson = json["generalParameter"] as? [String: AnyObject], let generalParameter = GeneralParameter.fromJson(generalParameterJson) else {
			return nil
		}

		var tracking = PageTracking(pageName: pixelParameter.pageName, pageParameter: pageParameter)
		tracking.pixelParameter = pixelParameter
		tracking.generalParameter = generalParameter

		if let customerParameterJson = json["customerParameter"] as? [String: AnyObject], let customerParameter = CustomerParameter.fromJson(customerParameterJson) {
			tracking.customerParameter = customerParameter
		}

		if let ecommerceParameterJson = json["ecommerceParameter"] as? [String: AnyObject], let ecommerceParameter = EcommerceParameter.fromJson(ecommerceParameterJson) {
			tracking.ecommerceParameter = ecommerceParameter
		}

		if let productParametersJson = json["productParameters"] as? [[String: AnyObject]] {
			tracking.productParameters = productParametersJson.map({ProductParameter.fromJson($0)!})
		}

		if let customDic = json["customParameters"] as? [[String: AnyObject]] {
			for item in customDic {
				tracking.customParameters[item["index"] as! String] =  item["value"] as? String
			}
		}

		return tracking
	}
}


extension MediaTracking: Backupable {
	internal func toJson() -> [String : AnyObject] {
		var items = [String: AnyObject]()
		items["customParameters"] = customParameters.map({["index":$0.0, "value": $0.1]})
		items["generalParameter"] = generalParameter.toJson()
		items["pixelParameter"] = pixelParameter.toJson()
		items["mediaParameter"] = mediaParameter!.toJson()
		return items
	}


	internal static func fromJson(json: [String: AnyObject]) -> MediaTracking? {
		guard let mediaParameterJson = json["mediaParameter"] as? [String: AnyObject], let mediaParameter = MediaParameter.fromJson(mediaParameterJson) else {
			return nil
		}
		var tracking = MediaTracking(mediaParameter: mediaParameter)

		guard let pixelParameterJson = json["pixelParameter"] as? [String: AnyObject], let pixelParameter = PixelParameter.fromJson(pixelParameterJson) else {
			return nil
		}
		tracking.pixelParameter = pixelParameter

		guard let generalParameterJson = json["generalParameter"] as? [String: AnyObject], let generalParameter = GeneralParameter.fromJson(generalParameterJson) else {
			return nil
		}
		tracking.generalParameter = generalParameter

		if let customDic = json["customParameters"] as? [[String: AnyObject]] {
			for item in customDic {
				tracking.customParameters[item["index"] as! String] =  item["value"] as? String
			}
		}

		return tracking
	}
}

extension MediaParameter: Backupable {
	internal func toJson() -> [String : AnyObject] {
		var items = [String: AnyObject]()
		items["action"] = action.rawValue
		items["duration"] = duration
		items["name"] = name
		items["position"] = position
		items["timeStamp"] = "\(timeStamp.timeIntervalSince1970)"

		if let bandwidth = bandwidth {
			items["bandwidth"] = bandwidth
		}
		if !categories.isEmpty {
			items["categories"] = categories.map({["index":$0.0, "value": $0.1]})
		}
		if let mute = mute {
			items["mute"] = mute
		}
		if let volume = volume {
			items["volume"] = volume
		}
		return items
	}


	internal static func fromJson(json: [String: AnyObject]) -> MediaParameter? {
		guard let actionString = json["action"] as? String, let duration = json["duration"] as? Int, let name = json["name"] as? String, let position = json["position"] as? Int, let timeStampValue = json["timeStamp"] as? String, let timeStamp = Double(timeStampValue) else {
			return nil
		}
		let action: MediaAction
		switch actionString {
		case MediaAction.EndOfFile.rawValue:
			action = .EndOfFile
		case MediaAction.Pause.rawValue:
			action = .Pause
		case MediaAction.Play.rawValue:
			action = .Play
		case MediaAction.Position.rawValue:
			action = .Position
		case MediaAction.Seek.rawValue:
			action = .Seek
		case MediaAction.Stop.rawValue:
			action = .Stop
		default:
			action = .Play
		}
		var parameter = MediaParameter(action: action, duration: duration, name: name, position: position, timeStamp: NSDate(timeIntervalSince1970: timeStamp))

		if let bandwidth = json["bandwidth"] as? Int {
			parameter.bandwidth = bandwidth

		}
		if let categoriesDic = json["categories"] as? [[String: AnyObject]] {
			for item in categoriesDic {
				parameter.categories[item["index"] as! Int] =  item["value"] as? String
			}
		}

		if let mute = json["mute"] as? Bool {
			parameter.mute = mute

		}
		if let volume = json["volume"] as? Int {
			parameter.volume = volume

		}
		return parameter
	}
}

extension EcommerceParameter: Backupable {
	internal func toJson() -> [String : AnyObject] {
		var items = [String: AnyObject]()
		items["currency"] = currency
		items["categories"] = categories.map({["index":$0.0, "value": $0.1]})
		items["orderNumber"] = orderNumber
		items["status"] = status.rawValue
		items["totalValue"] = totalValue
		if let voucherValue = voucherValue {
			items["voucherValue"] = voucherValue
		}
		return items
	}

	internal static func fromJson(json: [String: AnyObject]) -> EcommerceParameter? {
		guard let totalValue = json["totalValue"] as? Double else {
			return nil
		}
		var parameter = EcommerceParameter(totalValue: totalValue)
		if let currency = json["currency"] as? String {
			parameter.currency = currency
		}
		if let orderNumber = json["orderNumber"] as? String {
			parameter.orderNumber = orderNumber

		}
		if let categoriesDic = json["categories"] as? [[String: AnyObject]] {
			for item in categoriesDic {
				parameter.categories[item["index"] as! Int] =  item["value"] as? String
			}
		}
		if let status = json["status"] as? String {
			switch status {
			case EcommerceStatus.CONF.rawValue:
				parameter.status = EcommerceStatus.CONF
			case EcommerceStatus.ADD.rawValue:
				parameter.status = EcommerceStatus.ADD
			default:
				parameter.status = EcommerceStatus.VIEW
			}
		}
		if let totalValue = json["totalValue"] as? Double {
			parameter.totalValue = totalValue

		}
		if let voucherValue = json["voucherValue"] as? Double {
			parameter.voucherValue = voucherValue

		}
		return parameter
	}
}

extension GeneralParameter: Backupable {
	internal func toJson() -> [String : AnyObject] {
		var items = [String: AnyObject]()
		items["everId"] = everId
		items["firstStart"] = firstStart
		items["ip"] = ip
		items["nationalCode"] = nationalCode
		items["samplingRate"] = samplingRate
		items["timeStamp"] = "\(timeStamp.timeIntervalSince1970)"
		items["timeZoneOffset"] = timeZoneOffset
		items["userAgent"] = userAgent
		return items
	}

	internal static func fromJson(json: [String: AnyObject]) -> GeneralParameter? {
		guard let everId = json["everId"] as? String, let timeStampValue = json["timeStamp"] as? String, let timeStamp = Double(timeStampValue), let timeZoneOffset = json["timeZoneOffset"] as? Double, let userAgent = json["userAgent"] as? String else {
			return nil
		}
		var parameter = GeneralParameter(everId: everId, timeStamp: NSDate(timeIntervalSince1970: timeStamp), timeZoneOffset: timeZoneOffset, userAgent: userAgent)
		if let firstStart = json["firstStart"] as? Bool {
			parameter.firstStart = firstStart
		}
		if let ip = json["ip"] as? String {
			parameter.ip = ip
		}
		if let nationalCode = json["nationalCode"] as? String {
			parameter.nationalCode = nationalCode
		}
		if let samplingRate = json["samplingRate"] as? Int {
			parameter.samplingRate = samplingRate
		}
		return parameter
	}

}

extension PixelParameter: Backupable {
	internal func toJson() -> [String : AnyObject] {
		var items = [String: AnyObject]()
		items["version"] = version
		items["pageName"] = pageName
		items["displaySize"] = ["width": displaySize.width, "height": displaySize.height ]
		items["timeStamp"] = "\(timeStamp.timeIntervalSince1970)"
		return items
	}

	internal static func fromJson(json: [String : AnyObject]) -> PixelParameter? {
		guard let displaySizeValues = json["displaySize"] as? [String: CGFloat], let width = displaySizeValues["width"], let height = displaySizeValues["height"], let version = json["version"] as? Int else {
			return nil
		}
		var parameter = PixelParameter(version: version, displaySize: CGSize(width: width, height: height))
		if let pageName = json["pageName"] as? String {
			parameter.pageName = pageName
		}
		if let timeStampValue = json["timeStamp"] as? String, let timeStamp = Double(timeStampValue) {
			parameter.timeStamp = NSDate(timeIntervalSince1970: timeStamp)
		}
		return parameter
	}
}

extension ProductParameter: Backupable {
	internal func toJson() -> [String : AnyObject] {
		var items = [String: AnyObject]()
		items["currency"] = currency
		items["categories"] = categories.map({["index":$0.0, "value": $0.1]})
		items["name"] = name
		items["price"] = price
		items["quantity"] = quantity
		return items
	}

	internal static func fromJson(json: [String: AnyObject]) -> ProductParameter? {
		guard let name = json["name"] as? String else {
			return nil
		}
		var parameter = ProductParameter(name: name)
		if let currency = json["currency"] as? String {
			parameter.currency = currency
		}
		if let categoriesDic = json["categories"] as? [[String: AnyObject]] {
			for item in categoriesDic {
				parameter.categories[item["index"] as! Int] =  item["value"] as? String
			}
		}
		if let price = json["price"] as? String {
			parameter.price = price

		}
		if let quantity = json["quantity"] as? String {
			parameter.quantity = quantity

		}
		return parameter
	}

}

extension PageParameter: Backupable {
	internal func toJson() -> [String : AnyObject] {
		var items = [String: AnyObject]()
		items["page"] = page.map({["index":$0.0, "value": $0.1]})
		items["categories"] = categories.map({["index":$0.0, "value": $0.1]})
		items["session"] = session.map({["index":$0.0, "value": $0.1]})
		return items
	}


	internal static func fromJson(json: [String: AnyObject]) -> PageParameter? {
		var parameter = PageParameter()
		if let pageDic = json["page"] as? [[String: AnyObject]] {
			for item in pageDic {
				parameter.page[item["index"] as! Int] =  item["value"] as? String
			}
		}
		if let categoriesDic = json["categories"] as? [[String: AnyObject]] {
			for item in categoriesDic {
				parameter.categories[item["index"] as! Int] =  item["value"] as? String
			}
		}
		if let sessionDic = json["session"] as? [[String: AnyObject]] {
			for item in sessionDic {
				parameter.session[item["index"] as! Int] =  item["value"] as? String
			}
		}
		return parameter
	}
}

extension ActionParameter: Backupable {
	internal func toJson() -> [String : AnyObject] {
		var items = [String: AnyObject]()
		items["name"] = name
		items["categories"] = categories.map({["index":$0.0, "value": $0.1]})
		items["session"] = session.map({["index":$0.0, "value": $0.1]})
		return items
	}


	internal static func fromJson(json: [String: AnyObject]) -> ActionParameter? {
		guard let name = json["name"] as? String else {
			return nil
		}
		var parameter = ActionParameter(name: name)
		if let categoriesDic = json["categories"] as? [[String: AnyObject]] {
			for item in categoriesDic {
				parameter.categories[item["index"] as! Int] =  item["value"] as? String
			}
		}
		if let sessionDic = json["session"] as? [[String: AnyObject]] {
			for item in sessionDic {
				parameter.session[item["index"] as! Int] =  item["value"] as? String
			}
		}
		return parameter
	}
}

extension CustomerParameter: Backupable {
	internal func toJson() -> [String : AnyObject] {
		var items = [String: AnyObject]()
		items["categories"] = categories.map({["index":$0.0, "value": $0.1]})
		if let birthday = birthday {
			items["birthday"] = "\(birthday.timeIntervalSince1970)"
		}
		items["city"] = city
		items["country"] = country
		items["eMail"] = eMail
		items["eMailReceiverId"] = eMailReceiverId
		if let gender = gender {
			items["gender"] = gender.toValue()
		}
		items["firstName"] = firstName
		items["lastName"] = lastName
		if let newsletter = newsletter {
			items["newsletter"] = newsletter
		}
		items["number"] = number
		items["phoneNumber"] = phoneNumber
		items["street"] = street
		items["streetNumber"] = streetNumber
		items["zip"] = zip
		return items
	}


	internal static func fromJson(json: [String: AnyObject]) -> CustomerParameter? {
		var parameter = CustomerParameter()
		if let timeStampValue = json["birthday"] as? String, let timeStamp = Double(timeStampValue) {
			parameter.birthday = NSDate(timeIntervalSince1970: timeStamp)
		}
		if let categoriesDic = json["categories"] as? [[String: AnyObject]] {
			for item in categoriesDic {
				parameter.categories[item["index"] as! Int] =  item["value"] as? String
			}
		}
		if let city = json["city"] as? String {
			parameter.city = city
		}
		if let country = json["country"] as? String {
			parameter.country = country
		}
		if let eMail = json["eMail"] as? String {
			parameter.eMail = eMail
		}
		if let eMailReceiverId = json["eMailReceiverId"] as? String {
			parameter.eMailReceiverId = eMailReceiverId
		}
		if let gender = json["gender"] as? String {
			parameter.gender = CustomerGender.from(gender)
		}
		if let firstName = json["firstName"] as? String {
			parameter.firstName = firstName
		}
		if let lastName = json["lastName"] as? String {
			parameter.lastName = lastName
		}
		if let newsletter = json["newsletter"] as? Bool {
			parameter.newsletter = newsletter
		}
		if let number = json["number"] as? String {
			parameter.number = number
		}
		if let phoneNumber = json["phoneNumber"] as? String {
			parameter.phoneNumber = phoneNumber
		}
		if let street = json["street"] as? String {
			parameter.street = street
		}
		if let streetNumber = json["streetNumber"] as? String {
			parameter.streetNumber = streetNumber
		}
		if let zip = json["zip"] as? String {
			parameter.zip = zip
		}
		return parameter
	}
}
