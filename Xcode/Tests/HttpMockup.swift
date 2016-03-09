import Foundation
import Webtrekk

internal class MockUrlSession: UrlSessionProtocol {
	var nextDataTask = MockUrlSessionDataTask()
	private(set) var lastUrl: NSURL?

	func dataTaskWithURL(url: NSURL, completionHandler: DataTaskResult) -> UrlSessionDataTaskProtocol {
		lastUrl = url
		return nextDataTask
	}
}


internal class MockUrlSessionDataTask: UrlSessionDataTaskProtocol {
	private(set) var resumeWasCalled = false

	func resume() {
		resumeWasCalled = true
	}
}