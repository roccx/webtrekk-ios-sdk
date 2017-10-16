//The MIT License (MIT)
//
//Copyright (c) 2016 Webtrekk GmbH
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
//"Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
//distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject
//to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Created by arsen.vartbaronov on 13/10/17.
//

#import <Foundation/Foundation.h>

#import "SetV2EverID.h"

@implementation SetV2EverID

-(NSString*)createEverIDLikeV2{
    NSString* everId;
    BOOL      isFirstSession;
    
    NSFileManager* fileManager = NSFileManager.defaultManager;
    
    NSURL* fileUrl    = [[fileManager URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:FALSE error:NULL] URLByAppendingPathComponent:@"webtrekk-id"];
    NSURL* oldFileUrl = [[fileManager URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:FALSE error:NULL] URLByAppendingPathComponent:@"webtrekk-id"];
    
    if ([fileManager fileExistsAtPath:oldFileUrl.path]) {
        [fileManager removeItemAtURL:fileUrl error:NULL];
        [fileManager moveItemAtURL:oldFileUrl toURL:fileUrl error:NULL];
    }
    
    everId = [NSString stringWithContentsOfURL:fileUrl encoding:NSUTF8StringEncoding error:NULL];
    if (everId.length == 0) {
        everId = [NSString stringWithFormat:@"%06u%06u%07u", arc4random() % 1000000, arc4random() % 1000000, arc4random() % 10000000];
        [everId writeToURL:fileUrl atomically:TRUE encoding:NSUTF8StringEncoding error:NULL];
        
        isFirstSession = TRUE;
    }
    else {
        isFirstSession = FALSE;
    }
    
    return everId;
}

@end
