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
//  Created by Widgetlabs
//


public class GlobalProperties: BaseProperties {
	
	public var crossDeviceProperties: CrossDeviceProperties
	public var variables: [String : String]


	public init(
		actionProperties: ActionProperties = ActionProperties(name: nil),
		advertisementProperties: AdvertisementProperties = AdvertisementProperties(id: nil),
		crossDeviceProperties: CrossDeviceProperties = CrossDeviceProperties(),
		ecommerceProperties: EcommerceProperties = EcommerceProperties(),
		ipAddress: String? = nil,
		mediaProperties: MediaProperties = MediaProperties(name: nil),
		pageProperties: PageProperties = PageProperties(name: nil),
		sessionDetails: [Int: TrackingValue] = [:],
		userProperties: UserProperties = UserProperties(birthday: nil),
		variables: [String : String] = [:]
	) {
        self.crossDeviceProperties = crossDeviceProperties
        self.variables = variables
        super.init(actionProperties: actionProperties, advertisementProperties: advertisementProperties,
                   ecommerceProperties: ecommerceProperties, ipAddress: ipAddress,
                   mediaProperties: mediaProperties, pageProperties: pageProperties,
                   sessionDetails: sessionDetails, userProperties: userProperties)
	}


	
	internal func merged(over other: GlobalProperties) -> GlobalProperties {
		let global = GlobalProperties(
			actionProperties:        actionProperties.merged(over: other.actionProperties),
			advertisementProperties: advertisementProperties.merged(over: other.advertisementProperties),
			crossDeviceProperties:   crossDeviceProperties.merged(over: other.crossDeviceProperties),
			ecommerceProperties:     ecommerceProperties.merged(over: other.ecommerceProperties),
			ipAddress:               ipAddress ?? other.ipAddress,
			mediaProperties:         mediaProperties.merged(over: other.mediaProperties),
			pageProperties:          pageProperties.merged(over: other.pageProperties),
			sessionDetails:          sessionDetails.merged(over: other.sessionDetails),
			userProperties:          userProperties.merged(over: other.userProperties),
			variables:               variables.merged(over: other.variables)
		)
        
        global.trackingParameters = self.trackingParameters ?? other.trackingParameters
        return global
	}
}
