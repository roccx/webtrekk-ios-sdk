import Foundation

internal enum UserStoreKey: String {

	// MARK: Bools

	case FirstStart = "wtk_firstStart"
	case OptedOut = "wtk_optedOut"
	case Sampled = "wtk_sampled"

	// MARK: Strings

	case Eid = "wtk_eid"
	case VersionNumber = "wtk_versionNumber"

}

extension NSUserDefaults {

	internal func boolForKey(defaultName: UserStoreKey) -> Bool {
		return self.boolForKey(defaultName.rawValue)
	}


	internal func objectForKey(defaultName: UserStoreKey) -> AnyObject? {
		return objectForKey(defaultName.rawValue)
	}


	internal func setBool(value: Bool, forKey key: UserStoreKey) {
		self.setBool(value, forKey: key.rawValue)
	}


	internal func stringForKey(defaultName: UserStoreKey) -> String? {
		return self.stringForKey(defaultName.rawValue)
	}
}