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
//  Created by arsen.vartbaronov on 27/02/17.
//

import Foundation
//import UIKit

class RequestQueue {
    
    private var queue = ArraySync<URLItem>()
    private let urlsInMemoryMax = 5
    private let urlsBuffered = 100
    private var pointer: SimpleSync<UInt64?> = SimpleSync<UInt64?>(value: nil)
    private var fileHandler: FileHandle?
    private let fileName = "webtrekk_url_buffer.txt"
    private var fileURL: URL? = nil
    private let delimeter: String = "\n"
    fileprivate typealias ReadURLResult = (url: URL?, EOF: Bool, pointerShift: UInt64)
    private let reader: TextFileReader
    var size: SimpleSync<Int> = SimpleSync<Int>(value: 0)
    private let threadAddURLQueue: DispatchQueue
    private let threadGetURLQueue: DispatchQueue
    private let threadLoadURLQueue: DispatchQueue
    private let queuAddCondition = NSCondition()
    private let saveLoadLock = NSLock()
    private let flashAndDeleteLock = NSLock()
    private let sizeSettingName = "QUEU_SIZE"
    private let positionSettingName = "FILE_CURRENT_POSITION"
    private var isLoaded: Bool = false
    
    private let saveDirectory: FileManager.SearchPathDirectory
    
    private struct URLItem {
        let url: URL
        let pointer: UInt64? // link to next url in file
    }

    var isEmpty : Bool {
        return self.size.value == 0
    }

    init(){
        
        reader = TextFileReader(delimeter: self.delimeter.data(using: .utf8)!)
        threadAddURLQueue = DispatchQueue(label: "webtrekk_add_url", qos: .utility )
        threadGetURLQueue = DispatchQueue(label: "webtrekk_get_url", qos: .utility)
        threadLoadURLQueue = DispatchQueue(label: "webtrekk_load_url", qos: .utility)
        
        #if os(tvOS)
            saveDirectory = .cachesDirectory
        #else
            saveDirectory = .applicationSupportDirectory
        #endif
        
        guard let url = FileManager.default.urls(for: saveDirectory, in: .userDomainMask).first else {
            WebtrekkTracking.defaultLogger.logError("can't get application suport directory. No buffered tracking will be done")
            return
        }
        
        self.fileURL = url.appendingPathComponent("Webtrekk").appendingPathComponent(self.fileName)
    }
    
    
    // should be used weak reference for this closure
    func addURL(url: URL) {
        
        if !self.isLoaded {
            self.load()
        }
        
        self.logDebug("addURL begin queue size: \(self.size.value). local queue size \(self.queue.count)")
        if self.pointer.value != nil {
            // read it from file
            // put it to the separate thread
            self.threadAddURLQueue.async {
                let pointer = self.saveToFile(url: url)
                self.logDebug("saved to file")
                DispatchQueue.main.sync(){
                        if self.size.value == self.queue.count && self.queue.count < self.urlsBuffered{
                            self.queue.append(URLItem(url: url, pointer: pointer))
                        }
                    self.size.increment(to: 1)
                }
                self.saveSettings()
                self.logDebug("addURL threadAddURLQueue queue size: \(self.size.value). local queue size \(self.queue.count)")
            }
        } else {
            
                self.queue.append(URLItem(url: url, pointer: nil))
            
                self.size.increment(to: 1)
                self.logDebug("added to memory queue")
                if self.size.value > self.urlsInMemoryMax {
                    self.logDebug("flash to disk start thread")
                    
                    guard self.createNewFile() else {
                        return
                    }
                    
                    self.threadAddURLQueue.async {
                        self.flashQueueToDisk()
                        self.logDebug("flash to disk done")
                    }
                }
        }
        self.logDebug("addURL end queue size: \(self.size.value). local queue size \(self.queue.count)")
    }
    
    /** return nil, if it is empty */
    func getURL(finishClosure: @escaping (_ url: URL?)->Void ) throws{
        
        guard self.size.value > 0 else {
            finishClosure(nil)
            return
        }
        
        self.logDebug("get URL")
        
        if self.pointer.value != nil && queue.isEmpty  {
            // it means that queue is uploading
            self.threadGetURLQueue.async {
                self.logDebug("wait till at least one item in queue loaded")
                self.queuAddCondition.lock()
                self.logDebug("queuAddCondition lock is set")
                
                while self.queue.isEmpty {
                    self.queuAddCondition.wait()
                }
                
                self.logDebug("queuAddCondition wait is done")
                self.queuAddCondition.unlock()
                self.logDebug("queuAddCondition unlock is set")
                
                guard let first = self.queue.first?.url else {
                    WebtrekkTracking.defaultLogger.logError("no first items in cashed queue. something wrong")
                    finishClosure(nil)
                    return
                }
                self.logDebug("get next url")
                DispatchQueue.main.sync {
                    finishClosure(first)
                }
            }
        } else {
            guard let first = self.queue.first?.url else {
                throw TrackerError(message: "First can't be nil as queue isn't empty")
            }
            
            finishClosure(first)
        }
    }
    
    func deleteFirst(){
        self.logDebug("deleteFirst begin queue size: \(self.size.value). local queue size \(self.queue.count)")
        guard self.size.value > 0 else {
            WebtrekkTracking.defaultLogger.logError("try to delete first item in queue, but queue is empty")
            return
        }
        
        self.flashAndDeleteLock.lock()
        
        if self.pointer.value != nil {
            self.pointer.value = self.queue.first?.pointer
        }
        
        let urlToLog = self.queue.first?.url.absoluteString
        self.logDebug("url \(urlToLog.simpleDescription) will be deleted")

        self.queue.remove(at: 0)
        self.size.increment(to: -1)
        
        self.flashAndDeleteLock.unlock()
        
        self.refreshMemoryQueue()
    
        self.saveSettings()
        self.logDebug("deleteFirst end queue size: \(self.size.value). local queue size \(self.queue.count)")
    }
    
    func deleteAll() {
        self.size.value = 0
        self.pointer.value = nil
        self.queue.removeAll()
        
        if self.isExist() {
          self.deleteFile()
        }
        
        self.saveSettings()
    }
    
    /** can be called only once durign first application install in case of migration */
    func addArray(urls: [URL]){
        for url in urls {
            addURL(url: url)
        }
    }
    
    func save(){
        
        if self.pointer.value == nil && self.size.value > 0 {
            if self.createNewFile() {
                self.logDebug("flash to disk start")
                self.flashQueueToDisk()
                self.logDebug("flash to disk done")
            }
        }
        
        self.logDebug("wait for all savings done")
        // wait for all saving done
        self.threadAddURLQueue.sync{}
        self.logDebug("finish wait for all savings done")
        self.saveSettings()
    }
    
    private func saveSettings(){
        UserDefaults.standardDefaults.set(key: self.positionSettingName, to: self.pointer.value)
        UserDefaults.standardDefaults.set(key: self.sizeSettingName, to: self.size.value)
        logDebug("save pointer: \(self.pointer.value.simpleDescription) size: \(self.size.value)")
    }
    
    func load(){
        
        guard !self.isLoaded else {
            return
        }
        
        self.logDebug("load is started")
        self.pointer.value =  UserDefaults.standardDefaults.uInt64ForKey(self.positionSettingName)
        self.size.value = UserDefaults.standardDefaults.objectForKey(self.sizeSettingName) as? Int ?? 0
        
        logDebug("loaded save pointer: \(self.pointer.value.simpleDescription) size: \(self.size.value)")
        
        if self.size.value > 0 && self.pointer.value == nil {
            self.size.value = 0
            logDebug("set size to 0 if pointer is nil. Can be in case of crash")
        }
        
        if self.size.value != 0 && self.fileHandler == nil {
            if let pointer = self.pointer.value, self.initFileHandler() {
                self.fileHandler?.seek(toFileOffset: pointer)
            }
        }
        self.refreshMemoryQueue()
        self.isLoaded = true
    }
    
    // can be called for initial adding queue to file
    func flashQueueToDisk(){
        guard let pointer = self.pointer.value, pointer == 0 else {
            WebtrekkTracking.defaultLogger.logError("logic error with pointer")
            return
        }
        
        self.flashAndDeleteLock.lock()
        
        for i in 0..<queue.count {
            let pointer = saveToFile(url: queue[i].url)
            queue[i] = URLItem(url:queue[i].url, pointer: pointer)
        }
        self.flashAndDeleteLock.unlock()
        
        self.saveSettings()
    }
    
    private func refreshMemoryQueue(){
        
        guard let _ = self.pointer.value else {
            return
        }
        
        if self.size.value == 0{
            if self.isExist() {
                // check one more time if size real zero
                if self.size.value == 0 {
                    // set pointer to nil and delete file
                    self.pointer.value = nil
                    self.deleteFile()
                self.logDebug("file deleted")
                }
            }
        } else {
            self.threadLoadURLQueue.async {
               if self.queue.count == 0 {
                    self.loadToQueue()
                }
            }
        }
    }
    
    // write url to file return poniter to next postion after this url
    private func saveToFile(url: URL) -> UInt64{
        
        guard let file = self.fileHandler else {
            return 0
        }
        
        let str = url.absoluteString + self.delimeter
        
        guard let data = str.data(using: .utf8) else {
            WebtrekkTracking.defaultLogger.logError("Empty URL for saving to stored request file")
            return 0
        }
        self.saveLoadLock.lock()
        self.logDebug("saveToFile saveLoadLock.lock()")
        defer {
            self.saveLoadLock.unlock()
            self.logDebug("saveToFile saveLoadLock.unlock()")
        }

        file.seekToEndOfFile()
        file.write(data)
        self.logDebug("save data done")
        
        return file.offsetInFile
    }
    
    // load next portion of items in queue
    private func loadToQueue(){
        
        guard var pointer = self.pointer.value, queue.isEmpty else {
            WebtrekkTracking.defaultLogger.logError("Load only empty queue something wrong")
            return
        }
        
        guard let file = self.fileHandler else {
            return
        }
        
        self.logDebug("load queue start queue size: \(self.size.value). local queue size \(self.queue.count), pointer: \(pointer)")

        self.reader.initReading(initalPointer: pointer)
        
        defer {
            self.reader.clearBuffer()
        }
        
        mainCycle: for i in 0..<self.urlsBuffered {
            // that is save read lock for moving pointer correctly
            self.saveLoadLock.lock()
            logDebug("loadToQueue saveLoadLock.lock")
            
            defer {
                self.saveLoadLock.unlock()
                logDebug("loadToQueue saveLoadLock.unlock")
            }
            
            var signalIsSent = false
            // that is get load to queue lock to wait for queue to load before getting next item
            self.queuAddCondition.lock()
            
            // to avoid deadlock send and unlock anyway
            defer{
                if !signalIsSent {
                    self.queuAddCondition.signal()
                    self.queuAddCondition.unlock()
                    signalIsSent = true
                    logDebug("queuAddCondition signal is send and unlock is done")
                }
            }
            
            self.fileHandler?.seek(toFileOffset: pointer)
            let result = self.reader.readLine(fileHandle: file)
            logDebug("result is received \(result) ")
            switch result {
                case (nil, true, 0): //no data found exit from cycle
                    break mainCycle
                case (nil, false, let shift): // wrong data. just continue
                    pointer = pointer + shift
                case (let url, let EOF, let shift): // receive url add to queue
                    pointer = pointer + shift
                    self.queue.append(URLItem(url: url!, pointer: pointer))
                    if !signalIsSent {
                        self.queuAddCondition.signal()
                        self.queuAddCondition.unlock()
                        logDebug("queuAddCondition signal is send and unlock is done eor: \(EOF)")
                        signalIsSent = true
                    }
            }
        }
        
        self.logDebug("load queue finish queue size: \(self.size.value). local queue size \(self.queue.count)")
    }
    
    
    private func readURLFromFile() -> ReadURLResult? {
        guard let file = self.fileHandler else {
            return nil
        }
        
        return self.reader.readLine(fileHandle: file)
    }
    
    private func createNewFile() -> Bool{
        guard let url = self.fileURL else {
            return false
        }
        
        guard FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil) else {
            WebtrekkTracking.defaultLogger.logError("can't create file for buffered tracking. No buffered tracking will be done. file path: \(url.path)")
            return false
        }
        
        guard self.initFileHandler() else {
            return false
        }
        
        self.pointer.value = 0
        self.logDebug("file created")
        return true
    }
    
    private func initFileHandler() -> Bool{
        guard let url = self.fileURL else {
            return false
        }
        
        do {
            self.fileHandler = try FileHandle(forUpdating: url)
        } catch let error {
            WebtrekkTracking.defaultLogger.logError("can't create file for buffered tracking. No buffered tracking will be done. error: \(error)")
            self.pointer.value = nil
            return false
        }
        
        self.logDebug("file handler initializated")
        return true
    }
    
    // check if url stored file file exists
    private func isExist() -> Bool {
        guard let url = self.fileURL else {
            return false
        }
        
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    // delete url store file
    private func deleteFile(){
        guard let url = self.fileURL, let _ = self.fileHandler else {
            return
        }
        
        do {
            try FileManager.default.removeItem(at: url)
        }catch let error{
            WebtrekkTracking.defaultLogger.logError("Serious problem with urls saved file deletion: \(error). It might produce unexpected behaviour.")
        }
    }
    
    private func logDebug(_ message: String){
        WebtrekkTracking.defaultLogger.logDebug("Save queue:"+message)
    }
}

fileprivate class TextFileReader{
    
    let bufSize = 1000
    var buffer: Data
    let delimeter: Data
    var pointer: UInt64 = 0
    
    init(delimeter value: Data){
        delimeter = value
        self.buffer = Data(capacity: bufSize*2)
    }
    
    fileprivate func readLine(fileHandle: FileHandle)->RequestQueue.ReadURLResult {
        var eof = false
        var line: String? = nil
        var shift: UInt64 = 0
        var noData = false
        
        fileHandle.seek(toFileOffset: self.pointer)
        
        while !eof {
            
            if let range = self.buffer.range(of: delimeter) {
                
                // Convert complete line (excluding the delimiter) to a string:
                line = String(data: self.buffer.subdata(in: 0..<range.lowerBound), encoding: .utf8)
                
                // Remove line (and the delimiter) from the buffer:
                self.buffer.removeSubrange(0..<range.upperBound)
                //logDebug("buffer cut \(String(data: self.buffer, encoding: .utf8))")
                shift = UInt64(range.upperBound)
                break;
            }
            
            let tmpData = fileHandle.readData(ofLength: bufSize)
            self.pointer = fileHandle.offsetInFile
            
            if tmpData.count > 0 {
                self.buffer.append(tmpData)
                //logDebug("buffer is \(String(data: buffer, encoding: .utf8)) \n with temp data \(String(data: tmpData, encoding: .utf8))")
                //logDebug("file pointer is \(fileHandle.offsetInFile)")
            } else {
                eof = true
                
                //check if buffer empty. If yes exit.
                guard self.buffer.count > 0 else {
                    noData = true
                    break;
                }
            }
            
        }
        
        guard !noData else {
            return (nil, true, 0)
        }
        
        guard let lineNotOpt = line, let url = URL(string: lineNotOpt) else {
            WebtrekkTracking.defaultLogger.logDebug("Line in stored url file isn't string or URL. Line: \(line.simpleDescription)")
            return (nil, eof, shift)
        }
        
        return (url, eof, shift)
    }
    
    fileprivate func clearBuffer(){
        self.buffer.removeAll()
    }
    
    fileprivate func initReading(initalPointer pointer: UInt64){
        self.pointer = pointer
    }
    
}
