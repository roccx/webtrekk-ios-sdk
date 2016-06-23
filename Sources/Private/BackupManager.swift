import CoreGraphics
import Foundation


internal final class BackupManager {

	private let fileManager: FileManager


	internal init(fileManager: FileManager) {
		self.fileManager = fileManager
	}


	internal func saveRequests(requests: [NSURL], to file: NSURL) {
		guard let path = file.path else {
			logError("Could not save requests to location \(file)")
			return
		}
		NSKeyedArchiver.archiveRootObject(requests, toFile: path)
		logInfo("Archived \(requests.count) requests.")
	}


	internal func loadRequests(from file: NSURL) -> [NSURL] {
		guard let path = file.path else {
			logError("Could not finds requests at location \(file)")
			return []
		}
		guard let urls = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? [NSURL] else {
			logError("Could not load requests to from \(file)")
			return []
		}
		logInfo("Could load \(urls.count) requests.")
		return urls
	}
}


extension BackupManager: RequestManager.Delegate {

	internal func loadRequests() -> [NSURL] {
		return loadRequests(from: fileManager.eventFileUrl)
	}


	internal func saveRequests(requests: [NSURL]) {
		saveRequests(requests, to: fileManager.eventFileUrl)
	}
}
