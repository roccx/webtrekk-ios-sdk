Webtrekk Tracking Library for Swift
===================================

The Webtrekk SDK allows you to track user activities, screen flow and media usage for an App. All data is send to the Webtrekk tracking system for further analysis.


Requirements
============

| Plattform |            Version |
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

The minimal required configuration parameters for a valid Webtrekk instance are the `serverUrl` and the `webtrekkId`. The below code snippet shows a common way to integrate and configure a Webtrekk instance.

```swift
let webtrekkTracker: Tracker = {
    var configuration = TrackerConfiguration(
		webtrekkId: "289053685367929",
		serverUrl:  NSURL(string: "https://q3.webtrekk.net")!
	)

	return WebtrekkTracking.tracker(configuration: configuration)
}()
```


Page View Tracking
------------------

To track page views from the different screens of an App it is common to do this when a screen appeared. The below code snippet demonstrates this by creating a `tracker` variable with the name under which this specific screen of the App should be tracked. When the `UITableViewController` calls `viewDidAppear` the Screen is definitely visible to the user and can safely be tracked by calling `trackPageView()` on the previously assigned variable.

```swift
class ProductListViewController: UITableViewController {

	private let pageTracker = webtrekkTracker.trackerForPage("Product Details")


	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)

		tracker.trackPageView()
	}
}

```

Action Tracking
---------------

The user interaction on a screen can be tracked by done in two different ways either by using a previously assigned `tracker` variable of the screen or by utilizing the Webtrekk instance. The code snippet demonstrates the recommended way by using the `tracker` variable within an `IBAction` call from a button.

```swift
@IBAction
func productTapped(sender: UIButton) {
    pageTracker.trackAction("Product tapped")
}
```

Media Tracking
--------------

The Webtrekk SDK offers a simple integration to track different states of you media playback. There are two approaches to make use of that. The first code snippet shows the recommended way by using the previously assigned `tracker`variable.

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


Configuration XML
=================

A Configuration XML contains every option for a Webtrekk Tracker and offers a simple possibility to setup you Webtrekk instance. The Configuration XML is even used to integrate a remote configuration option for the Webtrekk instance

Minimal
-------

A Configuration XML consist of at least three parameters: 'version', 'trackDomain' and 'trackId'

```xml
<?xml version="1.0" encoding="utf-8"?>
<webtrekkConfiguration>
	<!-- configuration file version -->
	<version>1</version>

	<!-- server to send tracking events to -->
	<trackDomain>https://q3.webtrekk.net</trackDomain>

	<!-- Webtrekk customer id -->
	<trackId>289053685367929</trackId>
</webtrekkConfiguration>
```

Optional Settings
-----------------

Addition to be able to configure the minimal options for a Webtrekk Tracker the Configuration XMl opens the possibility to change other options too.

| Option                   | Description |
|--------------------------|-------------|
| `sampling`               |             |
| `sendDelay`              |             |
| `sessionTimeoutInterval` |             |
| `maxRequests`            | s           |

```xml
    <!-- measure only every Nth user (0 to disable) -->
	<sampling>0</sampling>
	<!-- maximum delay after an event occurred before sending it to the server (in seconds) -->
	<sendDelay>300</sendDelay>
	<!-- minimum duration the app has to be in the background (or terminated) before starting a new session -->
	<sessionTimeoutInterval>1800</sessionTimeoutInterval>
	<!-- maximum number of events to keep in the queue while there is no internet connection -->
	<maxRequests>1000</maxRequests>
	<!-- automatically download updated versions of this configuration file (empty to disable updates) -->
	<configurationUpdateUrl>https://your.domain/webtrekk.xml</configurationUpdateUrl>
```

Remote Configuration
--------------------

The Configuration XML also yields the option to reload a newer Configuration XML from a remote Url. A remotely saved Configuration XML needs to be valid against the definition, has a higher 'version' and the same 'trackId' as the currently used Configuration XML.

Automatic Tracking
------------------

To use the automatic Tracking feature the Configuration XML contains options to enable or disable different aspects for tracking.

```xml
<!-- automatically track various information -->
<automaticTracking>
    <advertisingIdentifier>true</advertisingIdentifier>
    <appUpdates>true</appUpdates>
    <appVersion>true</appVersion>
    <connectionType>true</connectionType>
    <interfaceOrientation>true</interfaceOrientation>
    <requestQueueSize>true</requestQueueSize>
</automaticTracking>
```

### Automatic Page Tracking

To make use of the automatic page view tracking of the Webtrekk SDK the Configuration XML offers the possibility to configure the screens which should be tracked. The code snippet below demonstrates a simple case and a more detailed case where instead of a pure String a RegularExpression is used and some properties are set.

```xml
<automaticTracking>
  <pages>
    <page viewControllerType="ProductListViewController">
      <pageProperties name="Product List"/>
    </page>

    <page viewControllerType="/.*\.ProductViewController/">
      <pageProperties name="Product Details">
        <details index1="Blue Variant" index2="Media"/>
      </pageProperties>
      <customProperties myProperty="myValue" anotherProperty="anotherValue"/>
    </page>
  </pages>
</automaticTracking>

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

- manually build the library
- run unit test
- run examples

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
