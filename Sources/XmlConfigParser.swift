import Foundation
import SWXMLHash

public final class XmlConfigParser: ConfigParser {

	public var trackerConfiguration: TrackerConfiguration? {
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

	public init(xmlString: String) throws {
		guard !xmlString.isEmpty else {
			throw XmlError.CanNotBeEmpty
		}
		self.xml = SWXMLHash.parse(xmlString)
	}

	private func parse(inout dictionary: [Int: String], fromParameters parameters: XMLIndexer) {
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
			dictionary[index] = value
		}
	}

	public func parseTrackerConfig() throws -> TrackerConfiguration {
		guard xml[.Root].boolValue else {
			throw XmlError.NoRoot
		}
		guard xml[.Root][.TrackingDomain].boolValue && xml[.Root][.TrackId].boolValue, let serverUrl = xml[.Root][.TrackingDomain].element?.text, let trackingId = xml[.Root][.TrackId].element?.text else {
			throw XmlError.MissingDomainOrId
		}
		var config = TrackerConfiguration(serverUrl: serverUrl, trackingId: trackingId)

		if xml[.Root][.MaxRequests].boolValue, let maxRequests = Int((xml[.Root][.MaxRequests].element?.text)!) {
			config.maxRequests = maxRequests
		}
		if xml[.Root][.Sampling].boolValue, let Sampling = Int((xml[.Root][.Sampling].element?.text)!) {
			config.samplingRate = Sampling
		}
		if xml[.Root][.SendDelay].boolValue, let sendDelay = Int((xml[.Root][.SendDelay].element?.text)!) {
			config.sendDelay = sendDelay
		}
		if xml[.Root][.Version].boolValue, let version = Int((xml[.Root][.Version].element?.text)!) {
			config.version = version
		}

		if xml[.Root][.EnableRemoteConfiguration].boolValue {
			config.enableRemoteConfiguration = Bool((xml[.Root][.EnableRemoteConfiguration].element?.text)!.lowercaseString == "true")
		}
		if xml[.Root][.TrackingConfigurationUrl].boolValue, let remoteConfigurationUrl = xml[.Root][.TrackingConfigurationUrl].element?.text {
			config.remoteConfigurationUrl = remoteConfigurationUrl
		}

		if xml[.Root][.AutoTracked].boolValue {
			config.autoTrack = Bool((xml[.Root][.AutoTracked].element?.text)!.lowercaseString == "true")
		}

		guard config.autoTrack else {
			return config
		}

		if xml[.Root][.AutoTrackAppUpdate].boolValue {
			config.autoTrackAppUpdate = Bool((xml[.Root][.AutoTrackAppUpdate].element?.text)!.lowercaseString == "true")
		}
		if xml[.Root][.AutoTrackAppVersionName].boolValue {
			config.autoTrackAppVersionName = Bool((xml[.Root][.AutoTrackAppVersionName].element?.text)!.lowercaseString == "true")
		}
		if xml[.Root][.AutoTrackAppVersionCode].boolValue {
			config.autoTrackAppVersionCode = Bool((xml[.Root][.AutoTrackAppVersionCode].element?.text)!.lowercaseString == "true")
		}
		if xml[.Root][.AutoTrackApiLevel].boolValue {
			config.autoTrackApiLevel = Bool((xml[.Root][.AutoTrackApiLevel].element?.text)!.lowercaseString == "true")
		}
		if xml[.Root][.AutoTrackScreenOrientation].boolValue {
			config.autoTrackScreenOrientation = Bool((xml[.Root][.AutoTrackScreenOrientation].element?.text)!.lowercaseString == "true")
		}
		if xml[.Root][.AutoTrackConnectionType].boolValue {
			config.autoTrackConnectionType = Bool((xml[.Root][.AutoTrackConnectionType].element?.text)!.lowercaseString == "true")
		}
		if xml[.Root][.AutoTrackRequestUrlStoreSize].boolValue {
			config.autoTrackRequestUrlStoreSize = Bool((xml[.Root][.AutoTrackRequestUrlStoreSize].element?.text)!.lowercaseString == "true")
		}
		if xml[.Root][.AutoTrackAdvertiserId].boolValue {
			config.autoTrackAdvertiserId = Bool((xml[.Root][.AutoTrackAdvertiserId].element?.text)!.lowercaseString == "true")
		}

		if xml[.Root][.Screens].boolValue {
			let screens = xml[.Root][.Screens].children
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
				var autoScreen = AutoTrackedScreen(className: className, mappingName: mappingName)
				if screen[.AutoTracked].boolValue {
					autoScreen.enabled = Bool((screen[.AutoTracked].element?.text)!.lowercaseString == "true")
				}
				if screen[.AutoTracked].boolValue {
					autoScreen.enabled = Bool((screen[.AutoTracked].element?.text)!.lowercaseString == "true")
				}
				guard screen[.TrackingParameter].boolValue else {
					config.autoTrackScreens[className] = autoScreen
					continue
				}

				let trackingParameter: XMLIndexer = screen[.TrackingParameter]
				var pageTracking = PageTrackingParameter(pageName: mappingName)
				if trackingParameter[.CustomParameters].boolValue {
					let customParameters = trackingParameter[.CustomParameters]
					for parameter in customParameters.children {
						guard let index = parameter.element?.attributes["id"] else {
							continue
						}
						guard let value = parameter.element?.text?.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet()) else {
							continue
						}
						pageTracking.customParameters[index] = value
					}
				}

				if trackingParameter[.PageParameter].boolValue {
					parse(&pageTracking.pageParameter!.categories, fromParameters: trackingParameter[.PageParameter][.Categories])
					parse(&pageTracking.pageParameter!.page, fromParameters: trackingParameter[.PageParameter][.Page])
					parse(&pageTracking.pageParameter!.session, fromParameters: trackingParameter[.PageParameter][.Session])
				}
				autoScreen.pageTrackingParameter = pageTracking
				config.autoTrackScreens[className] = autoScreen
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

public enum XmlError: ErrorType {
	case CanNotBeEmpty
	case MissingDomainOrId
	case NoRoot
}