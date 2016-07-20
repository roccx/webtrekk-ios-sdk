import Foundation


@objc(Webtrekk_ASIdentifierManager)
internal class ASIdentifierManager: NSObject {

	@objc
	internal dynamic var advertisingIdentifier: NSUUID? { return nil }


	@objc(isAdvertisingTrackingEnabled)
	internal dynamic var advertisingTrackingEnabled: Bool { return false }


	@objc
	internal dynamic class func sharedManager() -> ASIdentifierManager? {
		return nil
	}
}
