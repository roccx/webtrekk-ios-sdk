import Foundation


internal struct Migration {

	internal let appVersion: String?
	internal let everId: String
	internal let isOptedOut: Bool?
	internal let isSampling: Bool?
	internal let requestQueue: [NSURL]?
	internal let samplingRate: Int?


	internal static func migrateFromLibraryV3(webtrekkId webtrekkId: String) -> Migration? {
		#if os(iOS)
			let fileManager = NSFileManager.defaultManager()
			let userDefaults = NSUserDefaults.standardUserDefaults()

			let cachesDirectory = try? fileManager.URLForDirectory(.CachesDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
			let documentDirectory = try? fileManager.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)
			let libraryDirectory = try? fileManager.URLForDirectory(.LibraryDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: false)

			let everIdFileV2 = documentDirectory?.URLByAppendingPathComponent("webtrekk-id")
			let everIdFileV3 = libraryDirectory?.URLByAppendingPathComponent("webtrekk-id")

			let requestQueueFileV2 = cachesDirectory?.URLByAppendingPathComponent("webtrekk-\(webtrekkId)")
			let requestQueueFileV3 = cachesDirectory?.URLByAppendingPathComponent("webtrekk-queue")

			let samplingFileV2 = documentDirectory?.URLByAppendingPathComponent("webtrekk-sampling")
			let samplingFileV3 = libraryDirectory?.URLByAppendingPathComponent("webtrekk-sampling")

			let appVersionFileV2 = documentDirectory?.URLByAppendingPathComponent("webtrekk-app-version")
			let appVersionFileV3 = libraryDirectory?.URLByAppendingPathComponent("webtrekk-app-version")


			defer {
				let files = [everIdFileV2, everIdFileV3, requestQueueFileV2, requestQueueFileV3, samplingFileV2, samplingFileV3, appVersionFileV2, appVersionFileV3].filterNonNil()
				for file in files where fileManager.itemExistsAtURL(file) {
					do {
						try fileManager.removeItemAtURL(file)
					}
					catch let error {
						logWarning("Cannot remove \(file) of previous Webtrekk Library version: \(error)")
					}
				}

				userDefaults.removeObjectForKey("Webtrekk.optedOut")
			}


			let everId: String
			if let file = everIdFileV3, _everId = (try? String(contentsOfURL: file, encoding: NSUTF8StringEncoding))?.nonEmpty {
				everId = _everId
			}
			else if let file = everIdFileV2, _everId = (try? String(contentsOfURL: file, encoding: NSUTF8StringEncoding))?.nonEmpty {
				everId = _everId
			}
			else {
				return nil
			}


			let requestQueue: [NSURL]?
			if let file = requestQueueFileV3, _requestQueue = NSKeyedUnarchiver.unarchive(file: file) as? [String] {
				requestQueue = _requestQueue.map({ NSURL(string: $0) }).filterNonNil()
			}
			else if let file = requestQueueFileV2, _requestQueue = NSKeyedUnarchiver.unarchive(file: file) as? [String] {
				requestQueue = _requestQueue.map({ NSURL(string: $0) }).filterNonNil()
			}
			else {
				requestQueue = nil
			}

			let isSampling: Bool?
			let samplingRate: Int?
			if let file = samplingFileV3, string = try? String(contentsOfURL: file, encoding: NSUTF8StringEncoding), (_isSampling, _samplingRate) = parseSampling(string) {
				isSampling = _isSampling
				samplingRate = _samplingRate
			}
			else if let file = samplingFileV2, string = try? String(contentsOfURL: file, encoding: NSUTF8StringEncoding), (_isSampling, _samplingRate) = parseSampling(string) {
				isSampling = _isSampling
				samplingRate = _samplingRate
			}
			else {
				isSampling = nil
				samplingRate = nil
			}

			let appVersion: String?
			if let file = appVersionFileV3, _appVersion = (try? String(contentsOfURL: file, encoding: NSUTF8StringEncoding))?.nonEmpty {
				appVersion = _appVersion
			}
			else if let file = appVersionFileV2, _appVersion = (try? String(contentsOfURL: file, encoding: NSUTF8StringEncoding))?.nonEmpty {
				appVersion = _appVersion
			}
			else {
				appVersion = nil
			}

			let isOptedOut = userDefaults.objectForKey("Webtrekk.optedOut") as? Bool

			return Migration(
				appVersion:   appVersion,
				everId:       everId,
				isOptedOut:   isOptedOut,
				isSampling:   isSampling,
				requestQueue: requestQueue,
				samplingRate: samplingRate
			)
		#else
			return nil
		#endif
	}


	private static func parseSampling(string: String) -> (isSampling: Bool, samplingRate: Int)? {
		let components = string.componentsSeparatedByString("|")
		guard components.count == 2 else {
			return nil
		}
		guard let isSampling = Int(components[0]), samplingRate = Int(components[1]) where isSampling == 1 || isSampling == 0 else {
			return nil
		}

		return (isSampling: isSampling == 1, samplingRate: samplingRate)
	}
}


extension Migration: CustomStringConvertible {

	internal var description: String {
		return "Migration(\n"
			+ "\teverId: \(everId.simpleDescription)\n"
			+ "\tappVersion: \(appVersion.simpleDescription)\n"
			+ "\tisOptedOut: \(isOptedOut.simpleDescription)\n"
			+ "\tisSampling: \(isSampling.simpleDescription)\n"
			+ "\trequestQueueSize: \((requestQueue?.count).simpleDescription)\n"
			+ "\tsamplingRate: \(samplingRate.simpleDescription)\n"
			+ ")"
	}
}



private extension NSKeyedUnarchiver {

	private static func unarchive(file file: NSURL) -> AnyObject? {
		guard let data = NSData(contentsOfURL: file) else {
			return nil
		}

		if #available(iOS 9.0, *) {
			return (try? unarchiveTopLevelObjectWithData(data)) ?? nil
		}
		else {
			return unarchiveObjectWithData(data)
		}
	}
}
