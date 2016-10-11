import UIKit


internal extension UIDevice {

	@nonobjc
	internal var isSimulator: Bool {
		return TARGET_OS_SIMULATOR != 0
	}


	@nonobjc
	internal var modelIdentifier: String {
		var systemInfo = utsname()
		uname(&systemInfo)

		let machineMirror = Mirror(reflecting: systemInfo.machine)
		let identifier = machineMirror.children.reduce("") { identifier, element in
			guard let value = element.value as? Int8 , value != 0 else { return identifier }
			return identifier + String(UnicodeScalar(UInt8(value)))
		}

		return identifier
	}
}
