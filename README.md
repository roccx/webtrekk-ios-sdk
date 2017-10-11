Webtrekk Tracking Library for Swift
===================================


The Webtrekk SDK allows you to track user activities, screen flow and media usage for an App. All data is send to the Webtrekk tracking system for further analysis.

Requirements
============

| Plattform | Version            |
|-----------|-------------------:|
| `iOS`     |             `8.0+` |
| `tvOS`    |             `9.0+` |
| `watchOs` |             `2.0+` |

Xcode 7.3+ and Swift 2.2 for versions below and equal to 4.0.1

Xcode 8.0+ and Swift 3.0 starting with version 4.1.0

Xcode 8.3+ and Swift 3.1 starting with version 4.5.1

Starting with version 4.7.0 library can be included and compiled with XCode 9.0 beta6.

Xcode 9.0+ and Swift 4.0 starting with version 4.8.0

tvOS support starting with version 4.2.0 with the following limitation:
No screen resolution and network status automatic tracing support.

watchOS support starting with version 4.3.0 with the following limiations:
1. No screen resolution and network status automatic trackinging support.
2. No deep link and campaign support.

Carthage support starting from version 4.6.0


Installation
============

Using [CocoaPods](htttp://cocoapods.org) the installation of the Webtrekk SDK is done by simply adding it to your project's `Podfile`:

pod 'Webtrekk'

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

As of iOS 9 Apple is more strictly enforcing the usage of the SSL for network connections. Webtrekk highly recommends and offers the usage of a valid serverUrl with SSL support. In case there is a need to circumvent this the App needs an exception entry within the `Info.plist` this and the regulation Apple bestows upon that are well documented within the [iOS Developer Library](https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html#//apple_ref/doc/uid/TP40009251-SW33)

Examples & Unit Tests
=====================

The `Xcode` directory contains all files necessary to

-	manually build the library
-	run unit test
-	run examples

```shell
# install CocoaPods 1.2.0 or newer (unless you already did)
sudo gem install cocoapods

# clone this repository
https://github.com/Webtrekk/webtrekk-ios-sdk.git

# examples & tests are located in the directory 'Xcode' …
cd Xcode

# … and are set up with CocoaPods
pod install

# 'Examples.xcworkspace' is the file you'll use from now on
open Examples.xcworkspace
```
