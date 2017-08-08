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


internal final class DefaultMediaTracker: MediaTracker {

	private let handler: MediaEventHandler

	internal var mediaProperties: MediaProperties
	internal var pageName: String?
    internal var variables : [String : String]
	internal var viewControllerType: AnyObject.Type?


    internal init(handler: MediaEventHandler, mediaName: String, pageName: String?, mediaProperties: MediaProperties?, variables: [String : String]?) {
        checkIsOnMainThread()
        
        self.handler = handler
        self.mediaProperties = mediaProperties ?? MediaProperties(name: mediaName)
        self.pageName = pageName
        self.variables = variables ?? [String : String]()
    }

	internal func trackAction(_ action: MediaEvent.Action) {
		checkIsOnMainThread()

		let event = MediaEvent(
			action:          action,
			mediaProperties: mediaProperties,
			pageName:        pageName,
			variables:       variables
		)
		event.viewControllerType = viewControllerType

		handler.handleEvent(event)
	}
}
