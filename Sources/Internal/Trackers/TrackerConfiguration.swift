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
//  Created by Widget Labs
//

import Foundation
import UIKit


internal struct TrackerConfiguration {

	/** Allowed values for sendDelay */
	internal static let allowedMaximumSendDelays: ClosedInterval<NSTimeInterval> = 5 ... .infinity

	/** Allowed values for requestQueueLimit */
	internal static let allowedRequestQueueLimits: ClosedInterval<Int> = 1 ... .max

	/** Allowed values for resendOnStartEventTime */
	internal static let allowedResendOnStartEventTimes: ClosedInterval<NSTimeInterval> = 0 ... .infinity

	/** Allowed values for samplingRate */
	internal static let allowedSamplingRates: ClosedInterval<Int> = 0 ... .max

	/** Allowed values for version */
	internal static let allowedVersions: ClosedInterval<Int> = 1 ... .max

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

	/** Url of the remote configuration. */
	internal var configurationUpdateUrl: NSURL? = nil

	/** Delay after which the event request is send to the server. */
	internal var maximumSendDelay = NSTimeInterval(5 * 60)

	/** Maxiumum number of request which are stored before sending. */
	internal var requestQueueLimit = 1000

	/** The timout interval indicating when a new session should be tracked after an app went in the background. */
	internal var resendOnStartEventTime = NSTimeInterval(30 * 60)

	/** The tracker will randomly tracks only every X user. */
	internal var samplingRate = 0

	/** Url of the tracking server. */
	internal var serverUrl: NSURL

	/** The version is used to compare the current configuration with a remote configuration and to decide whether there is an update for the configuration available. */
	internal var version = 1

	/** The unique identifier of your webtrekk account. */
	internal var webtrekkId: String

	#if !os(watchOS)
	/** Automatically attaches tracker instances to the corresponding view controller if possible. */
	internal var automaticallyTrackedPages = [Page]()

	/** If enabled automatically attaches the connection type to each request. */
	internal var automaticallyTracksConnectionType = true

	/** If enabled automatically attaches the interface orientation to each request. */
	internal var automaticallyTracksInterfaceOrientation = true
	#endif

	internal var globalProperties = GlobalProperties()


	/** 
	Configuration for a Tracker

	Enable or disable various automatically tracked features or customize options to fit your requirement.

	- Parameter webtrekkId: The unique identifier of your webtrekk account
	- Parameter serverUrl: Url of the tracking server
	*/
	internal init(webtrekkId: String, serverUrl: NSURL) {
		self.serverUrl = serverUrl
		self.webtrekkId = webtrekkId
	}


	#if !os(watchOS)
	internal func automaticallyTrackedPageForViewControllerType(viewControllerType: UIViewController.Type) -> Page? {
		let typeName = String(reflecting: viewControllerType)

		return automaticallyTrackedPages.firstMatching({ $0.matches(viewControllerTypeName: typeName) })
	}
	#endif


	
	#if !os(watchOS)
	/**
	Representation of an automatically tracked page.
	*/
	internal struct Page {

		internal var actionProperties: ActionProperties?

		internal var advertisementProperties: AdvertisementProperties?

		internal var ecommerceProperties: EcommerceProperties?

		internal var ipAddress: String?

		internal var mediaProperties: MediaProperties?

		/** Page Properties that should be tracked if not overwritten manually. */
		internal var pageProperties: PageProperties

		internal var sessionDetails: [Int: TrackingValue]?

		internal var userProperties: UserProperties?

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
			self.actionProperties = actionProperties
			self.advertisementProperties = advertisementProperties
			self.ecommerceProperties = ecommerceProperties
			self.ipAddress = ipAddress
			self.mediaProperties = mediaProperties
			self.pageProperties = pageProperties
			self.sessionDetails = sessionDetails
			self.userProperties = userProperties
			self.viewControllerTypeNamePattern = viewControllerTypeNamePattern
		}


		private func matches(viewControllerTypeName viewControllerTypeName: String) -> Bool {
			return viewControllerTypeNamePattern.rangeOfFirstMatchInString(viewControllerTypeName, options: [], range: NSRange(forString: viewControllerTypeName)).location != NSNotFound
		}
	}
	#endif
}
