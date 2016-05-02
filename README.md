# Webtrekk iOS SDK


## Installation

### CococaPods

Installation des SDKs mit Hilfe von [CocoaPods](http://cocoapods.org/):

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'Webtrekk'
```


## Kurzanleitung

Für die Konfiguration und Verwendung des Webtrekk SDKs wird auf die Kombination der Server URL und der Tracking ID gesetzt. Dies sind auch die minimalen Elemente welche konfiguriert werden müssen bevor das SDK verwendet werden kann.

```swift
let config = TrackerConfiguration(serverUrl: "https://yourwebtrekk.domain.plz", trackingId: "123456789012345")
let tracker = Webtrekk(config: config)
```

Ein Tracking Request kann mit einer zuvor initialisierten Instance eines Webtrekk Trackers ganz einfach abgesetzt werden.

```swift
tracker.track(pageName: "MyFirstTrackedPage")
```


## Verwendung

Für die Verwendung des Webtrekks SDKs wird zunächst eine grundlegende Konfiguration, basierend auf der Server URL und der Tracking ID, benötigt. 

### Tracker Configuration

```swift
let tracker = Webtrekk(config: TrackerConfiguration(serverUrl: "https://yourwebtrekk.domain.plz", trackingId: "123456789012345"))
```

#### Benötigte Angaben

Option      | Description
------------|------------
`serverUrl` | Server URL `https://domain.de
`trackingId`| 15 stellige Tracking ID

#### Zusätzliche Angaben

Option                         | Default  | Description
-------------------------------|----------|-------------
`appVersion`                   | `""`     |
`maxRequests`                  | `1000`   |
`samplingRate`                 | `0`      |
`sendDelay`                    | `300`    |
`version`                      | `0`      |
`optedOut`                     | `false`  |
`autoTrack`                    | `true`   |
`autoTrackAdvertiserId`        | `true`   |
`autoTrackApiLevel`            | `true`   |
`autoTrackAppUpdate`           | `true`   |
`autoTrackAppVersionName`      | `true`   |
`autoTrackAppVersionCode`      | `true`   |
`autoTrackConnectionType`      | `true`   |
`autoTrackRequestUrlStoreSize` | `true`   |
`autoTrackScreenOrientation`   | `true`   |
`enableRemoteConfiguration`    | `false`  |
`remoteConfigurationUrl`       | `""`     |


### Tracking Parameter

Bei der Verwendung des Webtrekk SDKs unterteilt man beim Tracking die zu verwendenden Requests in die 3 Kategorien Inhalt, Aktion und Media. Dementsprechend werden beim Absetzen von Tracking Requests entsprechend der Kategorie ein `PageTrackingParameter`, `ActionTrackingParameter` oder ein `MediaTrackingParameter` übergeben.


### Page Tracking

Für das Tracken von Screens oder Pages wird ein `PageTrackingParameter` verwendet, dieser kann wie folgt abgesetzt werden

```swift
let pageTrackingParameter = PageTrackingParameter(pageName: "TestPage")
tracker.track(pageTrackingParameter)
```

oder über die kurze Variante.

```swift
tracker.track(pageName: "TestPage")
```

#### Optional settings

Option                 | Default                | Description
-----------------------|------------------------|-------------
`pageName`             | `""`                   |
`pageParameter`        | `PageParameter()`      |
`ecommerceParameter`   | `nil`                  |
`productParameters`    | `[ProductParameter]()` |

#### Computed settings

Option                 |  Description
-----------------------|--------------
`generalParameter`     | 
`pixelParameter`       | 



## Page Parameter

```swift
let pageParameter = PageParameter()
```

### Optional settings

Option        | Default             | Description
--------------|---------------------|-------------
`page`        | `[Int: String]()`   |
`categories`  | `[Int: String]()`   |
`session`     | `[Int: String]()`   |


## General Parameter


### Settings

Option           |  Description
-----------------|--------------
`everId`         | 
`firstStart`     | 
`ip`             | 
`nationalCode'   | 
`samplingRate`   | 
`timeStamp`      | 
`timeZoneOffset` | 
`userAgent`      | 



## Pixel Parameter


### Settings

Option         |  Description
---------------|--------------
`version`      | 
`pageName`     | 
`displaySize`  | 
`timeStamp'    |



## Product Parameter

### Mandatory settings

Option        | Description
--------------|------------
`productName` | 


### Optional settings

Option        | Default             | Description
--------------|---------------------|-------------
`categories`  | `[Int: String]()`   |
`currency`    | `""`                |
`price`       | `""`                |
`quantity`    | `""`                |


## Ecommerce Parameter

### Mandatory settings

Option        | Description
--------------|------------
`totalValue`  |


### Optional settings

Option          | Default                | Description
----------------|------------------------|-------------
`categories`    | `[Int: String]()`      |
`currency`      | `""`                   |
`orderNumber`   | `""`                   |
`voucherValue`  | `nil`                  |
`status`        | `EcommerceStatus.VIEW` |


## Ecommerce Status

### Settings

Option     |  Description
-----------|--------------
`ADD`      | 
`CONF`     | 
`VIEW`     | 


## Automatisches Screen Tracking

Über die Tracker Konfiguration kann mit einer kleinen Erweiterung der UIViewController Klasse das Automatisches Screen Tracking aktiviert werden. Dadurch wird jeder ViewController getracked. 

```swift
// global instance: var webtrekk: Webtrekk?
extension UIViewController {
	public override class func initialize() {
		struct Static {
			static var token: dispatch_once_t = 0
		}

		if self !== UIViewController.self {
			return
		}

		dispatch_once(&Static.token) {
			let originalSelector = #selector(viewWillAppear)
			let swizzledSelector = #selector(wtk_viewWillAppear)

			let originalMethod = class_getInstanceMethod(self, originalSelector)
			let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)

			let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))

			if didAddMethod {
				class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
			} else {
				method_exchangeImplementations(originalMethod, swizzledMethod)
			}
		}
	}

	// MARK: - Method Swizzling

	func wtk_viewWillAppear(animated: Bool) {
		self.wtk_viewWillAppear(animated)
		guard let webtrekk = webtrekk else {
			// print("currently no webtrekk attached (\(self.dynamicType))")
			return
		}
		webtrekk.auto("\(self.dynamicType)")
	}
}
```

Zusätzlich zu einfachen Tracken der Klassennamen kann über die Tracker Konfiguration ein Mapping von Klassennamen auf Screennamen erstellt werden, Ausnahmen hinzugefügt werden und sogar zusätzliche Parameter definiert werden. Dies wird über die `AutoTrackedScreens` ermöglicht.

```swift
let homeScreen = AutoTrackedScreen(className: "HomeController", mappingName: "Home")
let detailScreen = AutoTrackedScreen(className: "DetailController", mappingName: "Detail")
webtrekk.autoTrackedScreens = ["HomeScreen": homeScreen, "DetailScreen": detailScreen]
```

## Advertising Identifier

Add the AdSupport Framework to the project

```swift
import AdSupport

let advertiser: () -> String? =  {
	guard ASIdentifierManager.sharedManager().advertisingTrackingEnabled else {
		return nil
	}

	return ASIdentifierManager.sharedManager().advertisingIdentifier.UUIDString
}
webtrekk?.advertisingIdentifier = advertiser
```

# License


MIT

	