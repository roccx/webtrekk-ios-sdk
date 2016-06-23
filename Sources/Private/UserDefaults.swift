import Foundation


internal final class UserDefaults {

	internal static let standardDefaults = UserDefaults(source: NSUserDefaults.standardUserDefaults(), keyPrefix: "")

	private let keyPrefix: String
	private let source: NSUserDefaults


	private init(source: NSUserDefaults, keyPrefix: String) {
		self.keyPrefix = keyPrefix
		self.source = source
	}


	internal func boolForKey(key: String) -> Bool? {
		return objectForKey(key) as? Bool
	}


	internal func child(namespace namespace: String) -> UserDefaults {
		return UserDefaults(source: source, keyPrefix: "\(keyPrefix)\(namespace).")
	}


	internal func intForKey(key: String) -> Int? {
		return objectForKey(key) as? Int
	}


	internal func objectForKey(key: String) -> AnyObject? {
		return source.objectForKey(keyPrefix + key)
	}


	internal func remove(key key: String) {
		source.removeObjectForKey(keyPrefix + key)
	}


	internal func stringForKey(key: String) -> String? {
		return objectForKey(key) as? String
	}


	private func set(key key: String, to value: AnyObject?) {
		source.setObject(value, forKey: keyPrefix + key)
	}


	internal func set(key key: String, to value: Bool?) {
		set(key: key, to: value as AnyObject?)
	}


	internal func set(key key: String, to value: Int?) {
		set(key: key, to: value as AnyObject?)
	}


	internal func set(key key: String, to value: String?) {
		set(key: key, to: value as AnyObject?)
	}
}
