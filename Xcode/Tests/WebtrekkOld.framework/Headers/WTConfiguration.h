//
//  Webtrekk Library: Configuration holder object
//

#import <Foundation/Foundation.h>


@interface WTConfiguration : NSObject

@property(nonatomic,copy,readonly)                  NSURL*          serverUrl;
@property(nonatomic,copy,readonly)                  NSString*       trackId;
@property(nonatomic)                                NSUInteger      samplingRate;
@property(nonatomic)                                NSTimeInterval  sendDelay;
@property(nonatomic,copy)                           NSString*       appVersionParameter;
@property(nonatomic,getter=isUsingAdIdentifier)     BOOL            useAdIdentifier;

-(instancetype)initWithServerUrl:(NSURL*) serverUrl trackId:(NSString*) trackId;

-(void)crossDeviceDataAddEmail:(NSString*) email;
-(void)crossDeviceDataAddEmailAsMD5:(NSString*) md5;
-(void)crossDeviceDataAddEmailAsSHA256:(NSString*) sha256;

-(void)crossDeviceDataAddPhoneNumber:(NSString*) phoneNumber;
-(void)crossDeviceDataAddPhoneNumberAsMD5:(NSString*) md5;
-(void)crossDeviceDataAddPhoneNumberAsSHA256:(NSString*) sha256;

-(void)crossDeviceDataAddAddressFirstName:(NSString*)firstName lastName:(NSString*)lastName postalCode:(NSString*)postalCode street:(NSString*)street streetNumber:(NSString*)streetNumber;
-(void)crossDeviceDataAddressAddAsMD5:(NSString*) md5;
-(void)crossDeviceDataAddressAddAsSHA256:(NSString*) sha56;

-(void)crossDeviceDataAddFacebookId:(NSString*) fId;
-(void)crossDeviceDataAddTwitterId:(NSString*) tId;
-(void)crossDeviceDataAddLinkedInId:(NSString*) lId;
-(void)crossDeviceDataAddGooglePlusId:(NSString*) gId;

-(void)clearCrossDeviceData;

-(NSDictionary*)getCrossDeviceDictionary;

@end
