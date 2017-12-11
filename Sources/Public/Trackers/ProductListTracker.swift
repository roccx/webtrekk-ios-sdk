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
//  Created by arsen.vartbaronov on 29/11/16.
//
//

import Foundation
import UIKit

#if os(watchOS)
import WatchKit
#endif

public protocol ProductListTracker: class {
    /** add products to be tracked. Can be called several times. It isn't time consuming operation. Can be called during scrolling monitor.*/
    func addTrackingData(products: [EcommerceProperties.Product], type: EcommerceProperties.Status)
    
    /** track all data that was added by addTrackingData calls
     commonProperties - properties that are common for all products (like order status)
     viewController - if you use automatic tracking it defines page name(content Id) based on you ViewController
     */
    #if !os(watchOS)
        func track(commonProperties: PageViewEvent, viewController: UIViewController?)
    #else
        func track(commonProperties: PageViewEvent, viewController: WKInterfaceController?)
    #endif
}
/** that is extension to make possible optional parameter viewController for track*/
public extension ProductListTracker {
    
    #if !os(watchOS)
    func track(commonProperties: PageViewEvent, viewController: UIViewController? = nil){
        self.track(commonProperties: commonProperties, viewController: viewController)
    }
    #else
    func track(commonProperties: PageViewEvent, viewController: WKInterfaceController? = nil){
        self.track(commonProperties: commonProperties, viewController: viewController)
    }
    #endif
}
