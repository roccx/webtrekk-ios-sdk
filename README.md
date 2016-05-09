Webtrekk iOS SDK
================

Installation
------------

### CococaPods

Installation des SDKs mit Hilfe von [CocoaPods](http://cocoapods.org/):

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'Webtrekk'
```

Kurzanleitung
-------------

Für die Konfiguration und Verwendung des Webtrekk SDKs wird auf die Kombination der Server URL und der Tracking ID gesetzt. Dies sind auch die minimalen Elemente welche konfiguriert werden müssen bevor das SDK verwendet werden kann.

```swift
let config = TrackerConfiguration(serverUrl: "https://yourwebtrekk.domain.plz", trackingId: "123456789012345")
let tracker = Webtrekk(config: config)
```

Ein Tracking Request kann mit einer zuvor initialisierten Instance eines Webtrekk Trackers ganz einfach abgesetzt werden.

```swift
tracker.track(pageName: "MyFirstTrackedPage")
```

Verwendung
----------

Für die Verwendung des Webtrekks SDKs wird zunächst eine grundlegende Konfiguration, basierend auf der Server URL und der Tracking ID, benötigt.

### Tracker Configuration

```swift
let tracker = Webtrekk(config: TrackerConfiguration(serverUrl: "https://yourwebtrekk.domain.plz", trackingId: "123456789012345"))
```

#### Benötigte Angaben

| Option       | Beschreibung                   |
|--------------|--------------------------------|
| `serverUrl`  | Server URL `https://domain.de` |
| `trackingId` | 15 stellige Tracking ID        |

#### Zusätzliche Angaben

| Option                         | Default | Beschreibung                                                                         |
|--------------------------------|---------|--------------------------------------------------------------------------------------|
| `appVersion`                   | `""`    | Manuel gesetzte AppVersion überschreibt automatisch ermittelte.                      |
| `maxRequests`                  | `1000`  | Maxmimale Anzahl an Request in der Warteschlange                                     |
| `samplingRate`                 | `0`     | Jeder n-te Nutzer wird getracked. Deaktiert bei `0` oder `1`                         |
| `sendDelay`                    | `300`   | Abstand zwischen dem Versand von 2 Requests                                          |
| `version`                      | `0`     | Versionsnummer der Konfiguration                                                     |
| `optedOut`                     | `false` | Verhindert das Tracken aufgrund einer Nutzer Entscheidung                            |
| `autoTrack`                    | `true`  | Aktiviert/Deaktiviert alle `autoTrack` Optionen                                      |
| `autoTrackAdvertiserId`        | `true`  | [Advertising Identifier](#advertising-identifier) wird getracked sofern eingerichtet |
| `autoTrackAppUpdate`           | `true`  | Ermittelt ob sich der Versionsname geändert hat und dadurch eine Update passiert ist |
| `autoTrackAppVersionName`      | `true`  | Der Versionsname der App wird getracked                                              |
| `autoTrackAppVersionCode`      | `true`  | Der Versionscode der App wird getracked                                              |
| `autoTrackConnectionType`      | `true`  | Aktuelle Verbindungsart (WLan/Handynetz) wird getracked                              |
| `autoTrackRequestUrlStoreSize` | `true`  | Aktuelle Anzahl an Request in der Warteschlange wird getracked                       |
| `autoTrackScreenOrientation`   | `true`  | Aktuelle Orientierung (Landscape/Portrait) wird getracked                            |
| `enableRemoteConfiguration`    | `false` | Aktiviert die [Remote Config](#remote-config) Option                                 |
| `remoteConfigurationUrl`       | `""`    | Die URL zu einer Konfigurationsdatei                                                 |

### Tracking Parameter

Bei der Verwendung des Webtrekk SDKs unterteilt man beim Tracking die zu verwendenden Requests in die 3 Kategorien Inhalt, Aktion und Media. Dementsprechend werden beim Absetzen von Tracking Requests entsprechend der Kategorie ein `PageTrackingParameter`, `ActionTrackingParameter` oder ein `MediaTrackingParameter` übergeben.

#### Automtisch erstellte Angaben

Alle 3 Kategorien haben stets einen kleinen Anteil gleichbleibender Parameter, diese werden automatisch erzeugt und jedem Request beigefügt.

| Option             | Beschreibung                            |
|--------------------|-----------------------------------------|
| `generalParameter` | [General Parameter](#general-parameter) |
| `pixelParameter`   | [Pixel Parameter](#pixel-parameter)     |

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

#### Zusätzliche Angaben

| Option               | Default                | Beschreibung                                                       |
|----------------------|------------------------|--------------------------------------------------------------------|
| `pageName`           | `""`                   | `pageName` ermöglicht die Zuordnung von Tracking Request zu Screen |
| `pageParameter`      | `PageParameter()`      | [Page Parameter](#page-parameter)                                  |
| `ecommerceParameter` | `nil`                  | [Ecommerce Parameter](#ecommerce-parameter)                        |
| `productParameters`  | `[ProductParameter]()` | [Product Parameter](#product-parameter)                            |
| `customParameter`    | `[String: String]()`   | Selbstdefinierte Parametern [Custom Parameter](#custom-parameter)  |

### Action Tracking

Für das Tracken von Aktionen ein `ActionTrackingParameter` verwendet, dieser kann wie folgt abgesetzt werden

```swift
let actionParameter = ActionParameter(name: "click-test")
let actionTrackingParameter = ActionTrackingParameter(actionParameter: self.actionParameter)
tracker.track(actionTrackingParameter)
```

#### Benötigte Angaben

| Option            | Beschreibung                          |
|-------------------|---------------------------------------|
| `actionParameter` | [Action Parameter](#action-parameter) |

#### Zusätzliche Angaben

| Option               | Default                | Beschreibung                                                      |
|----------------------|------------------------|-------------------------------------------------------------------|
| `ecommerceParameter` | `nil`                  | [Ecommerce Parameter](#ecommerce-parameter)                       |
| `productParameters`  | `[ProductParameter]()` | [Product Parameter](#product-parameter)                           |
| `customParameter`    | `[String: String]()`   | Selbstdefinierte Parametern [Custom Parameter](#custom-parameter) |

### Media Tracking

Für das Tracken von Videos wird ein `MediaTrackingParameter` verwendet, dieser kann wie folgt abgesetzt werden.

```swift
let mediaParameter = MediaParameter(action: .Play, duration: 120, name: "small-trailer.mov", position: 0)
let mediaTrackingParameter = MediaTrackingParameter(mediaParameter: mediaParameter)
tracker.track(mediaTrackingParameter)
```

Media Tracking kann auch komfortabel durch die Verwendung der `WtAvPlayer` Klasse umgesetzt werden.

#### Benötigte Angaben

| Option           | Beschreibung                        |
|------------------|-------------------------------------|
| `mediaParameter` | [Media Parameter](#media-parameter) |

#### Zusätzliche Angaben

| Option            | Default              | Beschreibung                                                      |
|-------------------|----------------------|-------------------------------------------------------------------|
| `customParameter` | `[String: String]()` | Selbstdefinierte Parametern [Custom Parameter](#custom-parameter) |

Parameter Erklärung
-------------------

### Page Parameter

```swift
let pageParameter = PageParameter()
```

#### Optional settings

| Option       | Default           | Beschreibung                         |
|--------------|-------------------|--------------------------------------|
| `page`       | `[Int: String]()` | Seiten Parameter `cp1=""`, `cp2=""`  |
| `categories` | `[Int: String]()` | Seiten Kategorien `cg1=""`, `cg2=""` |
| `session`    | `[Int: String]()` | Session Parameter `cs1=""`, `cs2=""` |

### General Parameter

Der `General Parameter` ist ein automatisch generierter Parameter.

#### Settings

| Option           | Beschreibung               |
|------------------|----------------------------|
| `everId`         |                            |
| `firstStart`     | Erster Start der App       |
| `ip`             |                            |
| `nationalCode`   | Landeskennung z.B. `de_DE` |
| `samplingRate`   |                            |
| `timeStamp`      |                            |
| `timeZoneOffset` |                            |
| `userAgent`      |                            |

### Pixel Parameter

#### Settings

| Option        | Description |
|---------------|-------------|
| `version`     |             |
| `pageName`    |             |
| `displaySize` |             |
| `timeStamp`   |             |

### Product Parameter

#### Mandatory settings

| Option        | Description |
|---------------|-------------|
| `productName` |             |

#### Optional settings

| Option       | Default           | Description |
|--------------|-------------------|-------------|
| `categories` | `[Int: String]()` |             |
| `currency`   | `""`              |             |
| `price`      | `""`              |             |
| `quantity`   | `""`              |             |

### Ecommerce Parameter

#### Mandatory settings

| Option       | Description |
|--------------|-------------|
| `totalValue` |             |

#### Optional settings

| Option         | Default                | Description |
|----------------|------------------------|-------------|
| `categories`   | `[Int: String]()`      |             |
| `currency`     | `""`                   |             |
| `orderNumber`  | `""`                   |             |
| `voucherValue` | `nil`                  |             |
| `status`       | `EcommerceStatus.VIEW` |             |

### Ecommerce Status

#### Settings

| Option | Description |
|--------|-------------|
| `ADD`  |             |
| `CONF` |             |
| `VIEW` |             |

Automatisches Screen Tracking
-----------------------------

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

Advertising Identifier
----------------------

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

License
=======

MIT
