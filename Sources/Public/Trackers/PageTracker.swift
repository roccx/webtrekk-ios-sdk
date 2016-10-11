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


#if !os(watchOS)
	import AVFoundation
#endif


public protocol PageTracker: class {

	var advertisementProperties: AdvertisementProperties { get set }
	var ecommerceProperties: EcommerceProperties { get set }
	var pageProperties: PageProperties { get set }
	var sessionDetails: [Int: TrackingValue] { get set }
	var userProperties: UserProperties { get set }
	var variables: [String : String] { get set }


	func trackAction(_ actionName: String)
	
	func trackAction(_ event: ActionEvent)

	func trackMediaAction(_ event: MediaEvent)

	func trackPageView()

	func trackPageView(_ pageViewEvent: PageViewEvent)

	
	func trackerForMedia(_ mediaName: String) -> MediaTracker

	#if !os(watchOS)
	func trackerForMedia(_ mediaName: String, automaticallyTrackingPlayer player: AVPlayer) -> MediaTracker
	#endif
}


public extension PageTracker {

	public func trackAction(_ actionName: String) {
		trackAction(ActionEvent(actionProperties: ActionProperties(name: actionName), pageProperties: pageProperties))
	}
    
    public subscript(key: String) -> String? {
        get {
            return variables[key]
        }
        set {
            variables[key] = newValue
        }
    }

}
