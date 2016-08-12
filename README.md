This readme file is incorrect. It should be significantly updated!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



Webtrekk Tracking Library for Swift
===================================


The Webtrekk SDK allows you to track user activities, screen flow and media usage for an App. All data is send to the Webtrekk tracking system for further analysis.

Requirements
============

| Plattform | Version            |
|-----------|-------------------:|
| `iOS`     |             `8.0+` |
| `tvOS`    | planned for `9.0+` |
| `watchOs` | planned for `2.0+` |

Xcode 7.3+

Installation
============

Using [CocoaPods](htttp://cocoapods.org) the installation of the Webtrekk SDK is done by simply adding it to your project's `Podfile`:

```ruby
pod 'Webtrekk'
```

Basic Usage
===========

```swift
import Webtrekk
```

To fullfill the requirements for creating a `Tracker` instance simply add a valid configuration within the application main bundle under the filename `webtrekk_config.xml`. The below code snippet shows a common way to integrate and configure a Webtrekk instance.

```swift
let webtrekkTracker: Tracker = {
	return try! WebtrekkTracking.createTracker()
}()
```

Page View Tracking
------------------

To track page views from the different screens of an App it is common to do this when a screen appeared. The below code snippet demonstrates this by creating a `PageTracker` variable with the name under which this specific screen of the App should be tracked. This comfortable helps to always keep all tracking events pushed through this instance related to the previously specified page name. When the `UITableViewController` calls `viewDidAppear` the Screen is definitely visible to the user and can safely be tracked by calling `trackPageView()` on the assigned variable.

```swift
class ProductListViewController: UITableViewController {

	private let pageTracker = webtrekkTracker.trackerForPage("Product Details")


	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		tracker.trackPageView()
	}
}
```

As an alternative approach the `Tracker` instanced previously stored within `webtrekkTracker` can also send each and every type of event. A page view would be tracked like in the following snippet.

```swift
class ProductListViewController: UITableViewController {

override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		webtrekkTracker.trackPageView("Product Details")
	}
}
```

Action Tracking
---------------

The user interaction on a screen can be tracked by using a previously assigned `tracker` variable of the screen or by utilizing the Webtrekk instance. The code snippet demonstrates the recommended way by using the `tracker` variable within an `IBAction` call from a button.

```swift
@IBAction
func productTapped(sender: UIButton) {
    pageTracker.trackAction("Product tapped")
}
```

As an alternative approach the `Tracker` instanced as previously mentioned can also send action tracking events. The `Tracker` just needs the page name the action is related to.

```swift
@IBAction
func productTapped(sender: UIButton) {
    webtrekkTracker.trackAction("Product tapped", pageName: "Product List")
}
```

Media Tracking
--------------

The Webtrekk SDK offers a simple integration to track different states of you media playback. The code snippet shows the recommended way by using the previously assigned `tracker`variable.

```swift
@IBAction
func productTapped(sender: UIButton) {
    let player = AVPlayer(URL: videoUrl)
    pageTracker.trackerForMedia("product-video-productId", automaticallyTrackingPlayer: player)

    let playerViewController = AVPlayerViewController()
    playerViewController.player = player

    presentViewController(playerViewController, animated: true, completion: nil)
    player.play()
}
```

Additional Tracking Properties
==============================

Beside the basic tracking of the different events each can be enhanced with more details. For that there are the `ActionEvent`, `MediaEvent` and the `PageEvent` which offers the possibility to add those details.

Page View Event
---------------

The `PageViewEvent`is the most commonly used event and as of that has most of the properties that the other two events have.

-	Advertisement Properties
-	Ecommerce Properties
-	Page Properties
-	Session Details
-	User Properties

```swift
var pageViewEvent = PageViewEvent(pageProperties: PageProperties(name: "PageName"))
```

### Advertisement Properties

```swift
pageViewEvent.advertisementProperties = AdvertisementProperties(id: "AdvertisementId", action: "AdvertisementActionName", details: [1: "AdvertisementDetail1", 2: "AdvertisementDetail2"])
```

### Ecommerce Properties

```swift
pageViewEvent.ecommerceProperties = EcommerceProperties(
			currencyCode: "EUR",
			details:      [1: "Detail1", 2: "Detail2"],
			orderNumber:  "123-SVK-567",
			products: [
				EcommerceProperties.Product(name: "ProductName1", categories: [1: "Category1-1", 2: "Category1-2"], price: "100.11", quantity: 123),
				EcommerceProperties.Product(name: "ProductName2", categories: [2: "Category2-2", 3: "Category2-3"], price: "200.22"),
				EcommerceProperties.Product(name: "ProductName3", quantity: 456)
			],
			status:       .addedToBasket,
			totalValue:   "1000.11",
			voucherValue: "15.95"
		)    
```

### Page Properties

```swift
pageViewEvent.pageProperties = PageProperties(name: "PageName", details: [1: "Detail1", 2: "Detail2"], groups: [1: "Group1", 2: "Group2"], internalSearch: "InternalSearch", url: "PageUrl")
```

### Session Details

```swift
pageViewEvent.sessionDetails = [1: "Detail1", 2: "Detail2"]
```

### User Properties

```swift
pageViewEvent.userProperties = UserProperties(
			birthday:             UserProperties.Birthday(day: 12, month: 1, year: 1986),
			city:                 "CityName",
			country:              "CountryName",
			details:              [1: "Detail1", 2: "Detail2"],
			emailAddress:         "EmailAddress",
			emailReceiverId:      "EmailReceiverId",
			firstName:            "FirstName",
			gender:               .male,
			id:                   "UserId",
			ipAddress:            "1.2.3.4",
			lastName:             "LastName",
			newsletterSubscribed: true,
			phoneNumber:          "PhoneNumber",
			street:               "StreetName",
			streetNumber:         "StreetNumber",
			zipCode:              "ZipCode"
		)
```

Action Event
------------

The `ActionEvent` has additional to the properties of the `PageViewEvent` another property named `ActionProperties`. As per requirement any `ActionEvent` needs to be related to a page which concludes in every `ActionEvent` requires a `PageProperties`.

```swift
var actionEvent = ActionEvent(actionProperties: ActionProperties(name: "ActionName"), pageProperties: PageProperties(name: "PageName"))
```

### Action Properties

```swift
actionEvent.actionProperties = ActionProperties(name: "ActionName", details: [1: "Detail1", 2: "Detail2"])
```

Media Event
-----------

The `MediaEvent` has only a subset of the `PageViewEvent` properties and an additional `MediaProperties`. As per requirement any `MediaEvent` needs to be related to a page which concludes in every `MediaEvent` requires a page Name.

-	Media Action
-	Media Properties
-	Page Name
-	Session Details
-	User Properties

```swift
var mediaEvent = MediaEvent(action: .initialize, mediaProperties: MediaProperties(name: "MediaName"), pageName: "PageName")
```

### Media Action

Defines in what kind of action this event is categorized. Besides the SDK given Action a custom Action can also be used for example when a user clicks on an referral link.

-	finish
-	initialize
-	pause
-	play
-	position
-	seek
-	stop
-	custom(name: String)

```swift
mediaEvent.action = .custom(name: "referral-link")
```

### Media Properties

```swift
mediaEvent.mediaProperties = MediaProperties(
	name:         "MediaName",
	bandwidth:    123.456,
	duration:     12345.2,
	groups:       [1: "Group1", 2: "Group2"],
	position:     456.7,
	soundIsMuted: true,
	soundVolume:  0.5
)
```

Global Properties
=================

The `Tracker` has a property called global which holds all properties an event can have. The purpose of those properties are to be merged within every request to supplement the events with information gathered on a global scope.

Cross Device Bridge
-------------------

The "Cross Device Bridge" properties can be set onto the global properties. The `address`, `emailAddress` or `phoneNumber` can either be set as a plain value or as an already hashed MD5 or SHA256 value.

```swift
tracker.global.crossDeviceProperties.emailAddress = .plain(text)
```

Automatic Tracking
==================

The Webtrekk SDK offers the possibility to configure an automatic creation of `Tracker` instances. Once a `UIViewControllers` is configured for automatic tracking the `WebtrekkTracking` holds a preconfigured `Tracker` instance which will be used to automatically track page view events within the `viewDidAppear` function. The code snippet demonstrates how to access this preconfigured instance for further tracking.

```swift
class ProductListViewController: UITableViewController {

  var autoTracker: PageTracker {
    return WebtrekkTracking.trackerForAutotrackedViewController(self)
  }


  @IBAction
  func productTapped(sender: UIButton) {
      autoTracker.trackAction("Product tapped")
  }
}
```

Configuration XML
=================

A Configuration XML contains every option for a Webtrekk Tracker and offers a simple possibility to setup you Webtrekk instance. The Configuration XML is even used to integrate a remote configuration option for the Webtrekk instance

Minimal
-------

A Configuration XML consist of at least three parameters: 'version', 'trackDomain' and 'trackId'

```xml
<?xml version="1.0" encoding="utf-8"?>
<webtrekkConfiguration>
	<!--the version number for this configuration file -->
	<version>1</version>
	<!--the webtrekk trackDomain where the requests are send -->
	<trackDomain>https://q3.webtrekk.net</trackDomain>

	<!--customers trackid-->
	<trackId>123456789123456</trackId>

</webtrekkConfiguration>
```

Optional Settings
-----------------

Addition to be able to configure the minimal options for a Webtrekk Tracker the Configuration XMl opens the possibility to change other options too.

| Option                   | Description                                                                                        |
|--------------------------|----------------------------------------------------------------------------------------------------|
| `sampling`               | measure only every Nth user (0 to disable)                                                         |
| `sendDelay`              | maximum delay after an event occurred before sending it to the server (in seconds)                 |
| `resendOnStartEventTime` | minimum duration the app has to be in the background (or terminated) before starting a new session |
| `maxRequests`            | maximum number of events to keep in the queue while there is no internet connection                |

```xml
  <sampling>0</sampling>
	<sendDelay>300</sendDelay>
	<resendOnStartEventTime>1800</resendOnStartEventTime>
	<maxRequests>1000</maxRequests>
```

Remote Configuration
--------------------

The Configuration XML also yields the option to reload a newer Configuration XML from a remote Url. A remotely saved Configuration XML needs to be valid against the definition, has a higher 'version' and the same 'trackId' as the currently used Configuration XML.

```xml
<enableRemoteConfiguration>false</enableRemoteConfiguration>
<trackingConfigurationUrl>https://d1r27qvpjiaqj3.cloudfront.net/238713152098253/34629.xml</trackingConfigurationUrl>
```

Automatic Tracking
------------------

To use the automatic Tracking feature the Configuration XML contains options to enable or disable different aspects for tracking.

```xml
<autoTracked>true</autoTracked>
<!--track if there was an application update -->
<autoTrackAppUpdate>true</autoTrackAppUpdate>
<!--track the advertiser id -->
<autoTrackAdvertiserId>true</autoTrackAdvertiserId>
<!--track the app versions name -->
<autoTrackAppVersionName>true</autoTrackAppVersionName>
<!--track the app versions code -->
<autoTrackAppVersionCode>true</autoTrackAppVersionCode>
<!--track the devices screen orientation -->
<autoTrackScreenOrientation>true</autoTrackScreenOrientation>
<!--track the current connection type -->
<autoTrackConnectionType>true</autoTrackConnectionType>
<!--track if the user has opted out for advertisement on google plays -->
<autoTrackAdvertisementOptOut>true</autoTrackAdvertisementOptOut>
<!--sends the size of the current locally stored urls in a custom parameter -->
<autoTrackRequestUrlStoreSize>true</autoTrackRequestUrlStoreSize>
```

### Automatic Page Tracking

To make use of the automatic page view tracking of the Webtrekk SDK the Configuration XML offers the possibility to configure the screens which should be tracked. The code snippet below demonstrates a simple case and a more detailed case where instead of a pure String a RegularExpression is used and some properties are set.

```xml
<screen>
  <classname>/.*\.ProductViewController/</classname>
	<mappingname>Product Details</mappingname>
</screen>
<screen>
	<classname>ProductListViewController</classname>
	<mappingname>Product List</mappingname>

	<!--screen tracking parameter -->
	<screenTrackingParameter>
		<parameter id="CURRENCY">EUR</parameter>

		<sessionParameter>
			<parameter id="2">test_sessionparam2</parameter>
		</sessionParameter>
		<ecomParameter>
			<parameter id="2">test_ecomparam2</parameter>
		</ecomParameter>
		<userCategories>
			<parameter id="2">test_usercategory2</parameter>
		</userCategories>
		<pageCategories>
			<parameter id="2">test_pagecategory2</parameter>
		</pageCategories>
		<adParameter>
			<parameter id="2">test_adparam2</parameter>
		</adParameter>
		<actionParameter>
			<parameter id="2">test_actionparam2</parameter>
		</actionParameter>
		<productCategories>
			<parameter id="2">test_productcategory2</parameter>
		</productCategories>
		<mediaCategories>
			<parameter id="2">test_mediacategory2</parameter>
		</mediaCategories>

	</screenTrackingParameter>
</screen>

```

Migrating from Webtrekk SDK V3
==============================

The Webtrekk SDK V4 offers the possibility to migrate some stored information to the new SDK. This option is enabled as per default but in case the old data should be neglected and deleted the value of the `migratesFromLibraryV3` variable needs to be set to `false` before creating the first tracker. The code snippet below shows this case.

```swift
WebtrekkTracking.migratesFromLibraryV3 = false
```

Following properties are part of the migration.

| Option           | Description                                                       |
|------------------|-------------------------------------------------------------------|
| `everId`         | previously generated everId for the user                          |
| `appVersion`     | previously stored appVersion used to detect app updates           |
| `optedOut`       | previously stored status which is only migrated if not set before |
| `samplingState`  | previously stored samplingState                                   |
| `unsentRequests` | previously saved unsent requests                                  |

SSL
===

As of iOS 9 Apple is more strictly enforcing the usage of the SSL for network connections. Webtrekk highly recommend and offers the usage of a valid serverUrl with SSL support. In case there is a need to circumvent this the App needs an exception entry within the `Info.plist` this and the regulation Apple bestows upon that are well documented within the [iOS Developer Library](https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW33)

Examples & Unit Tests
=====================

The `Xcode` directory contains all files necessary to

-	manually build the library
-	run unit test
-	run examples

```shell
# install CocoaPods 1.0.1 or newer (unless you already did)
sudo gem install cocoapods

# clone this repository
git clone https://bitbucket.org/widgetlabs/webtrekk-library.git && cd webtrekk-library

# examples & tests are located in the directory 'Xcode' …
cd Xcode

# … and are set up with CocoaPods
pod update

# 'Examples.xcworkspace' is the file you'll use from now on
open Examples.xcworkspace
```

Project structure
=================

```
|_Module
|_Sources                  [Webtrekk SDK]
| |_Internal
| | |_Event Handlers       [Handler Protocols]
| | |_Requests             [URL Handling]
| | |_Trackers             [Tracker Implementations]
| | |_Utility              [Utils&Extensions]
| |_Public
| | |_Events               [Tracking Events]
| | |_Properties           [Properties of Tracking Events]
| | |_Trackers             [Tracker Protocols]
| | |_Utility              [e.g Logger]
|_Xcode                    [Demo/Tests]
| |_Resources              [Storyboards, Media, Info.plist]
| |_Sources                
| | |_Automatic Tracking   
| | |_Manual Tracking
| | |_WatchKit App
| | |_WatchKit Extension
| |_Tests
```
