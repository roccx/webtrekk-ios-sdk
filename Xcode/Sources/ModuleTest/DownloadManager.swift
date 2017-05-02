import Foundation

class DownloadManager : NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    
    static var shared = DownloadManager()
    
    override private init() {
        super.init()
    }
    
    func start() {
        let config = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).backgroundTest")
        
        // Warning: If an URLSession still exists from a previous download, it doesn't create a new URLSession object but returns the existing one with the old delegate object attached!
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        
        let url = URL(string: "http://download.thinkbroadband.com/50MB.zip")!
        
        try? FileManager.default.removeItem(at: url)
        let task = session.downloadTask(with: url)
        task.resume()
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        NSLog("Download task in progress. Expected to write \(Int((totalBytesExpectedToWrite - totalBytesWritten)/1024))")
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        NSLog("Download task is finished")
        try? FileManager.default.removeItem(at: location)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        NSLog("Test download task completed")
    }
    
}
