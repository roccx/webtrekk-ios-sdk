//
//  Campaign.swift
//  Pods
//
//  Created by arsen.vartbaronov on 17/08/16.
//
//
import Foundation

class Campaign{
    
    let trackID: String
    static let campaignHasProcessed = "campaignHasProcessed"
    static let savedMediaCode = "mediaCode"
    private let sharedDefaults = UserDefaults.standardDefaults.child(namespace: "webtrekk")

    
    init(trackID: String){
        self.trackID = trackID
    }
    
    
    func processCampaign() {
        
        // check if compain is done already
        if let isCampaignSet = sharedDefaults.boolForKey(Campaign.campaignHasProcessed) where isCampaignSet { return
        }
        
        WebtrekkTracking.logger.logDebug("Campaign process is starting")
        
        //if not get advId
        let advID = Environment.advertisingIdentifierManager?.advertisingIdentifier
        
        // sent request
        
        let session = RequestManager.createUrlSession()
        guard let urlComponents = NSURLComponents(string: "https://appinstall.webtrekk.net/appinstall/v1/install") else {
            WebtrekkTracking.logger.logError("can't initializate URL for campaign")
            return
        }
        var queryItems = [NSURLQueryItem]()
        queryItems.append(NSURLQueryItem(name: "trackid", value: self.trackID))
        
        if let advID = Environment.advertisingIdentifierManager?.advertisingIdentifier {
            queryItems.append(NSURLQueryItem(name: "aid", value: advID.UUIDString))
        }
        
        queryItems.append(NSURLQueryItem(name: "X-WT-UA", value: DefaultTracker.userAgent))
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.URL else {
            WebtrekkTracking.logger.logError("can't construct URL for campaign")
            return
        }
        
        let task = session.dataTaskWithURL(url){ data, response, error in
            if let error = error {
                WebtrekkTracking.logger.logError("Install campaign request error:\(error)")
            } else {
                guard let responseGuard = response as? NSHTTPURLResponse else {
                    WebtrekkTracking.logger.logError("Install campaign response error:\(response)")
                    return
                }
                
                guard responseGuard.statusCode == 200 else {
                    WebtrekkTracking.logger.logDebug("No campaign for this applicaiton. Response:\(response)")
                    self.sharedDefaults.set(key: Campaign.campaignHasProcessed, to: true)
                    return
                }
                
                // parc response
                guard let dataG = data, let json = try? NSJSONSerialization.JSONObjectWithData(dataG, options: .AllowFragments),
                    let jsonMedia = json["mediacode"] as? String where jsonMedia.characters.split("=").count == 2 else {
                    
                    WebtrekkTracking.logger.logError("Incorrect JSON response:\(data)")
                    return
                }
            
               WebtrekkTracking.logger.logDebug("Media code is received:\(jsonMedia)")
            
               let mc = String(jsonMedia.characters.split("=")[1])
                
                guard !mc.isEmpty else {
                    WebtrekkTracking.logger.logError("media code length is zero")
                    return
                }
                
                self.sharedDefaults.set(key: Campaign.campaignHasProcessed, to: true)
                self.sharedDefaults.set(key: Campaign.savedMediaCode, to: mc)
            }
        }
        
        WebtrekkTracking.logger.logDebug("Campaign request is sent:\(url)")
        task.resume()
    }
    
    func getAndDeletSavedMediaCode() -> String?{
        let mediaCode = self.sharedDefaults.stringForKey(Campaign.savedMediaCode)
        
        if let _ = mediaCode {
            self.sharedDefaults.remove(key: Campaign.savedMediaCode)
        }
        
        return mediaCode
    }
    
}
