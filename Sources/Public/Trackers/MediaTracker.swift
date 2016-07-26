import UIKit


public protocol MediaTracker: class {

	var mediaProperties: MediaProperties { get set }
	var pageName: String? { get set }
	var variables: [String : String] { get set }
	var viewControllerType: UIViewController.Type? { get set }

	func trackAction (action: MediaEvent.Action)
}
