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


import Foundation


public struct MediaProperties {

	public var bandwidth: Double?    // bit/s
	public var duration: TimeInterval?
	public var groups: [Int: TrackingValue]?
	public var name: String?
	public var position: TimeInterval?
	public var soundIsMuted: Bool?
	public var soundVolume: Double?  // 0 ... 1


	public init(
		name: String?,
		bandwidth: Double? = nil,
		duration: TimeInterval? = nil,
		groups: [Int: TrackingValue]? = nil,
		position: TimeInterval? = nil,
		soundIsMuted: Bool? = nil,
		soundVolume: Double? = nil
	) {
		self.bandwidth = bandwidth
		self.duration = duration
		self.groups = groups
		self.name = name
		self.position = position
		self.soundIsMuted = soundIsMuted
		self.soundVolume = soundVolume
	}

	
	
	internal func merged(over other: MediaProperties) -> MediaProperties {
		return MediaProperties(
			name:         name ?? other.name,
			bandwidth:    bandwidth ?? other.bandwidth,
			duration:     duration ?? other.duration,
			groups:       groups.merged(over: other.groups),
			position:     position ?? other.position,
			soundIsMuted: soundIsMuted ?? other.soundIsMuted,
			soundVolume:  soundVolume ?? other.soundVolume
		)
	}
}
