import UIKit


public protocol TrackingEvent {

	var ipAddress: String? { get mutating set }
	var pageName: String? { get mutating set }
	var variables: [String : String] { get mutating set }
	var viewControllerType: UIViewController.Type? { get mutating set }
}
