import Foundation


internal class ASIdentifierManager: NSObject {

	@objc
	internal var advertisingIdentifier: NSUUID? { fatalError() }


	@objc
	internal dynamic var advertisingTrackingEnabled: Bool { fatalError() }


	@objc
	internal dynamic class func sharedManager() -> ASIdentifierManager? {
		fatalError()
	}


	private override init() {
		super.init()
	}
}
