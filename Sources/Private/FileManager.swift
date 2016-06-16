import Foundation


internal struct FileManager : Logable {

	var loger: Loger

	internal init(_ loger: Loger) {
		self.loger = loger
	}

	private let documentsDirectory = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)

	internal func getConfigurationDirectoryUrl(forTrackingId id: String) -> NSURL{
		let directory = documentsDirectory.URLByAppendingPathComponent(id)
		if !NSFileManager.defaultManager().fileExistsAtPath(directory.path!) {
			do {
				try NSFileManager.defaultManager().createDirectoryAtURL(directory, withIntermediateDirectories: true, attributes: nil)
			}
			catch let error {
				log("Cannot create directory '\(directory)': \(error)")
				return documentsDirectory
			}
		}
		return directory
	}


	internal func saveConfiguration(config: TrackerConfiguration) {
		guard let data = try? NSJSONSerialization.dataWithJSONObject(config.toJson(), options: NSJSONWritingOptions()) else {
			log("Could not prepare config for saving to file.")
			return
		}
		guard let _ = try? data.writeToURL(getConfigurationDirectoryUrl(forTrackingId: config.trackingId).URLByAppendingPathComponent("config.json"), options: .DataWritingAtomic) else {
			log("Writing config to file failed.")
			return
		}
	}


	internal func restoreConfiguration(trackingId: String) -> TrackerConfiguration? {
		guard let data = NSData(contentsOfURL: getConfigurationDirectoryUrl(forTrackingId: trackingId).URLByAppendingPathComponent("config.json")) else {
			log("Couldn't find a config for this trackingId.")
			return nil
		}
		guard let conf = (try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String : AnyObject])!, let config = TrackerConfiguration.fromJson(conf) else {
			return nil
		}
		return config
	}


	internal func saveData(toFileUrl fileUrl: NSURL, data: NSData) {
		guard let url: NSURL = fileUrl.URLByDeletingLastPathComponent! else {
			log("\(fileUrl) is not a valid url to save data to.")
			return
		}

		if !NSFileManager.defaultManager().fileExistsAtPath(url.path!) {
			do {
				try NSFileManager.defaultManager().createDirectoryAtURL(url, withIntermediateDirectories: false, attributes: nil)
			}
			catch let error {
				log("Cannot create directory '\(url)': \(error)")
				return
			}
		}
		guard let _ = try? data.writeToURL(fileUrl, options: .DataWritingAtomic) else {
			log("Writing data to file at \(fileUrl) failed.")
			return
		}
	}


	internal func restoreData(fromFileUrl fileUrl: NSURL) -> NSData? {
		guard NSFileManager.defaultManager().fileExistsAtPath(fileUrl.path!) else {
			return nil
		}
		guard let data: NSData = NSData(contentsOfURL: fileUrl) else {
			log("Couldn't find a data at \(fileUrl) for restoring data.")
			return nil
		}
		return data
	}
}