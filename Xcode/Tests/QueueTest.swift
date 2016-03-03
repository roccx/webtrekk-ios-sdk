import XCTest

@testable import Webtrekk

class QueueTest: XCTestCase {

	// MARK: String Tests

	func testAddOneStringItem() {
		let stringQueue = Queue<String>()
		stringQueue.enqueue("Item")
	}

	func testAddMultipleStringItems() {
		let stringQueue = Queue<String>()
		for index in 0..<10 {
			stringQueue.enqueue("Item \(index)")
		}
		XCTAssertFalse(stringQueue.isEmpty())
	}


	func testRemoveOneStringItem() {
		let stringQueue = Queue<String>()
		XCTAssert(stringQueue.itemCount == 0)
		for index in 0..<10 {
			stringQueue.enqueue("Item \(index)")
			XCTAssert(stringQueue.itemCount == index+1)
		}
		let firstItem = stringQueue.dequeue()
		XCTAssertNotNil(firstItem)
		XCTAssertEqual(firstItem!, "Item 0")
	}


	func testRemoveAllStringItems() {
		let stringQueue = Queue<String>()
		XCTAssert(stringQueue.itemCount == 0)
		for index in 0..<10 {
			stringQueue.enqueue("Item \(index)")
			XCTAssert(stringQueue.itemCount == index+1)
		}
		XCTAssertFalse(stringQueue.isEmpty())
		for index in 0..<10 {
			XCTAssertEqual(stringQueue.dequeue()!, "Item \(index)")
			XCTAssert(stringQueue.itemCount == 9 - index)
		}
		XCTAssertTrue(stringQueue.isEmpty())
	}

	func testRemoveAllStringItemsTillEmpty() {
		let stringQueue = Queue<String>()
		XCTAssert(stringQueue.itemCount == 0)
		for index in 0..<10 {
			stringQueue.enqueue("Item \(index)")
			XCTAssert(stringQueue.itemCount == index+1)
		}
		XCTAssertFalse(stringQueue.isEmpty())
		while(stringQueue.itemCount > 0) {
			XCTAssertNotNil(stringQueue.dequeue()!)
		}
		XCTAssertTrue(stringQueue.isEmpty())
	}


	// MARK: Int Tests
	func testAddOneIntItem() {
		let intQueue = Queue<Int>()
		intQueue.enqueue(1)
	}


	func testAddMultipleIntItems() {
		let intQueue = Queue<Int>()
		for index in 0..<10 {
			intQueue.enqueue(index)
		}
		XCTAssertFalse(intQueue.isEmpty())
	}
	
	
	func testRemoveOneIntItem() {
		let intQueue = Queue<Int>()
		for index in 0..<10 {
			intQueue.enqueue(index)
		}
		let firstItem = intQueue.dequeue()
		XCTAssertNotNil(firstItem)
		XCTAssertEqual(firstItem!, 0)
	}


	func testRemoveAllIntItems() {
		let intQueue = Queue<Int>()
		for index in 0..<10 {
			intQueue.enqueue(index)
		}
		XCTAssertFalse(intQueue.isEmpty())
		for index in 0..<10 {
			XCTAssertEqual(intQueue.dequeue()!, index)
		}
		XCTAssertTrue(intQueue.isEmpty())
	}

	// MARK: general function

	func testAddNillItem() {
		let queue = Queue<Int?>()
		queue.enqueue(nil)
		let zero = queue.dequeue()!
		XCTAssertNil(zero)

		queue.enqueue(1)
		queue.enqueue(nil)
		queue.enqueue(3)
		let first = queue.dequeue()!!
		let second = queue.dequeue()!
		let third = queue.dequeue()!!
		XCTAssertEqual(first, 1)
		XCTAssertNil(second)
		XCTAssertEqual(third, 3)
	}

	func testRemoveAfterEmpty() {
		let intQueue = Queue<Int>()
		for index in 0..<10 {
			intQueue.enqueue(index)
		}
		XCTAssertFalse(intQueue.isEmpty())
		for index in 0..<10 {
			XCTAssertEqual(intQueue.dequeue()!, index)
		}
		XCTAssertTrue(intQueue.isEmpty())
		XCTAssertNil(intQueue.dequeue())
	}

	func testConcurrency() {
		let queue = Queue<Int>()
		let numberofiterations = 2_000_00

		let addingexpectation = expectationWithDescription("adding completed")
		let addingqueue = dispatch_queue_create( "adding", DISPATCH_QUEUE_SERIAL)
		dispatch_async(addingqueue)  {
			for i in  1...numberofiterations {
				queue.enqueue(i)
			}
			addingexpectation.fulfill()
		}

		let deletingexpectation = expectationWithDescription("deleting completed")
		let deletingqueue = dispatch_queue_create( "deleting", DISPATCH_QUEUE_SERIAL)
		dispatch_async(deletingqueue)  {
			var adding = 1
			for i in 0..<numberofiterations {
				if let result = queue.dequeue() {
					XCTAssertEqual(result, i + adding)
				} else {
					print(" pausing deleting for one second")
					sleep(CUnsignedInt(1))
					adding -= 1
				}
			}
			deletingexpectation.fulfill()
		}

		waitForExpectationsWithTimeout( 600, handler:  nil)
	}

	func testPeek() {
		let intQueue = Queue<Int>()
		for index in 0..<10 {
			intQueue.enqueue(index)
		}
		for index in 0..<10 {
			XCTAssertEqual(intQueue.peek()!, intQueue.dequeue()!)
		}
	}

}