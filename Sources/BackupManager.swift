import Foundation
import UIKit

internal struct BackupManager: Logable {

	var loger: Loger

	private let fileManager: FileManager


	internal init(_ loger: Loger) {
		self.loger = loger
		self.fileManager = FileManager(loger)
	}


	internal func saveToDisc(fileUrl: NSURL, queue: Queue<WebtrekkQueue.TrackingQueueItem>) {
		var json = [AnyObject]()
		let itemCount = queue.itemCount
		var array: [WebtrekkQueue.TrackingQueueItem] = []
		repeat {
			guard let item = queue.dequeue() else {
				break
			}
			array.append(item)
			var items = [String: AnyObject]()
			if let action = item.parameter as? ActionTrackingParameter{
				items["parameters"] = action.toJson()
				items["type"] = "action"
			}
			else if let page = item.parameter as? PageTrackingParameter {
				items["parameters"] = page.toJson()
				items["type"] = "page"
			} else {
				log("as of now only support action and page tracking parameters")
			}
			items["config"] = item.config.toJson()
			json.append(items)
		} while queue.itemCount > 0

		for item in array {
			queue.enqueue(item)
		}
		
		guard NSJSONSerialization.isValidJSONObject(json), let data = try? NSJSONSerialization.dataWithJSONObject(json, options: NSJSONWritingOptions()) else {
			log("something went wrong during backup")
			return
		}

		fileManager.saveData(toFileUrl: fileUrl, data: data)
		log("Stored \(itemCount) to disc.")
	}


	internal func restoreFromDisc(fileUrl: NSURL) -> Queue<WebtrekkQueue.TrackingQueueItem> {
		let queue = Queue<WebtrekkQueue.TrackingQueueItem>()
		// get file storage location based on tracker config
		guard let data = fileManager.restoreData(fromFileUrl: fileUrl) else {
			return queue
		}
		guard let json: [AnyObject] = (try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions())) as? [AnyObject] else {
			log("Data was not a valid json to be restored.")
			return queue
		}
		for item in json {
			let config: TrackerConfiguration
			let parameter: TrackingParameter
			if let type: String = item["type"] as? String where type == "page" {
				guard let page = PageTrackingParameter.fromJson(item["parameters"] as! [String: AnyObject]) else {
					continue
				}
				parameter = page
			}
			else if let type: String = item["type"] as? String where type == "action"{
				guard let action = ActionTrackingParameter.fromJson(item["parameters"] as! [String: AnyObject]) else {
					continue
				}
				parameter = action
			}
			else {
				log("Item was of neither page or action type and cannot be restored at the moment.")
				continue
			}
			guard let trackerConfig = TrackerConfiguration.fromJson(item["config"] as! [String: AnyObject]) else {
				continue
			}
			config = trackerConfig
			queue.enqueue(WebtrekkQueue.TrackingQueueItem(config:config, parameter: parameter))
		}
		return queue
	}
}


internal protocol Backupable {
	func toJson() -> [String: AnyObject]
	static func fromJson(json: [String: AnyObject]) -> Self?
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
			config.sendDelay = sendDelay
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
		return config
	}
}

extension ActionTrackingParameter: Backupable {
	internal func toJson() -> [String : AnyObject] {
		var items = [String: AnyObject]()
		if let ecommerceParameter = ecommerceParameter {
			items["ecommerceParameter"] = ecommerceParameter.toJson()
		}
		items["generalParameter"] = generalParameter.toJson()
		items["pixelParameter"] = pixelParameter.toJson()
		items["productParameters"] = productParameters.map({$0.toJson()})
		items["actionParameter"] = actionParameter.toJson()
		return items
	}

	internal static func fromJson(json: [String: AnyObject]) -> ActionTrackingParameter? {
		guard let actionParameterJson = json["actionParameter"] as? [String: AnyObject], let actionParameter = ActionParameter.fromJson(actionParameterJson) else {
			return nil
		}
		var parameter = ActionTrackingParameter(actionParameter: actionParameter)

		guard let pixelParameterJson = json["pixelParameter"] as? [String: AnyObject], let pixelParameter = PixelParameter.fromJson(pixelParameterJson) else {
			return nil
		}
		parameter.pixelParameter = pixelParameter

		guard let generalParameterJson = json["generalParameter"] as? [String: AnyObject], let generalParameter = GeneralParameter.fromJson(generalParameterJson) else {
			return nil
		}
		parameter.generalParameter = generalParameter

		if let productParametersJson = json["productParameters"] as? [[String: AnyObject]] {
			parameter.productParameters = productParametersJson.map({ProductParameter.fromJson($0)!})
		}

		return parameter
	}
}

extension PageTrackingParameter: Backupable {
	internal func toJson() -> [String : AnyObject] {
		var items = [String: AnyObject]()
		if let ecommerceParameter = ecommerceParameter {
			items["ecommerceParameter"] = ecommerceParameter.toJson()
		}
		items["generalParameter"] = generalParameter.toJson()
		items["pixelParameter"] = pixelParameter.toJson()
		items["productParameters"] = productParameters.map({$0.toJson()})
		items["pageParameter"] = pageParameter.toJson()
		return items
	}


	internal static func fromJson(json: [String: AnyObject]) -> PageTrackingParameter? {
		guard let pageParameterJson = json["pageParameter"] as? [String: AnyObject], let pageParameter = PageParameter.fromJson(pageParameterJson) else {
			return nil
		}
		var parameter = PageTrackingParameter(pageParameter: pageParameter)

		guard let pixelParameterJson = json["pixelParameter"] as? [String: AnyObject], let pixelParameter = PixelParameter.fromJson(pixelParameterJson) else {
			return nil
		}
		parameter.pixelParameter = pixelParameter

		guard let generalParameterJson = json["generalParameter"] as? [String: AnyObject], let generalParameter = GeneralParameter.fromJson(generalParameterJson) else {
			return nil
		}
		parameter.generalParameter = generalParameter

		if let productParametersJson = json["productParameters"] as? [[String: AnyObject]] {
			parameter.productParameters = productParametersJson.map({ProductParameter.fromJson($0)!})
		}

		return parameter
	}
}

extension EcommerceParameter: Backupable {
	internal func toJson() -> [String : AnyObject] {
		var items = [String: AnyObject]()
		items["currency"] = currency
		items["categories"] = categories.map({["index":$0.0, "value": $0.1]})
		items["orderNumber"] = currency
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
		if let detailsDic = json["categories"] as? [[String: AnyObject]] {
			for item in detailsDic {
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
		items["timeStamp"] = "\(timeStamp)"
		items["timeZoneOffset"] = timeZoneOffset
		items["userAgent"] = userAgent
		return items
	}

	internal static func fromJson(json: [String: AnyObject]) -> GeneralParameter? {
		guard let everId = json["everId"] as? String, let timeStampValue = json["timeStamp"] as? String, let timeStamp = Int64(timeStampValue), let timeZoneOffset = json["timeZoneOffset"] as? Double, let userAgent = json["userAgent"] as? String else {
			return nil
		}
		var parameter = GeneralParameter(everId: everId, timeStamp: timeStamp, timeZoneOffset: timeZoneOffset, userAgent: userAgent)
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
		items["timeStamp"] = "\(timeStamp)"
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
		if let timeStampValue = json["timeStamp"] as? String, let timeStamp = Int64(timeStampValue) {
			parameter.timeStamp = timeStamp
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