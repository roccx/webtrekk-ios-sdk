import Foundation

internal protocol Parameter{
	var urlParameter: [NSURLQueryItem] { get }
}