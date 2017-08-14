// Webtrekk Library 3.0.1 beta (2015-07-13)

#import <Foundation/Foundation.h>

#import "MPMoviePlayerController+Webtrekk.h"
#import "WTConfiguration.h"
#import "WTMediaCategories.h"

@interface Webtrekk : NSObject

// starts the tracking. should only be called once in your delegate method application:didFinishLaunchingWithOptions:
+(void) startWithServerUrl: (NSURL*)serverUrl trackId:(NSString*)trackId;
+(void) startWithServerUrl: (NSURL*)serverUrl trackId:(NSString*)trackId samplingRate:(NSUInteger)samplingRate;
+(void) startWithServerUrl: (NSURL*)serverUrl trackId:(NSString*)trackId samplingRate:(NSUInteger)samplingRate sendDelay:(NSTimeInterval)sendDelay;
+(void) startWithServerUrl: (NSURL*)serverUrl trackId:(NSString*)trackId samplingRate:(NSUInteger)samplingRate sendDelay:(NSTimeInterval)sendDelay appVersionParameter:(NSString*)appVersionParameter;

+(void) startWithConfiguration: (WTConfiguration*) config;

// stops the tracking. you usually don't need to and should not call this.
+(void) stop;

// tracking methods
+(void) trackClick:   (NSString*)clickId contentId:(NSString*)contentId;
+(void) trackClick:   (NSString*)clickId contentId:(NSString*)contentId additionalParameters:(NSDictionary*)additionalParameters;
+(void) trackContent: (NSString*)contentId;
+(void) trackContent: (NSString*)contentId additionalParameters:(NSDictionary*)additionalParameters;

// allows the user to opt out of tracking
+(BOOL) optedOut;
+(void) setOptedOut: (BOOL)optedOut;

// ever id for the current app installation (does not require a tracking session to be started)
+(NSString*) everId;

// library version
+(NSString*) version;

//if the App is updated or not
+(BOOL) isThisVersionAnUpdate;

// App Version version
+(NSString*) appVersionParameter;
+(void) setAppVersionParameter:(NSString*)appVersionParameter ;


// ad identifier

+(BOOL) isUsingAdIdentifier;
+(void) useAdIdentifier: (BOOL)useAdIdentifier;

// cross device bridge
+(void)addCrossDeviceDataEmail:(NSString*) email;
+(void)addCrossDeviceDataEmailAsMD5:(NSString*) md5;
+(void)addCrossDeviceDataEmailAsSHA256:(NSString*) sha256;


+(void)addCrossDeviceDataPhoneNumber:(NSString*) phoneNumber;
+(void)addCrossDeviceDataPhoneNumberAsMD5:(NSString*) md5;
+(void)addCrossDeviceDataPhoneNumberAsSHA256:(NSString*) sha256;

+(void)addCrossDeviceDataAddressFirstName:(NSString*)firstName lastName:(NSString*)lastName postalCode:(NSString*)postalCode street:(NSString*)street streetNumber:(NSString*)streetNumber;
+(void)addCrossDeviceDataAddressAsMD5:(NSString*) md5;
+(void)addCrossDeviceDataAddressAsSHA256:(NSString*) sha56;

+(void)addCrossDeviceDataFacebookId:(NSString*) facebookId;
+(void)addCrossDeviceDataTwitterId:(NSString*) twitterId;
+(void)addCrossDeviceDataLinkedInId:(NSString*) linkedInId;
+(void)addCrossDeviceDataGooglePlusId:(NSString*) googlePlusId;

+(void)clearCrossDeviceData;

@end

// Library developed by Widgetlabs
