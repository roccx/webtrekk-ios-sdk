import Foundation

import ReachabilitySwift

internal struct Event {
	var pixel: PixelParameter
	var general: GeneralParameter

	var action: ActionParameter?
	var media: MediaParameter?
	var page: PageParameter?

	var custom = [String: String]()
	var customer: CustomerParameter?
	var ecommerce: EcommerceParameter?
	var products = [ProductParameter]()

	var autoTracking = [String: String]()
	var crossDevice = [String: String]()
	var baseUrl: NSURL?


	internal init(trackingParameter: TrackingParameter) {
		self.pixel = trackingParameter.pixelParameter
		self.general = trackingParameter.generalParameter
		self.action = trackingParameter.actionParameter
		self.page = trackingParameter.pageParameter
		self.media = trackingParameter.mediaParameter
		self.custom = trackingParameter.customParameters
		self.customer = trackingParameter.customerParameter
		self.ecommerce = trackingParameter.ecommerceParameter
		self.products = trackingParameter.productParameters
	}


	internal mutating func parse(config: TrackerConfiguration, advertisingIdentifier: String?, itemCount: Int)  {
		baseUrl = config.baseUrl
		if config.autoTrack {
			if config.autoTrackAdvertiserId, let advertisingIdentifier = advertisingIdentifier {
				autoTracking["\(ParameterName.AdvertiserId.rawValue)"] = advertisingIdentifier
			}

			if config.autoTrackConnectionType, let reachability = try? Reachability.reachabilityForInternetConnection() {
				autoTracking["\(ParameterName.ConnectionType)"] = reachability.isReachableViaWiFi() ? "0" : "1"
			}

			if config.autoTrackRequestUrlStoreSize {
				autoTracking["\(ParameterName.RequestUrlStoreSize)"] = "\(itemCount)"
			}

			if config.autoTrackAppVersionName {
				if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
					autoTracking["\(ParameterName.AppVersionName)"] = config.appVersion.isEmpty ? version : config.appVersion
				}
			}

			if config.autoTrackAppVersionCode {
				if let version = NSBundle.mainBundle().infoDictionary?[kCFBundleVersionKey as String] as? String {
					autoTracking["\(ParameterName.AppVersionCode)"] = version
				}
			}

			if config.autoTrackScreenOrientation {
				autoTracking["\(ParameterName.ScreenOrientation)"] = UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) ? "1" : "0"
			}

			if config.autoTrackAppUpdate {
				var appVersion: String
				if !config.appVersion.isEmpty {
					appVersion = config.appVersion
				} else if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
					appVersion = version
				}else {
					appVersion = ""
				}

				let userDefaults = NSUserDefaults.standardUserDefaults()
				if let version = userDefaults.stringForKey(UserStoreKey.VersionNumber) {
					if version != appVersion {
						userDefaults.setValue(appVersion, forKey:UserStoreKey.VersionNumber.rawValue)
						autoTracking["\(ParameterName.AppUpdate)"] = "1"
					}
				} else {
					userDefaults.setValue(appVersion, forKey:UserStoreKey.VersionNumber.rawValue)
				}
			}
		}
	}
}