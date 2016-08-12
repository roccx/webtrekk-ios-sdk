import UIKit

#if !os(watchOS)
	import AVFoundation
#endif


public protocol Tracker: class {

	var everId: String { get }
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
