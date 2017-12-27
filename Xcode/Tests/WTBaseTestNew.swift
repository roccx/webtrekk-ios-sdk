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
//  Created by arsen.vartbaronov on 17/08/16.
//

import XCTest
@testable import Webtrekk
import AVFoundation
import Nimble

class WTBaseTestNew: HttpBaseTestNew {
    
    var libraryVersion: String?
    static var lifeCicleIsInited = false
    var initWebtrekkManualy = false
    var isCheckFinishCondition = true
    var isWaitForCampaignFinished = true

    override func setUp() {
        super.setUp()
        
        guard !self.initWebtrekkManualy else {
            return
        }
        
        initWebtrekk()
    }
    
    override func tearDown() {
        doSmartWait(sec: 1)
        releaseWebtrekk()
        super.tearDown()
    }
    
    func getConfigName() -> String?{
        return nil
    }
    
    func initWebtrekk(){
        
        guard !WebtrekkTracking.isInitialized() else{
            return
        }
        
        WebtrekkTracking.defaultLogger.minimumLevel = .debug
        WebtrekkTracking.defaultLogger.testMode = true
        
        do {
            if let configName = getConfigName(){
                let configFileURL = Bundle.main.url(forResource: configName, withExtension: "xml", subdirectory: "Configurations/")
                try WebtrekkTracking.initTrack(configFileURL)
            }else {
                try WebtrekkTracking.initTrack()
            }
        }catch let error as TrackerError {
            WebtrekkTracking.defaultLogger.logError("Error Webtrekk SDK initialization: \(error.message)")
        }catch {
            WebtrekkTracking.defaultLogger.logError("Unkown error during Webtrekk SDK initialization")
        }
        
        
        let libraryVersionOriginal = Bundle.init(for: WebtrekkTracking.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "9.9.9"
        self.libraryVersion = libraryVersionOriginal.replacingOccurrences(of: ".", with: "")
        
        doInitiateApplicationLifecycleOneMoreTime()
        checkStartCondition()
        if self.isWaitForCampaignFinished {
            waitForCampaignFinished()
        }
    }

    private func waitForCampaignFinished(){
        var attempt: Int = 0
        
        while !self.isCampaignFinished && attempt < 100 {
            self.doSmartWait(sec: 1.0)
            attempt += 1
        }
        
        WebtrekkTracking.defaultLogger.logDebug("end wait for campaign process: isSuccess=\(checkDefSettingNoConfig(setting: "campaignHasProcessed"))")
    }
    
    private var isCampaignFinished : Bool {
        return (Foundation.UserDefaults.standard.object(forKey: getKeyForDefSetting(setting: "campaignHasProcessed")) as? Bool) ?? false
    }
    
    
    func releaseWebtrekk(){
        clearCashedConf()
        rollBackAutoTrackingMethodsSwizz()
        resetWebtrackInstance()
        checkFinishCondition()
    }
    
    private func resetWebtrackInstance()
    {
        weak var weakTracker = WebtrekkTracking.tracker
        WebtrekkTracking.tracker = nil
        
        while weakTracker != nil {
            doSmartWaitIter(sec: 2)
        }
    }
        
    private func rollBackAutoTrackingMethodsSwizz(){
        UIViewController.setUpAutomaticTracking()
    }
    
    private func checkStartCondition(){
        expect(self.isBackupFileExists()).to(equal(false))
    }
    
    private func checkFinishCondition(){
        
        guard isCheckFinishCondition else {
            return
        }
        
        expect(self.isBackupFileExists()).to(equal(false), description: "check for saved urls in old format")
        expect(WTBaseTestNew.requestNewQueueBackFileExists()).to(equal(false), description: "check for saved urls")
    }
    
    private func doInitiateApplicationLifecycleOneMoreTime(){
        
        guard !WTBaseTestNew.lifeCicleIsInited else {
            return
        }
        
        let nc = NotificationCenter.default
        
        nc.post(name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        nc.post(name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
        WTBaseTestNew.lifeCicleIsInited = true
    }
    
    private func isBackupFileExists() -> Bool{
        let file = WTBaseTestNew.requestOldQueueBackupFileForWebtrekkId(getConfID());
        
        return FileManager.default.itemExistsAtURL(file!)
    }
    
    func doSmartWaitIter(sec: Double){
        RunLoop.current.run(mode: .defaultRunLoopMode, before: Date(timeIntervalSinceNow:sec))
    }
    
    
    func doSmartWait(sec: Double){
        let date: Date = Date(timeIntervalSinceNow: TimeInterval(sec))
        
        while date > Date() {
        doSmartWaitIter(sec: 1)
        }
    }
    
    
    func getConfID() -> String{
        return "123451234512345"
    }
    
    
    private func clearCashedConf(){
        removeDefSetting(setting: "configuration")
    }
    
    func removeDefSetting(setting: String) {
        Foundation.UserDefaults.standard.removeObject(forKey: getKeyForDefSetting(setting: setting))
    }
    
    func checkDefSetting(setting: String)-> Bool{
        let object = Foundation.UserDefaults.standard.object(forKey: getKeyForDefSetting(setting: setting))
        return object != nil
    }
    
    private func getKeyForDefSetting(setting: String)->String {
        return "webtrekk.\(setting)"
    }
    
    func checkDefSettingNoConfig(setting: String) -> Bool{
        let object = Foundation.UserDefaults.standard.object(forKey: "webtrekk.\(setting)")
        return object != nil
    }
    
    static func requestOldQueueBackupFileForWebtrekkId(_ webtrekkId: String) -> URL? {
        
        let searchPathDirectory: FileManager.SearchPathDirectory
        #if os(iOS) || os(OSX) || os(watchOS)
            searchPathDirectory = .applicationSupportDirectory
        #elseif os(tvOS)
            searchPathDirectory = .cachesDirectory
        #endif
        
        let fileManager = FileManager.default
        
        var directory: URL
        do {
            directory = try fileManager.url(for: searchPathDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        }
        catch let error {
            WebtrekkTracking.defaultLogger.logError("Test: Cannot find directory for storing request queue backup file: \(error)")
            return nil
        }
        
        directory = directory.appendingPathComponent("Webtrekk")
        directory = directory.appendingPathComponent(webtrekkId)
        
        if !fileManager.itemExistsAtURL(directory) {
            do {
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
                var resourceValue = URLResourceValues()
                resourceValue.isExcludedFromBackup = true
                try? directory.setResourceValues(resourceValue)
            }
            catch let error {
                WebtrekkTracking.defaultLogger.logError("Test: Cannot create directory at '\(directory)' for storing request queue backup file: \(error)")
                return nil
            }
        }
        
        return directory.appendingPathComponent("requestQueue.archive")
    }
    
    static func requestNewQueueBackFileExists() -> Bool{
        
        guard let url = getNewQueueBackFileURL() else {
            return false
        }

        return FileManager.default.fileExists(atPath: url.path)
    }
    
    static func requestNewQueueBackFileDelete(){
        
        guard let url = getNewQueueBackFileURL() else {
            return
        }
        
        try? FileManager.default.removeItem(atPath: url.path)
    }

    static func getNewQueueBackFileURL() -> URL?{
    
        return getNewQueueBackFolderURL()?.appendingPathComponent("webtrekk_url_buffer.txt")
    }

    static func getNewQueueBackFolderURL() -> URL?{
        
        #if os(tvOS)
            let saveDirectory: FileManager.SearchPathDirectory = .cachesDirectory
        #else
            let saveDirectory: FileManager.SearchPathDirectory = .applicationSupportDirectory
        #endif

        
        guard let url = FileManager.default.urls(for: saveDirectory, in: .userDomainMask).first else {
            WebtrekkTracking.defaultLogger.logError("requestNewQueueBackFileExists can't get application support dir for backup file url")
            return nil
        }
        
        return url.appendingPathComponent("Webtrekk")
    }
    
    func log(text: String){
        WebtrekkTracking.defaultLogger.logDebug(text)
    }

}
