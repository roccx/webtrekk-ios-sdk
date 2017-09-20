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
//  Created by arsen.vartbaronov on 07/09/16.
//

import UIKit

class DeepLink: NSObject{
    
    private let sharedDefaults = UserDefaults.standardDefaults.child(namespace: "webtrekk")
    static let savedDeepLinkMediaCode = "mediaCodeForDeepLink"
    
    // add wt_application to delegation class in runtime and switch implementation with application func
    @nonobjc
    func deepLinkInit(){
        let replacedSel = #selector(wt_application(_:continue:restorationHandler:))
        let originalSel = #selector(UIApplicationDelegate.application(_:continue:restorationHandler:))
        
        // get class of delegate instance
        guard let delegate = UIApplication.shared.delegate,
              let delegateClass = object_getClass(delegate) else {
            return
        }
        
        if !replaceImplementationFromAnotherClass(toClass: delegateClass, methodChanged: originalSel, fromClass: DeepLink.self, methodAdded: replacedSel) {
            logError("Deep link functionality initialization error.")
        }
    }
    
    // method that replaces application in delegate
    @objc dynamic func wt_application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                                          restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        
        // test if this is deep link
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb,
                let url = userActivity.webpageURL,
                let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                let queryItems = components.queryItems{
            
            WebtrekkTracking.defaultLogger.logDebug("Deep link is received")
            
            // as this implementation is added to another class with swizzle we can't use local parameters
            let track = WebtrekkTracking.instance()
            
            //loop for all parameters
            for queryItem in queryItems {
                //if parameter is everID set it
                if queryItem.name == "wt_everID" {
                    
                    if let value = queryItem.value  {
                        // check if ever id has correct format 19 digits.
                        if let isMatched = value.isMatchForRegularExpression("\\d{19}") , isMatched {
                            track.everId = value
                            WebtrekkTracking.defaultLogger.logDebug("Ever id from Deep link is set")
                        } else {
                            WebtrekkTracking.defaultLogger.logError("Incorrect everid: \(queryItem.value.simpleDescription)")
                        }
                    } else {
                      WebtrekkTracking.defaultLogger.logError("Everid is empty in request")
                    }
                }
                //if parameter is media code set it
                if queryItem.name == "wt_mediaCode", let value = queryItem.value {
                    track.mediaCode = value
                    WebtrekkTracking.defaultLogger.logDebug("Media code from Deep link is set")
                }
            }
        }
        if class_respondsToSelector(object_getClass(self), #selector(wt_application(_:continue:restorationHandler:))) {
            return self.wt_application(application, continue: userActivity, restorationHandler: restorationHandler)
        } else {
            return true
        }
    }
    
    // returns media code and delete it from settings
    func getAndDeletSavedDeepLinkMediaCode() -> String?{
        let mediaCode = self.sharedDefaults.stringForKey(DeepLink.savedDeepLinkMediaCode)
        
        if let _ = mediaCode {
            self.sharedDefaults.remove(key: DeepLink.savedDeepLinkMediaCode)
        }
        
        return mediaCode
    }
    
    //save media code to settings
    func setMediaCode(_ mediaCode: String)
    {
        self.sharedDefaults.set(key: DeepLink.savedDeepLinkMediaCode, to: mediaCode)
    }

}
