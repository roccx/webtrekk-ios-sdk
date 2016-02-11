import Foundation

internal class Queue<T> {

	internal typealias Element = T

	internal var _front: _QueueItem<Element>
	internal var _back: _QueueItem<Element>

	internal init () {
		// Insert empty item. Will disappear when the first item is added.
		_back = _QueueItem(nil)
		_front = _back
	}

	/// Add a item to the back of the queue.
	internal func enqueue (value: Element) {
		_back.next = _QueueItem(value)
		_back = _back.next!
	}

	/// Return and remove the item at the front of the queue.
	internal func dequeue () -> Element? {
		if let newhead = _front.next {
			_front = newhead
			return newhead.value
		} else {
			return nil
		}
	}

	internal func isEmpty() -> Bool {
		return _front === _back
	}
}

internal class _QueueItem<T> {
	internal let value: T!
	internal var next: _QueueItem?

	internal init(_ newvalue: T?) {
		self.value = newvalue
	}
}