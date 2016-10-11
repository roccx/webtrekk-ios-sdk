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


/**
The `TrackerPlugin` gets invoked regardless the OptOut state right before the `TrackerRequest` is enqueued for delivery and can edit the request before.

After the `TrackerRequest` should have been enqueued the `TrackerPlugin` gets another chances to handle the request.

As the `TrackerPlugin` is always called it is for the plugin to keep track of the OptOut state which can be obtained like this
```
let isOptOut = WebtrekkTracking.isOptedOuts
```
*/
public protocol TrackerPlugin: class {

	/** Handle the `TrackerRequest` before it is enqueued for delivery. */
	func tracker (_ tracker: Tracker, requestForQueuingRequest request: TrackerRequest) -> TrackerRequest
	/** Handle the `TrackerRequest` after it was enqueued. */
	func tracker (_ tracker: Tracker, didQueueRequest request: TrackerRequest)
}
