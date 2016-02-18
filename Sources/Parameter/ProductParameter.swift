import Foundation

public protocol ProductParameter {
	var categories: [Int: String] { get set }
	var currency:   String        { get set }
	var name:       String        { get set }
	var price:      String        { get set }
	var quantity:   String        { get set }
}
