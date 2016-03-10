import Foundation


internal struct FileManager {

	private let documentsDirectory = try! NSFileManager.defaultManager().URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)

	private func getConfigurationDirectoryUrl(forTrackingId id: String) -> NSURL{
		let directory = documentsDirectory.URLByAppendingPathComponent(id)
		if let error = try? NSFileManager.defaultManager().createDirectoryAtPath("\(directory.absoluteString)/", withIntermediateDirectories: true, attributes: [:]) {
			log("An error \(error) occured while creating a directory to store the config.")
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
}