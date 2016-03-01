import UIKit

public struct PixelParameter {
	public let version:     Int
	public var pageName:    String = ""
	public let displaySize: CGSize
	public var timeStamp:   Int64 = -1

	public init(version: Int = 400, pageName: String = "", displaySize: CGSize, timeStamp: Int64 = -1) {
		self.version = version
		self.pageName = pageName
		self.displaySize = displaySize
		self.timeStamp = timeStamp
	}

}


extension PixelParameter: Parameter {
	internal var urlParameter: String {
		get {
			return "\(ParameterName.Pixel.rawValue)=\(version),\(pageName),0,\(Int(displaySize.width))x\(Int(displaySize.height)),32,0,\(timeStamp),0,0,0"
		}
	}
}

