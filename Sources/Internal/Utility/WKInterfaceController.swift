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
//  Created by arsen.vartbaronov on 09/11/16.
//

import WatchKit

internal extension WKInterfaceController {
    
    private static var isSwizzled = false
    private static var autoTrackerKey = UInt8()
    
    internal var automaticTracker: PageTracker {
        return objc_getAssociatedObject(self, &WKInterfaceController.autoTrackerKey) as? PageTracker ?? {
            let tracker = DefaultPageTracker(handler: DefaultTracker.autotrackingEventHandler, viewControllerType: type(of: self))
            objc_setAssociatedObject(self, &WKInterfaceController.autoTrackerKey, tracker, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return tracker
            }()
    }
    
    internal static func setUpAutomaticTracking() {
        guard !isSwizzled else {
            return
        }
        
        isSwizzled = true
        
        let _ = swizzleMethod(ofType: WKInterfaceController.self, fromSelector: #selector(willActivate), toSelector: #selector(wtWillActivate))
    }
    
    
    dynamic func wtWillActivate(){
        self.wtWillActivate()
        
        guard WebtrekkTracking.isInitialized() else {
            return
        }
        
        let tracker = WebtrekkTracking.instance() as! DefaultTracker
        if tracker.isApplicationActive {
            automaticTracker.trackPageView()
        }
    }
}
