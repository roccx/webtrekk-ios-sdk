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

import UIKit


public class MediaEvent: TrackingEventWithMediaProperties {

	public var action: Action
	public var ipAddress: String?
	public var mediaProperties: MediaProperties
	public var pageName: String?
	public var variables: [String : String]
	public var viewControllerType: AnyObject.Type?


	public init(
		action: Action,
		mediaProperties: MediaProperties,
		pageName: String?,
		variables: [String : String] = [:]
	) {
		self.action = action
		self.mediaProperties = mediaProperties
		self.pageName = pageName
		self.variables = variables
	}


	public init(
		action: Action,
		mediaProperties: MediaProperties,
		viewControllerType: AnyObject.Type?,
		variables: [String : String] = [:]
	) {
		self.action = action
		self.mediaProperties = mediaProperties
		self.variables = variables
		self.viewControllerType = viewControllerType
	}



	public enum Action {

		case finish
		case initialize
		case pause
		case play
		case position
		case seek
		case stop
		case custom(name: String)
	}
}
