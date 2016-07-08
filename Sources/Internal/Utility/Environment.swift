import Foundation
import UIKit

#if os(watchOS)
	import WatchKit
#endif


internal struct Environment {

	internal static let appVersion: String? = {
		guard let shortVersion = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String, version = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String else {
			return nil
		}
		return "\(shortVersion).\(version)"
	}()


	internal static let deviceModelString: String = {
		#if os(watchOS)
			return WKInterfaceDevice.currentDevice().model
		#else
			let device = UIDevice.currentDevice()
			if device.isSimulator {
				return "\(operatingSystemName) Simulator"
			}
			else {
				return device.modelIdentifier
			}
		#endif
	}()


	internal static let operatingSystemName: String = {
		#if os(iOS)
			return "iOS"
		#elseif os(watchOS)
			return "watchOS"
		#elseif os(tvOS)
			return "tvOS"
		#elseif os(OSX)
			return "macOS"
		#endif
	}()


	internal static let operatingSystemVersionString: String = {
		let version = NSProcessInfo().operatingSystemVersion
		if version.patchVersion == 0 {
			return "\(version.majorVersion).\(version.minorVersion)"
		}
		else {
			return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
		}
	}()
}
