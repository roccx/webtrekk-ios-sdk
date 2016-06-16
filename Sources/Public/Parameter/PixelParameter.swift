import UIKit

public struct PixelParameter {
	public let version:     Int
	public var pageName:    String
	public let displaySize: CGSize
	public var timeStamp:   NSDate

	public init(version: Int = 400, pageName: String = "", displaySize: CGSize, timeStamp: NSDate = NSDate()) {
		self.version = version
		self.pageName = pageName
		self.displaySize = displaySize
		self.timeStamp = timeStamp
	}

}