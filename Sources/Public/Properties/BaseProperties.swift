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
//  Created by arsen.vartbaronov on 15/09/16.
//
//

import Foundation
/** base class for properties */
public class BaseProperties {

    public var actionProperties: ActionProperties
    public var advertisementProperties: AdvertisementProperties
    public var ecommerceProperties: EcommerceProperties
    public var ipAddress: String?
    public var mediaProperties: MediaProperties
    public var pageProperties: PageProperties
    public var sessionDetails: [Int: TrackingValue]
    public var userProperties: UserProperties
    var trackingParameters: TrackingParameter?
    
    public init(
        actionProperties: ActionProperties = ActionProperties(name: nil),
        advertisementProperties: AdvertisementProperties = AdvertisementProperties(id: nil),
        ecommerceProperties: EcommerceProperties = EcommerceProperties(),
        ipAddress: String? = nil,
        mediaProperties: MediaProperties = MediaProperties(name: nil),
        pageProperties: PageProperties = PageProperties(name: nil),
        sessionDetails: [Int: TrackingValue] = [:],
        userProperties: UserProperties = UserProperties(birthday: nil)
        ) {
        self.actionProperties = actionProperties
        self.advertisementProperties = advertisementProperties
        self.ecommerceProperties = ecommerceProperties
        self.ipAddress = ipAddress
        self.mediaProperties = mediaProperties
        self.pageProperties = pageProperties
        self.sessionDetails = sessionDetails
        self.userProperties = userProperties
    }
}
