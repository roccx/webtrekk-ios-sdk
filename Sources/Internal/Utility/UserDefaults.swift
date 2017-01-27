import Foundation


internal final class UserDefaults {

	internal static let standardDefaults = UserDefaults(source: Foundation.UserDefaults.standard, keyPrefix: "")

	fileprivate let keyPrefix: String
	fileprivate let source: Foundation.UserDefaults


	fileprivate init(source: Foundation.UserDefaults, keyPrefix: String) {
		self.keyPrefix = keyPrefix
		self.source = source
	}


	internal func boolForKey(_ key: String) -> Bool? {
		return objectForKey(key) as? Bool
	}


	internal func child(namespace: String) -> UserDefaults {
		return UserDefaults(source: source, keyPrefix: "\(keyPrefix)\(namespace).")
	}


	internal func dataForKey(_ key: String) -> Data? {
		return objectForKey(key) as? Data
	}


	internal func dateForKey(_ key: String) -> Date? {
		return objectForKey(key) as? Date
	}


	internal func intForKey(_ key: String) -> Int? {
		return objectForKey(key) as? Int
	}
    
	internal func objectForKey(_ key: String) -> AnyObject? {
		return source.object(forKey: keyPrefix + key) as AnyObject?
	}

    internal func uInt64ForKey(_ key: String) -> UInt64? {
        return objectForKey(key) as? UInt64
    }


	internal func remove(key: String) {
		source.removeObject(forKey: keyPrefix + key)
	}


	internal func stringForKey(_ key: String) -> String? {
		return objectForKey(key) as? String
	}


	private func set(key: String, to value: AnyObject?) {
		source.set(value, forKey: keyPrefix + key)
	}


	internal func set(key: String, to value: Bool?) {
		set(key: key, to: value as AnyObject?)
	}


	internal func set(key: String, to value: Data?) {
		set(key: key, to: value as AnyObject?)
	}


	internal func set(key: String, to value: Date?) {
		set(key: key, to: value as AnyObject?)
	}


	internal func set(key: String, to value: Int?) {
		set(key: key, to: value as AnyObject?)
	}


	internal func set(key: String, to value: String?) {
		set(key: key, to: value as AnyObject?)
	}
    
    internal func set(key: String, to value: UInt64?) {
        set(key: key, to: value as AnyObject?)
    }
}
