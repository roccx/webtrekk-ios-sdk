import CoreGraphics
import Foundation


internal final class BackupManager {

	private let fileManager: FileManager

	internal var logger: Webtrekk.Logger


	internal init(fileManager: FileManager, logger: Webtrekk.Logger) {
		self.fileManager = fileManager
		self.logger = logger
	}


	internal func saveEvents(events: [NSURLComponents], to file: NSURL) {
		var jsonEvents = [[String: AnyObject]]()
		for event in events {
			guard let url = event.string as? AnyObject else {
				continue
			}
			jsonEvents.append(["url": url])
		}


		do {
			let data = try NSJSONSerialization.dataWithJSONObject(jsonEvents, options: [])
			fileManager.saveData(toFileUrl: file, data: data)
		}
		catch let error {
			logger.logError("Cannot save pending events to disk: \(error)")
		}

		guard !jsonEvents.isEmpty else{
			logger.logInfo("All events could be sent.")
			return
		}
		logger.logInfo("Stored \(jsonEvents.count) to disc.")
	}


	internal func loadEvents(from file: NSURL) -> [NSURLComponents] {
		guard let data = fileManager.restoreData(fromFileUrl: file) else {
			return []
		}
		guard let jsonEvents: [[String: AnyObject]] = (try? NSJSONSerialization.JSONObjectWithData(data, options: [])) as? [[String: AnyObject]] else {
			logger.logInfo("Data was not a valid json to be restored.")

			return []
		}

		var events = [NSURLComponents]()
		events.reserveCapacity(jsonEvents.count)

		for jsonEvent in jsonEvents {
			guard let urlString = jsonEvent["url"] as? String, url = NSURLComponents(string: urlString) else {
				logger.logError("Cannot load pending event from disk: \(jsonEvent)")
				continue
			}

			events.append(url)
		}

		return events
	}
}


extension BackupManager: RequestManager.Delegate {

	internal func loadEvents() -> [NSURLComponents] {
		return loadEvents(from: fileManager.eventFileUrl)
	}


	internal func saveEvents(events: [NSURLComponents]) {
		saveEvents(events, to: fileManager.eventFileUrl)
	}
}
