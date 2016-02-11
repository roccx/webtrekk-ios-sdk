import UIKit

public struct PixelParameter {
	public let version: Int
	public var pageName: String = ""
	public let displaySize: CGSize
	public var timestamp: Int = -1

	public init(version: Int = 400, pageName: String = "", displaySize: CGSize, timestamp: Int = -1) {
		self.version = version
		self.pageName = pageName
		self.displaySize = displaySize
		self.timestamp = timestamp
	}

}

extension PixelParameter: Parameter {

	public var queryItems: [NSURLQueryItem] {
		get {
			return [NSURLQueryItem(name: .PIXEL, value: "\(version),\(pageName),0,\(Int(displaySize.width))x\(Int(displaySize.height)),32,0,\(timestamp),0,0,0")]
		}
	}
}

