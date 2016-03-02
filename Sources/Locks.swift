import Foundation

internal func with(mutex: UnsafeMutablePointer<pthread_mutex_t>, f: Void -> Void) {
	pthread_mutex_lock(mutex)
	f()
	pthread_mutex_unlock(mutex)
}


internal func with(rwlock: UnsafeMutablePointer<pthread_rwlock_t>, f: Void -> Void) {
	pthread_rwlock_rdlock(rwlock)
	f()
	pthread_rwlock_unlock(rwlock)
}


internal func with_write(rwlock: UnsafeMutablePointer<pthread_rwlock_t>, f: Void -> Void) {
	pthread_rwlock_wrlock(rwlock)
	f()
	pthread_rwlock_unlock(rwlock)
}


internal func with(queue: dispatch_queue_t, f: Void -> Void) {
	dispatch_sync(queue, f)
}


internal func with(opQ: NSOperationQueue, f: Void -> Void) {
	let op = NSBlockOperation(block: f)
	opQ.addOperation(op)
	op.waitUntilFinished()
}


internal func with(lock: NSLock, f: Void -> Void) {
	lock.lock()
	f()
	lock.unlock()
}