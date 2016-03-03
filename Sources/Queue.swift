import Foundation

internal class Queue<T> {

	internal typealias Element = T

	internal var front: QueueItem<Element>
	internal var back: QueueItem<Element>

	internal var itemCount = 0

	internal init () {
		// Insert empty item. Will disappear when the first item is added.
		back = QueueItem(nil)
		front = back
	}

	/// Add a item to the back of the queue.
	internal func enqueue (value: Element) {
		back.next = QueueItem(value)
		back = back.next!
		itemCount += 1
	}

	/// Return and remove the item at the front of the queue.
	internal func dequeue () -> Element? {
		if let newhead = front.next {
			front = newhead
			itemCount -= 1
			return newhead.value
		} else {
			return nil
		}
	}

	internal func peek() -> Element? {
		if let newhead = front.next {
			return newhead.value
		} else {
			return nil
		}
	}

	internal func isEmpty() -> Bool {
		return front === back
	}
}

internal class QueueItem<T> {
	internal let value: T!
	internal var next: QueueItem?

	internal init(_ newvalue: T?) {
		self.value = newvalue
	}
}