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


public struct PageProperties {

	public var details: [Int: TrackingValue]?
	public var groups: [Int: TrackingValue]?
	public var name: String?
	public var internalSearch: String?
	public var viewControllerType: AnyObject.Type?
    public var url: String? {
        didSet {
            if !isURLCanBeSet(self.url) {
                printInvalidURL(self.url!)
            }
        }
    }
	
    public init(
		name: String?,
		details: [Int: TrackingValue]? = nil,
		groups: [Int: TrackingValue]? = nil,
		internalSearch: String? = nil,
		url: String? = nil
	) {
		self.details = details
		self.groups = groups
		self.name = name
		self.internalSearch = internalSearch
        setUpURL(url: url)
	}


	public init(
		viewControllerType: AnyObject.Type?,
		details: [Int: TrackingValue]? = nil,
		groups: [Int: TrackingValue]? = nil,
		internalSearch: String? = nil,
		url: String? = nil
	) {
		self.details = details
		self.groups = groups
		self.internalSearch = internalSearch
		setUpURL(url: url)
		self.viewControllerType = viewControllerType
	}
    
    
    internal func merged(over other: PageProperties) -> PageProperties {
		var new = self
		new.details = details.merged(over: other.details)
		new.groups = groups.merged(over: other.groups)
		new.name = name ?? other.name
        new.internalSearch = internalSearch ?? other.internalSearch
		new.viewControllerType = viewControllerType ?? other.viewControllerType
		new.url = url ?? other.url
		return new
	}
    
    mutating private func setUpURL(url: String?){
    
    if isURLCanBeSet(url) {
        self.url = url
    } else {
        printInvalidURL(url!)
    }
    }
    
    fileprivate func isURLCanBeSet(_ url: String?) -> Bool {
       return url == nil || url!.isValidURL()
    }
    
    fileprivate func printInvalidURL(_ url: String) {
        WebtrekkTracking.defaultLogger.logError("Invalid URL \(url) for pu parameter")
    }
}
