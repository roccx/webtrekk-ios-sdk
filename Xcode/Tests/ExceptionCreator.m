//
//  ExceptionCreator.m
//  Examples
//
//  Created by arsen.vartbaronov on 13/02/17.
//  Copyright © 2017 Webtrekk. All rights reserved.
//

#import "ExceptionCreator.h"

@implementation ExceptionCreator

-(void)throwCocoaPod{
    NSException* myException = [NSException
                                exceptionWithName:@"Example_of_uncatched_exception"
                                reason:@"Just_for_test"
                                userInfo:@{@"Key1" : @"Value1", @"Key2" : @"Value2"}];
    @throw myException;
}

-(void)throwNSError{
    NSError* myException = [NSError
                                errorWithDomain:@"Example_of_NSError_exception"
                                code:5
                                userInfo:@{@"KeyNSError1" : @"Value1", @"Key2" : @"Value2"}];
    @throw myException;
}
@end
