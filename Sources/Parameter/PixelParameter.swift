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


extension PixelParameter: Parameter {
	internal var urlParameter: String {
		get {
			return "?\(ParameterName.Pixel.rawValue)=\(version),\(pageName.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!),0,\(Int(displaySize.width))x\(Int(displaySize.height)),32,0,\(Int64(timeStamp.timeIntervalSince1970 * 1000)),0,0,0"
		}
	}
}

