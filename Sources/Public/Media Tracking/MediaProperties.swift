import Foundation


public struct MediaProperties {

	public var bandwidth: Double?    // bit/s
	public var categories: Set<Category>
	public var duration: NSTimeInterval?
	public var name: String
	public var position: NSTimeInterval?
	public var soundIsMuted: Bool?
	public var soundVolume: Double?  // 0 ... 1


	public init(name: String, categories: Set<Category> = []) {
		self.categories = categories
		self.name = name
	}
}
