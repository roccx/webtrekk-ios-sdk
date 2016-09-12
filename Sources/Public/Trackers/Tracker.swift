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


public protocol Tracker: class {

	/** get and set everID. If you set Ever ID it started to use new value for all requests*/
    var everId: String { get set }
	var global: GlobalProperties { get set }
	var plugins: [TrackerPlugin] { get set }


	#if os(watchOS)
	func applicationDidFinishLaunching()
	#endif

	func sendPendingEvents()

	func trackAction(event: ActionEvent)

	func trackMediaAction(event: MediaEvent)

	func trackPageView(event: PageViewEvent)

	@warn_unused_result
	func trackerForMedia(mediaName: String, pageName: String) -> MediaTracker

	#if !os(watchOS)
	func trackerForMedia(mediaName: String, pageName: String, automaticallyTrackingPlayer player: AVPlayer) -> MediaTracker
	#endif

	@warn_unused_result
	func trackerForPage(pageName: String) -> PageTracker
    
    /** set media code. Media code will be sent with next page request only. Only setter is working. Getter always returns ""*/
    var mediaCode: String { get set }
    
    //Override of page URL parameters in code or xml
    var pageURL: String? { get set }
}


public extension Tracker {

	public func trackAction(
		actionName: String,
		pageName: String,
		advertisementProperties: AdvertisementProperties = AdvertisementProperties(id: nil),
		ecommerceProperties: EcommerceProperties = EcommerceProperties(),
		sessionDetails: [Int: TrackingValue] = [:],
		userProperties: UserProperties = UserProperties(birthday: nil),
		variables: [String : String] = [:]
	) {
		trackAction(
			ActionProperties(name: actionName),
			pageProperties:          PageProperties(name: pageName),
			advertisementProperties: advertisementProperties,
			ecommerceProperties:     ecommerceProperties,
			sessionDetails:          sessionDetails,
			userProperties:          userProperties,
			variables:               variables
		)
	}


	public func trackAction(
		actionName: String,
		viewControllerType: UIViewController.Type,
		advertisementProperties: AdvertisementProperties = AdvertisementProperties(id: nil),
		ecommerceProperties: EcommerceProperties = EcommerceProperties(),
		sessionDetails: [Int: TrackingValue] = [:],
		userProperties: UserProperties = UserProperties(birthday: nil),
		variables: [String : String] = [:]
	) {
		trackAction(
			ActionProperties(name: actionName),
			pageProperties:          PageProperties(viewControllerType: viewControllerType),
			advertisementProperties: advertisementProperties,
			ecommerceProperties:     ecommerceProperties,
			sessionDetails:          sessionDetails,
			userProperties:          userProperties,
			variables:               variables
		)
	}


	public func trackAction(
		actionProperties: ActionProperties,
		pageProperties: PageProperties,
		advertisementProperties: AdvertisementProperties = AdvertisementProperties(id: nil),
		ecommerceProperties: EcommerceProperties = EcommerceProperties(),
		sessionDetails: [Int: TrackingValue] = [:],
		userProperties: UserProperties = UserProperties(birthday: nil),
		variables: [String : String] = [:]
	) {
		trackAction(ActionEvent(
			actionProperties:        actionProperties,
			pageProperties:          pageProperties,
			advertisementProperties: advertisementProperties,
			ecommerceProperties:     ecommerceProperties,
			sessionDetails:          sessionDetails,
			userProperties:          userProperties,
			variables:               variables
		))
	}


	public func trackMediaAction(
		action: MediaEvent.Action,
		mediaProperties: MediaProperties,
		pageName: String?,
		variables: [String : String] = [:]
	) {
		trackMediaAction(MediaEvent(
			action: action,
			mediaProperties: mediaProperties,
			pageName: pageName,
			variables: variables
		))
	}


	public func trackPageView(
		pageName: String,
		advertisementProperties: AdvertisementProperties = AdvertisementProperties(id: nil),
		ecommerceProperties: EcommerceProperties = EcommerceProperties(),
		sessionDetails: [Int: TrackingValue] = [:],
		userProperties: UserProperties = UserProperties(birthday: nil),
		variables: [String : String] = [:]
	) {
		trackPageView(
			PageProperties(name: pageName),
			advertisementProperties: advertisementProperties,
			ecommerceProperties:     ecommerceProperties,
			sessionDetails:          sessionDetails,
			userProperties:          userProperties,
			variables:               variables
		)
	}


	public func trackPageView(
		pageProperties: PageProperties,
		advertisementProperties: AdvertisementProperties = AdvertisementProperties(id: nil),
		ecommerceProperties: EcommerceProperties = EcommerceProperties(),
		sessionDetails: [Int: TrackingValue] = [:],
		userProperties: UserProperties = UserProperties(birthday: nil),
		variables: [String : String] = [:]
	) {
		trackPageView(PageViewEvent(
			pageProperties:          pageProperties,
			advertisementProperties: advertisementProperties,
			ecommerceProperties:     ecommerceProperties,
			sessionDetails:          sessionDetails,
			userProperties:          userProperties,
			variables:               variables
		))
	}
    
    public func trackCDB(crossDeviceProperties: CrossDeviceProperties)
    {
        global.crossDeviceProperties = crossDeviceProperties
        trackPageView("CDBPage")
    }
    
    public subscript(key: String) -> String? {
        get {
            return global.variables[key]
        }
        set {
            global.variables[key] = newValue
        }
    }
}
