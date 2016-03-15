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






# License


MIT

	