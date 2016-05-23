import Foundation

internal class Queue<T> {

	internal var array: Array<T>

	internal typealias Element = T

	internal var itemCount: Int {
		return array.count
	}

	internal init () {
		self.array = Array<T>()
	}

	/// Add a item to the back of the queue.
	internal func enqueue (value: Element) {
		array.append(value)
	}

	/// Return and remove the item at the front of the queue.
	internal func dequeue () -> Element? {
		guard !array.isEmpty else {
			return nil
		}
		return array.removeFirst()
	}

	internal func peek() -> Element? {
		guard !array.isEmpty, let firstItem = array.first else {
			return nil
		}
		return firstItem
	}

	internal func isEmpty() -> Bool {
		return array.isEmpty
	}
}

internal class QueueItem<T> {
	internal let value: T!
	internal var next: QueueItem?

	internal init(_ newvalue: T?) {
		self.value = newvalue
	}
}