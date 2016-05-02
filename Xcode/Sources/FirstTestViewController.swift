import AVFoundation
import AVKit
import UIKit
import Webtrekk


internal class FirstTestViewController: UIViewController {

	let button = Button()

	internal init() {
		super.init(nibName: nil, bundle: nil)
		tabBarItem = UITabBarItem(title: "Media", image: UIImage(named: "movie"), tag: 2)
	}


	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}


	private func layoutComponents() {
		let bounds = self.view.bounds
		button.frame = CGRect(x: 10, y: bounds.height / 2, width: bounds.width - 20, height: 50)
	}


	private func setUp() {
		button.setTitle("Play", forState: .Normal)
		button.setTitleColor(.blackColor(), forState: .Normal)
		button.handle(.TouchUpInside) { (sender:Button) in
			guard let url = NSBundle(forClass: FirstTestViewController.self).URLForResource("wt", withExtension: "mp4") else {
				print("file url not possible")
				return
				}
			let avController = AVPlayerViewController()
			avController.player = WtAvPlayer(URL: url, webtrekk: webtrekk!)
			webtrekk!.track("VideoPlayer")
			self.presentViewController(avController, animated: true, completion: nil)

		}
		self.view.addSubview(button)

	}


	override func viewDidLoad() {
		super.viewDidLoad()
		setUp()
	}


	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		layoutComponents()
	}

	var startObserver: AnyObject?
	var periodicObserver: AnyObject?
}

public protocol WebtrekkReference {
	func webtrekkReference() -> Webtrekk?
}

extension AVPlayer: WebtrekkReference {
	public func webtrekkReference() -> Webtrekk? {
		return webtrekk
	}
}
