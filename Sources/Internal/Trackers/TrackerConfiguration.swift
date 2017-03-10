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

import Foundation
import UIKit


internal struct TrackerConfiguration {

	/** Allowed values for sendDelay */
	internal static let allowedMaximumSendDelays: ClosedRange<TimeInterval> = 0 ... .infinity

	/** Allowed values for resendOnStartEventTime */
	internal static let allowedResendOnStartEventTimes: ClosedRange<TimeInterval> = 0 ... .infinity

	/** Allowed values for samplingRate */
	internal static let allowedSamplingRates: ClosedRange<Int> = 0 ... .max

	/** Allowed values for version */
	internal static let allowedVersions: ClosedRange<Int> = 1 ... .max

	/** If enabled automatically tries to attach the Advertising Identifier to each request. */
	internal var automaticallyTracksAdvertisingId = true

	/** If enabled automatically tries to attach the Advertising Opt Out state to each request. */
	internal var automaticallyTracksAdvertisingOptOut = true

	/** If enabled automatically trackes app updates. */
	internal var automaticallyTracksAppUpdates = true

	/** If enabled automatically attaches the app version to each request. */
	internal var automaticallyTracksAppVersion = true

	/** If enabled automatically attaches the current request queue size to each request. */
	internal var automaticallyTracksRequestQueueSize = true
    
    /** If enabled automatically tracks adclear id. */
    internal var automaticallyTracksAdClearId = false
    
	/** Url of the remote configuration. */
	internal var configurationUpdateUrl: URL? = nil

	/** Timeout between sending message to server. */
	internal var maximumSendDelay = TimeInterval(5 * 60)

	/** The timout interval indicating when a new session should be tracked after an app went in the background. */
	internal var resendOnStartEventTime = TimeInterval(30 * 60)

	/** The tracker will randomly tracks only every X user. */
	internal var samplingRate = 0

	/** Url of the tracking server. */
	internal var serverUrl: URL

	/** The version is used to compare the current configuration with a remote configuration and to decide whether there is an update for the configuration available. */
	internal var version = 1

	/** The unique identifier of your webtrekk account. */
	internal var webtrekkId: String

	/** Automatically attaches tracker instances to the corresponding view controller if possible. */
	internal var automaticallyTrackedPages = [Page]()

    #if !os(watchOS)
	/** If enabled automatically attaches the connection type to each request. */
	internal var automaticallyTracksConnectionType = true

	/** If enabled automatically attaches the interface orientation to each request. */
	internal var automaticallyTracksInterfaceOrientation = true
	#endif

    //list of recommendations
    internal var recommendations : [String: URL]? = nil
	
    //error tracking
    internal var errorLogLevel: Int? = nil
    
    internal var globalProperties = GlobalProperties()
    

	/** 
	Configuration for a Tracker

	Enable or disable various automatically tracked features or customize options to fit your requirement.

	- Parameter webtrekkId: The unique identifier of your webtrekk account
	- Parameter serverUrl: Url of the tracking server
	*/
	internal init(webtrekkId: String, serverUrl: URL) {
		self.serverUrl = serverUrl
		self.webtrekkId = webtrekkId
	}


	internal func automaticallyTrackedPageForViewControllerType(_ viewControllerType: AnyObject.Type) -> Page? {
		let typeName = String(reflecting: viewControllerType)

		return automaticallyTrackedPages.firstMatching(predicate: { $0.matches(viewControllerTypeName: typeName) })
	}

	/**
	Representation of an automatically tracked page.
	*/
    internal class Page: BaseProperties {

		/** A Regular Expression to determine a view controller for automatic tracking. */
		internal var viewControllerTypeNamePattern: NSRegularExpression


		/**
		- Parameter viewControllerTypeNamePattern: A Regular Expression to determine a view controller for automatic tracking.
		- Parameter pageProperties: Page Properties that should be tracked if not overwritten manually.
		- Parameter customProperties: Custom Properties that should be tracked if not overwritten manually.
		*/
		internal init(
			viewControllerTypeNamePattern: NSRegularExpression,
			pageProperties: PageProperties,
			actionProperties: ActionProperties? = nil,
			advertisementProperties: AdvertisementProperties? = nil,
			ecommerceProperties: EcommerceProperties? = nil,
			ipAddress: String? = nil,
			mediaProperties: MediaProperties? = nil,
			sessionDetails: [Int: TrackingValue]? = nil,
			userProperties: UserProperties? = nil
		) {
            self.viewControllerTypeNamePattern = viewControllerTypeNamePattern
            super.init(actionProperties: actionProperties ?? ActionProperties(name: nil),
                       advertisementProperties: advertisementProperties ?? AdvertisementProperties(id: nil),
                       ecommerceProperties: ecommerceProperties ?? EcommerceProperties(), ipAddress: ipAddress,
                       mediaProperties: mediaProperties ?? MediaProperties(name: nil), pageProperties: pageProperties,
                       sessionDetails: sessionDetails ?? [ : ], userProperties: userProperties ?? UserProperties(birthday: nil))
		}


		fileprivate func matches(viewControllerTypeName: String) -> Bool {
			return viewControllerTypeNamePattern.rangeOfFirstMatch(in: viewControllerTypeName, options: [], range: NSRange(forString: viewControllerTypeName)).location != NSNotFound
		}
	}
}
