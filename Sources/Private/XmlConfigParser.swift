import Foundation
import SWXMLHash

internal final class XmlConfigParser {

	internal var trackerConfiguration: TrackerConfiguration? {
		get {
			do {
				let config = try parseTrackerConfig()
				return config
			} catch XmlError.NoRoot {

			} catch XmlError.MissingDomainOrId {

			} catch {

			}
			return nil
		}
	}

	let xml: XMLIndexer

	internal init(xmlString: String) throws {
		guard !xmlString.isEmpty else {
			throw XmlError.CanNotBeEmpty
		}
		self.xml = SWXMLHash.parse(xmlString)
	}

	private func parse(dictionary: [Int: String]?, fromParameters parameters: XMLIndexer) -> [Int: String]{
		var dic = dictionary ?? [Int: String]()
		for parameter in parameters.children {
			guard let indexString = parameter.element?.attributes["id"] else {
				continue
			}
			guard let index = Int(indexString) else {
				continue
			}
			guard let value = parameter.element?.text?.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()) else {
				continue
			}
			dic[index] = value
		}
		return dic
	}

	internal func parseTrackerConfig() throws -> TrackerConfiguration {
		guard xml[.Root].boolValue else {
			throw XmlError.NoRoot
		}

		let root = xml[.Root]

		guard root[.TrackingDomain].boolValue && root[.TrackId].boolValue, let serverUrl = root[.TrackingDomain].element?.text, trackingId = root[.TrackId].element?.text else {
			throw XmlError.MissingDomainOrId
		}
		var config = TrackerConfiguration(serverUrl: serverUrl, trackingId: trackingId)

		if root[.MaxRequests].boolValue, let text = root[.MaxRequests].element?.text, maxRequests = Int(text) {
			config.maxRequests = maxRequests
		}
		if root[.Sampling].boolValue, let text = root[.Sampling].element?.text,  sampling = Int(text) {
			config.samplingRate = sampling
		}
		if root[.SendDelay].boolValue, let text = root[.SendDelay].element?.text, sendDelay = Int(text) {
			config.sendDelay = NSTimeInterval(sendDelay)
		}
		if root[.Version].boolValue, let text = root[.Version].element?.text, version = Int(text) {
			config.version = version
		}

		if root[.EnableRemoteConfiguration].boolValue, let text = root[.EnableRemoteConfiguration].element?.text {
			config.enableRemoteConfiguration = Bool(text.lowercaseString == "true")
		}
		if root[.TrackingConfigurationUrl].boolValue, let remoteConfigurationUrl = root[.TrackingConfigurationUrl].element?.text {
			config.remoteConfigurationUrl = remoteConfigurationUrl
		}

		if root[.AutoTracked].boolValue, let text = root[.AutoTracked].element?.text {
			config.autoTrack = Bool(text.lowercaseString == "true")
		}

		guard config.autoTrack else {
			return config
		}

		if root[.AutoTrackAppUpdate].boolValue, let text = root[.AutoTrackAppUpdate].element?.text {
			config.autoTrackAppUpdate = Bool(text.lowercaseString == "true")
		}
		if root[.AutoTrackAppVersionName].boolValue, let text = root[.AutoTrackAppVersionName].element?.text {
			config.autoTrackAppVersionName = Bool(text.lowercaseString == "true")
		}
		if root[.AutoTrackAppVersionCode].boolValue, let text = root[.AutoTrackAppVersionCode].element?.text {
			config.autoTrackAppVersionCode = Bool(text.lowercaseString == "true")
		}
		if root[.AutoTrackApiLevel].boolValue, let text = root[.AutoTrackApiLevel].element?.text {
			config.autoTrackApiLevel = Bool(text.lowercaseString == "true")
		}
		if root[.AutoTrackScreenOrientation].boolValue, let text = root[.AutoTrackScreenOrientation].element?.text {
			config.autoTrackScreenOrientation = Bool(text.lowercaseString == "true")
		}
		if root[.AutoTrackConnectionType].boolValue, let text = root[.AutoTrackConnectionType].element?.text {
			config.autoTrackConnectionType = Bool(text.lowercaseString == "true")
		}
		if root[.AutoTrackRequestUrlStoreSize].boolValue, let text = root[.AutoTrackRequestUrlStoreSize].element?.text {
			config.autoTrackRequestUrlStoreSize = Bool(text.lowercaseString == "true")
		}
		if root[.AutoTrackAdvertiserId].boolValue, let text = root[.AutoTrackAdvertiserId].element?.text {
			config.autoTrackAdvertiserId = Bool(text.lowercaseString == "true")
		}

		if root[.Screens].boolValue {
			let screens = root[.Screens].children
			for screen in screens {
				guard let className = screen[.ClassName].element?.text else {
					continue
				}
				let mappingName: String
				if screen[.MappingName].boolValue, let name = screen[.MappingName].element?.text {
					mappingName = name
				}
				else {
					mappingName = className
				}
//				var autoScreen = AutoTrackedScreen(className: className, mappingName: mappingName)
//				if screen[.AutoTracked].boolValue, let text = screen[.AutoTracked].element?.text {
//					autoScreen.enabled = Bool(text.lowercaseString == "true")
//				}
//				guard screen[.TrackingParameter].boolValue else {
//					config.autoTrackScreens[className] = autoScreen
//					continue
//				}

				let trackingParameter: XMLIndexer = screen[.TrackingParameter]
//				var pageTracking = PageTracking(pageName: mappingName)
//				if trackingParameter[.CustomParameters].boolValue {
//					let customParameters = trackingParameter[.CustomParameters]
//					for parameter in customParameters.children {
//						guard let index = parameter.element?.attributes["id"] else {
//							continue
//						}
//						guard let value = parameter.element?.text?.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()) else {
//							continue
//						}
//						pageTracking.customParameters[index] = value
//					}
//				}

//				if trackingParameter[.PageParameter].boolValue, let _ = pageTracking.pageParameter {
//					pageTracking.pageParameter?.categories = parse(pageTracking.pageParameter?.categories, fromParameters: trackingParameter[.PageParameter][.Categories])
//					pageTracking.pageParameter?.page = parse(pageTracking.pageParameter?.page, fromParameters: trackingParameter[.PageParameter][.Page])
//					pageTracking.pageParameter?.session = parse(pageTracking.pageParameter?.session, fromParameters: trackingParameter[.PageParameter][.Session])
//				}
//				autoScreen.pageTracking = pageTracking
//				config.autoTrackScreens[className] = autoScreen
			}
		}

		return config
	}
}

internal enum XmlConfigParameter: String {
	case Root = "webtrekkConfiguration"

	// MARK: required parameters
	case TrackingDomain = "trackDomain"
	case TrackId = "trackId"

	// MARK: default parameters
	case MaxRequests = "maxRequests"
	case Sampling = "Sampling"
	case SendDelay = "sendDelay"
	case Version = "version"

	// MARK: auto parameters
	case AutoTracked = "autoTracked"
	case AutoTrackAppUpdate = "autoTrackAppUpdate"
	case AutoTrackAppVersionName = "autoTrackAppversionName"
	case AutoTrackAppVersionCode = "autoTrackAppversionCode"
	case AutoTrackApiLevel = "autoTrackApiLevel"
	case AutoTrackScreenOrientation = "autoTrackScreenOrientation"
	case AutoTrackConnectionType = "autoTrackConnectionType"
	case AutoTrackRequestUrlStoreSize = "autoTrackRequestUrlStoreSize"

	// MARK: advertiser id
	case AutoTrackAdvertiserId = "autoTrackAdvertiserId"

	// MARK: remote configuration parameter
	case EnableRemoteConfiguration = "enableRemoteConfiguration"
	case TrackingConfigurationUrl = "trackingConfigurationUrl"

	// MARK: screen configuration
	case ClassName = "className"
	case MappingName = "mappingName"
	case Screens = "screens"
	case TrackingParameter = "trackingParameter"
	case CustomParameters = "customParameters"
	case PageParameter = "pageParameter"
	case Categories = "categories"
	case Page = "page"
	case Session = "session"
	case EcommerceParameter = "ecommerceParameter"

}

internal extension XMLIndexer {

	internal subscript(key: XmlConfigParameter) -> XMLIndexer {
		do {
			return try self.byKey(key.rawValue)
		} catch let error as Error {
			return .XMLError(error)
		} catch {
			return .XMLError(.Key(key: key.rawValue))
		}
	}
}

internal enum XmlError: ErrorType {
	case CanNotBeEmpty
	case MissingDomainOrId
	case NoRoot
}