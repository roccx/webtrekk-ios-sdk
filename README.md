# Webtrekk


## Minimal Configuration


```swift
let config = TrackerConfiguration(serverUrl: "https://yourwebtrekk.domain.plz", trackingId: "123456789012345")
let tracker = Webtrekk(config: config)
tracker.track(pageName: "MyFirstTrackedPage")
```

```swift
let tracker = Webtrekk(config: TrackerConfiguration(serverUrl: "https://yourwebtrekk.domain.plz", trackingId: "123456789012345"))
tracker.track(pageName: "TestPage")
```

## Tracker Configuration

```swift
let tracker = Webtrekk(config: TrackerConfiguration(serverUrl: "https://yourwebtrekk.domain.plz", trackingId: "123456789012345"))
```
### Mandatory settings

Option      | Description
------------|------------
`serverUrl` | 
`trackingId`| 

### Optional settings

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

## Page Tracking

```swift
let tracker = Webtrekk(config: TrackerConfiguration(serverUrl: "https://yourwebtrekk.domain.plz", trackingId: "123456789012345"))
let pageTrackingParameter = PageTrackingParameter(pageName: "TestPage")
tracker.track(pageTrackingParameter)
```

### Optional settings

Option                 | Default                | Description
-----------------------|------------------------|-------------
`pageName`             | `""`                   |
`pageParameter`        | `PageParameter()`      |
`ecommerceParameter`   | `nil`                  |
`productParameters`    | `[ProductParameter]()` |

### Computed settings

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


## Automatic Screen Tracking

Assuming `webtrekk` as global variable for the Webtrekk Tracker

```swift
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

After `webtrekk` init add the AutoTrackedScreens and lean back

```swift
let homeScreen = AutoTrackedScreen(className: "HomeController", mappingName: "Home")
let detailScreen = AutoTrackedScreen(className: "DetailController", mappingName: "Detail")
webtrekk.autoTrackedScreens = ["HomeScreen": homeScreen, "DetailScreen": detailScreen]
```

## Advertising Identifier

```swift
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

	