//The MIT License (MIT)
//
//Copyright (c) 2016 Webtrekk GmbH
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
//"Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
//distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject
//to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Created by Widgetlabs
//

import AVFoundation
import AVKit
import UIKit
import Webtrekk


class ProductViewController: UIViewController {

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == "openVideo" {
			guard let playerViewController = segue.destination as? AVPlayerViewController else {
				return
			}
			guard let videoUrl = Bundle.main.url(forResource: "Video", withExtension: "mp4") else {
				return
			}

			autoTracker.trackAction("Play Video tapped")

			let player = AVPlayer(url: videoUrl)
			let _ = autoTracker.trackerForMedia("product-video-\(productId)", automaticallyTrackingPlayer: player)

			playerViewController.player = player

			player.play()
		}

		if segue.identifier == "openVouchers" {
			autoTracker.trackAction("Choose Voucher tapped")
		}
	}


	var productId = 0 {
		didSet {
			title = "Product \(productId)"
		}
	}
}
