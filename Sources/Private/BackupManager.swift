import CoreGraphics
import Foundation


internal final class BackupManager {

	private let fileManager: FileManager

	internal var logger: Webtrekk.Logger


	internal init(fileManager: FileManager, logger: Webtrekk.Logger) {
		self.fileManager = fileManager
		self.logger = logger
	}


	internal func saveEvents(events: [NSURL], to file: NSURL) {
		guard let path = file.path else {
			logger.logError("Could not save requests to location \(file)")
			return
		}
		NSKeyedArchiver.archiveRootObject(events, toFile: path)
		logger.logInfo("Archived \(events.count) requests.")
	}


	internal func loadEvents(from file: NSURL) -> [NSURL] {
		guard let path = file.path else {
			logger.logError("Could not finds requests at location \(file)")
			return []
		}
		guard let urls = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? [NSURL] else {
			logger.logError("Could not load events to from \(file)")
			return []
		}
		logger.logInfo("Could load \(urls.count) requests.")
		return urls
	}
}


extension BackupManager: RequestManager.Delegate {

	internal func loadEvents() -> [NSURL] {
		return loadEvents(from: fileManager.eventFileUrl)
	}


	internal func saveEvents(events: [NSURL]) {
		saveEvents(events, to: fileManager.eventFileUrl)
	}
}
