import Foundation


internal final class MigrationManager {


	internal func migrateWebtrekkId() {
		#if !os(iOS)
		return
		#endif

		let fileManager = NSFileManager.defaultManager()
		if let oldFileUrl = try? fileManager.URLForDirectory(.LibraryDirectory, inDomain: .AllDomainsMask, appropriateForURL: nil, create: false).URLByAppendingPathComponent("webtrekk-id") {
			if let path = oldFileUrl.path where fileManager.fileExistsAtPath(path) {
				if let webtrekkId = try? String(contentsOfURL: oldFileUrl) where !webtrekkId.isEmpty {
					// FIXME: Store to defaults
				}
			}

		}

		if let oldFileUrl = try? fileManager.URLForDirectory(.DocumentDirectory, inDomain: .AllDomainsMask, appropriateForURL: nil, create: false).URLByAppendingPathComponent("webtrekk-id") {
			if let path = oldFileUrl.path where fileManager.fileExistsAtPath(path) {
				if let webtrekkId = try? String(contentsOfURL: oldFileUrl) where !webtrekkId.isEmpty {
					// FIXME: Store to defaults
				}
			}

		}
	}
}