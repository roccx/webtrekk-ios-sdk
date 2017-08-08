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

import UIKit

#if !os(watchOS)
	import AVFoundation
#endif


internal final class DefaultPageTracker: PageTracker {

	internal typealias Handler = ActionEventHandler & MediaEventHandler & PageViewEventHandler

	fileprivate let handler: Handler
	
	internal var advertisementProperties = AdvertisementProperties(id: nil)
	internal var ecommerceProperties = EcommerceProperties()
	internal var pageProperties: PageProperties
	internal var sessionDetails = [Int: TrackingValue]()
    internal var userProperties = UserProperties(birthday: nil)
	internal var variables = [String : String]()


	internal init(handler: Handler, pageName: String) {
		checkIsOnMainThread()

		self.handler = handler

		self.pageProperties = PageProperties(name: pageName)
	}


	internal init(handler: Handler, viewControllerType: AnyObject.Type) {
		checkIsOnMainThread()

		self.handler = handler

		self.pageProperties = PageProperties(viewControllerType: viewControllerType)
	}


	internal func trackAction(_ event: ActionEvent) {
		checkIsOnMainThread()

		handleEvent(event)
	}


	internal func trackMediaAction(_ event: MediaEvent) {
		checkIsOnMainThread()

		handleEvent(event)
	}


	internal func trackPageView() {
		checkIsOnMainThread()

		handler.handleEvent(PageViewEvent(
			pageProperties:          pageProperties,
			advertisementProperties: advertisementProperties,
			ecommerceProperties:     ecommerceProperties,
			sessionDetails:          sessionDetails,
			userProperties:          userProperties,
			variables:               variables
		))
	}


	internal func trackPageView(_ pageViewEvent: PageViewEvent) {
		checkIsOnMainThread()

		handler.handleEvent(PageViewEvent(
			pageProperties:          pageViewEvent.pageProperties.merged(over: pageProperties),
			advertisementProperties: pageViewEvent.advertisementProperties.merged(over: advertisementProperties),
			ecommerceProperties:     pageViewEvent.ecommerceProperties.merged(over: ecommerceProperties),
			ipAddress:               pageViewEvent.ipAddress,
			sessionDetails:          pageViewEvent.sessionDetails.merged(over: sessionDetails),
			userProperties:          pageViewEvent.userProperties.merged(over: userProperties),
			variables:               pageViewEvent.variables.merged(over: variables)
		))
	}


	
	internal func trackerForMedia(_ mediaName: String) -> MediaTracker {
		checkIsOnMainThread()

		return DefaultMediaTracker(handler: self, mediaName: mediaName, pageName: nil, mediaProperties: nil, variables: nil)
	}


	#if !os(watchOS)
	internal func trackerForMedia(_ mediaName: String, automaticallyTrackingPlayer player: AVPlayer) -> MediaTracker {
		checkIsOnMainThread()

		let tracker = trackerForMedia(mediaName)
		AVPlayerTracker.track(player: player, with: tracker)

		return tracker
	}
	#endif
}


extension DefaultPageTracker: ActionEventHandler {

	internal func handleEvent(_ event: ActionEvent) {
		checkIsOnMainThread()

		let event = event
		event.advertisementProperties = event.advertisementProperties.merged(over: advertisementProperties)
		event.ecommerceProperties = event.ecommerceProperties.merged(over: ecommerceProperties)
		event.pageProperties = event.pageProperties.merged(over: pageProperties)
		event.sessionDetails = event.sessionDetails.merged(over: sessionDetails)
		event.userProperties = event.userProperties.merged(over: userProperties)
		event.variables = event.variables.merged(over: variables)

		handler.handleEvent(event)
	}
}


extension DefaultPageTracker: MediaEventHandler {

	internal func handleEvent(_ event: MediaEvent) {
		checkIsOnMainThread()

		let event = event
		event.pageName = event.pageName ?? pageProperties.name
		event.viewControllerType = event.viewControllerType ?? pageProperties.viewControllerType
		event.variables = event.variables.merged(over: variables)

		handler.handleEvent(event)
	}
}
