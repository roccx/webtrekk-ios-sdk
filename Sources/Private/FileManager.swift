import Foundation


internal struct FileManager : Logable {

	internal var logger: Logger
	private let fileDirectoryUrl: NSURL

	internal init(_ logger: Logger) {
		self.logger = logger
		#if os(iOS)
			fileDirectoryUrl = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .AllDomainsMask, appropriateForURL: nil, create: true)
		#else
			fileDirectoryUrl = try! NSFileManager.defaultManager().URLForDirectory(.CachesDirectory, inDomain: .AllDomainsMask, appropriateForURL: nil, create: true)
		#endif
	}





	internal func getConfigurationDirectoryUrl(forTrackingId id: String) -> NSURL{
		let directory = fileDirectoryUrl.URLByAppendingPathComponent(id)
		if !NSFileManager.defaultManager().fileExistsAtPath(directory.path!) {
			do {
				try NSFileManager.defaultManager().createDirectoryAtURL(directory, withIntermediateDirectories: true, attributes: nil)
			}
			catch let error {
				logE("Cannot create directory '\(directory)': \(error)")
				return fileDirectoryUrl
			}
		}
		return directory
	}


	internal func saveConfiguration(config: TrackerConfiguration) {
		guard let data = try? NSJSONSerialization.dataWithJSONObject(config.toJson(), options: NSJSONWritingOptions()) else {
			logE("Could not prepare config for saving to file.")
			return
		}
		guard let _ = try? data.writeToURL(getConfigurationDirectoryUrl(forTrackingId: config.trackingId).URLByAppendingPathComponent("config.json"), options: .DataWritingAtomic) else {
			logE("Writing config to file failed.")
			return
		}
	}


	internal func restoreConfiguration(trackingId: String) -> TrackerConfiguration? {
		guard let data = NSData(contentsOfURL: getConfigurationDirectoryUrl(forTrackingId: trackingId).URLByAppendingPathComponent("config.json")) else {
			logE("Couldn't find a config for this trackingId.")
			return nil
		}
		guard let conf = (try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String : AnyObject])!, let config = TrackerConfiguration.fromJson(conf) else {
			logE("Couldn't read stored config for this trackingId.")
			return nil
		}
		return config
	}


	internal func saveData(toFileUrl fileUrl: NSURL, data: NSData) {
		guard let url: NSURL = fileUrl.URLByDeletingLastPathComponent! else {
			logE("\(fileUrl) is not a valid url to save data to.")
			return
		}

		if !NSFileManager.defaultManager().fileExistsAtPath(url.path!) {
			do {
				try NSFileManager.defaultManager().createDirectoryAtURL(url, withIntermediateDirectories: false, attributes: nil)
			}
			catch let error {
				logE("Cannot create directory '\(url)': \(error)")
				return
			}
		}
		guard let _ = try? data.writeToURL(fileUrl, options: .DataWritingAtomic) else {
			logE("Writing data to file at \(fileUrl) failed.")
			return
		}
	}


	internal func restoreData(fromFileUrl fileUrl: NSURL) -> NSData? {
		guard NSFileManager.defaultManager().fileExistsAtPath(fileUrl.path!) else {
			return nil
		}
		guard let data: NSData = NSData(contentsOfURL: fileUrl) else {
			logE("Couldn't find a data at \(fileUrl) for restoring data.")
			return nil
		}
		return data
	}
}