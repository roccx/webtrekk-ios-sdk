import Foundation
import UIKit

#if os(watchOS)
	import WatchKit
#endif


internal struct Environment {

	internal static var advertisingIdentifierManager: ASIdentifierManager? = {
		let selector = #selector(ASIdentifierManager.sharedManager)

		guard let identifierManagerClass = NSClassFromString("ASIdentifierManager") as? NSObjectProtocol , identifierManagerClass.responds(to: selector) else {
			return nil
		}

		let sharedManager = identifierManagerClass.perform(selector).takeUnretainedValue()
		return unsafeBitCast(sharedManager, to: ASIdentifierManager.self)
	}()


	internal static let appVersion: String? = {
		return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
	}()


	internal static let deviceModelString: String = {
		#if os(watchOS)
			return WKInterfaceDevice.currentDevice().model
		#else
			let device = UIDevice.current
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
		let version = ProcessInfo().operatingSystemVersion
		if version.patchVersion == 0 {
			return "\(version.majorVersion).\(version.minorVersion)"
		}
		else {
			return "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
		}
	}()
}
