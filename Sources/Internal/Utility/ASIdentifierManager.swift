import Foundation


internal class ASIdentifierManager: NSObject {

	@objc
	internal var advertisingIdentifier: NSUUID? { return nil }


	@objc
	internal dynamic var advertisingTrackingEnabled: Bool { return false }


	@objc
	internal dynamic class func sharedManager() -> ASIdentifierManager? {
		return nil
	}


	private override init() {
		super.init()
	}
}
