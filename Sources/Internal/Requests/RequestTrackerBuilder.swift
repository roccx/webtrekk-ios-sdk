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
//  Created by arsen.vartbaronov on 18/11/16.
//
//

import Foundation

final class RequestTrackerBuilder {
    
    #if !os(watchOS)
    var deepLink: DeepLink!
    #endif
    
    let campaign: Campaign
    let pageURL: String?
    let configuration: TrackerConfiguration
    let global: GlobalProperties
    
    init (_ campaign: Campaign, pageURL: String?, configuration: TrackerConfiguration,
          global: GlobalProperties){
        self.campaign = campaign
        self.pageURL = pageURL
        self.configuration = configuration
        self.global = global
    }
    
    #if !os(watchOS)
    func setDeepLink(deepLink: DeepLink){
        self.deepLink = deepLink
    }
    #endif
 
    // create mergedTrackerRequest
    func createRequest(_ event: TrackingEvent, requestProperties: TrackerRequest.Properties)-> TrackerRequest? {

        var event = globalPropertiesByApplyingEvent(from: event, requestProperties: requestProperties)
        
        event = eventByApplyingAutomaticPageTracking(to: event)
        
        event = campaignOverride(to :event) ?? event
        
        #if !os(watchOS)
            event = deepLinkOverride(to: event) ?? event
        #endif
        
        event = pageURLOverride(to: event) ?? event
        
        return createRequestForEvent(event, requestProperties: requestProperties)
}
    
    // override media code in request in case of deeplink
    
    #if !os(watchOS)
    private func deepLinkOverride(to event: TrackingEvent) -> TrackingEvent? {
        
        guard var _ = event as? TrackingEventWithAdvertisementProperties,
            let _ = event as? TrackingEventWithEcommerceProperties else{
                return nil
        }
        
        if let mc = self.deepLink.getAndDeletSavedDeepLinkMediaCode() {
            var returnEvent = event
            
            var eventWithAdvertisementProperties = returnEvent as! TrackingEventWithAdvertisementProperties
            eventWithAdvertisementProperties.advertisementProperties.id = mc
            returnEvent = eventWithAdvertisementProperties
            
            return returnEvent
        }
        
        return nil
    }
    #endif
    
    // override some parameter in request if campaign is completed
    private func campaignOverride(to event: TrackingEvent) -> TrackingEvent? {
        
        guard var _ = event as? TrackingEventWithAdvertisementProperties,
            let _ = event as? TrackingEventWithEcommerceProperties else{
                return nil
        }
        
        if let mc = self.campaign.getAndDeletSavedMediaCode() {
            var returnEvent = event
            
            var eventWithAdvertisementProperties = returnEvent as! TrackingEventWithAdvertisementProperties
            eventWithAdvertisementProperties.advertisementProperties.id = mc
            eventWithAdvertisementProperties.advertisementProperties.action = "c"
            returnEvent = eventWithAdvertisementProperties
            
            var eventWithEcommerceProperties = returnEvent as! TrackingEventWithEcommerceProperties
            var detailsToAdd = eventWithEcommerceProperties.ecommerceProperties.details ?? [Int: TrackingValue]()
            detailsToAdd[900] = "1"
            eventWithEcommerceProperties.ecommerceProperties.details = detailsToAdd
            returnEvent = eventWithEcommerceProperties
            
            return returnEvent
        }
        
        return nil
    }
    
    //override PageURLParameter
    private func pageURLOverride(to event:TrackingEvent) -> TrackingEvent? {
        
        guard var _ = event as? TrackingEventWithPageProperties else{
            return nil
        }
        
        if let pageURL = self.pageURL {
            
            guard pageURL.isValidURL() else {
                WebtrekkTracking.defaultLogger.logError("Invalid URL \(pageURL) for override pu parameter")
                return nil
            }
            
            var returnEvent = event
            
            var eventWithPageProperties = returnEvent as! TrackingEventWithPageProperties
            eventWithPageProperties.pageProperties.url = pageURL
            returnEvent = eventWithPageProperties
            
            return returnEvent
        }
        
        return nil
    }
    
    
    private func eventByApplyingAutomaticPageTracking(to event: TrackingEvent) -> TrackingEvent {
        checkIsOnMainThread()
        
        guard let
            viewControllerType = event.viewControllerType,
            let pageProperties = self.configuration.automaticallyTrackedPageForViewControllerType(viewControllerType)
            else {
                return event
        }
        
        if let page = applyKeys(keys: event.variables, properties: pageProperties) as? TrackerConfiguration.Page {
            return mergeProperties(event: event, properties: page, rewriteEvent: true)
        } else {
            WebtrekkTracking.logger.logError("incorect type of return value from apply Keys for page parameters")
            return event
        }
    }
    
    private func globalPropertiesByApplyingEvent(from event: TrackingEvent, requestProperties: TrackerRequest.Properties) -> TrackingEvent {
        checkIsOnMainThread()
        
        var event = event
        
        event.variables = self.global.variables.merged(over: event.variables)
        
        if let globalSettings = applyKeys(keys: event.variables, properties: configuration.globalProperties) as? GlobalProperties {
            // merge global from code and from configuration.
            let globalMerged = globalSettings.merged(over: self.global)
            
            // merge autoParameters
            let autoProperties = getAutoParameters(requestProperties: requestProperties)
            let global = globalMerged.merged(over: autoProperties)
            
            return mergeProperties(event: event, properties: global, rewriteEvent: false)
        } else {
            WebtrekkTracking.logger.logError("incorect type of return value from apply Keys for global parameters")
            return event
        }
    }
    
    private func applyKeys(keys: [String:String], properties: BaseProperties) -> BaseProperties{
        
        guard let trackingParameter = properties.trackingParameters else {
            return properties
        }
        
        if let globalProperties = properties as? GlobalProperties {
            return GlobalProperties(actionProperties: trackingParameter.actionProperties(variables: keys),
                                    advertisementProperties: trackingParameter.advertisementProperties(variables: keys),
                                    crossDeviceProperties: globalProperties.crossDeviceProperties,
                                    ecommerceProperties: trackingParameter.ecommerceProperties(variables: keys),
                                    ipAddress: trackingParameter.resolveIPAddress(variables: keys),
                                    mediaProperties: trackingParameter.mediaProperties(variables: keys),
                                    pageProperties: trackingParameter.pageProperties(variables: keys),
                                    sessionDetails: trackingParameter.sessionDetails(variables: keys),
                                    userProperties: trackingParameter.userProperties(variables: keys),
                                    variables: globalProperties.variables)
        }
        if let pageProperties = properties as? TrackerConfiguration.Page {
            
            var page = trackingParameter.pageProperties(variables: keys)
            //override name from xml
            page.name = pageProperties.pageProperties.name
            
            return TrackerConfiguration.Page(viewControllerTypeNamePattern: pageProperties.viewControllerTypeNamePattern,
                                             pageProperties: page,
                                             actionProperties: trackingParameter.actionProperties(variables: keys),
                                             advertisementProperties: trackingParameter.advertisementProperties(variables: keys),
                                             ecommerceProperties: trackingParameter.ecommerceProperties(variables: keys),
                                             ipAddress: trackingParameter.resolveIPAddress(variables: keys),
                                             mediaProperties: trackingParameter.mediaProperties(variables: keys),
                                             sessionDetails: trackingParameter.sessionDetails(variables: keys),
                                             userProperties: trackingParameter.userProperties(variables: keys))
        }
        
        WebtrekkTracking.logger.logError("Unsupported type of properties")
        return properties
    }

    private func createRequestForEvent(_ event: TrackingEvent, requestProperties: TrackerRequest.Properties) -> TrackerRequest? {
        checkIsOnMainThread()
        
        guard validateEvent(event) else {
            return nil
        }
        
        return TrackerRequest(
            crossDeviceProperties: global.crossDeviceProperties,
            event: event,
            properties: requestProperties
        )
    }
    
    
    private func validateEvent(_ event: TrackingEvent) -> Bool {
        checkIsOnMainThread()
        
        guard event.pageName?.nonEmpty != nil else {
            logError("Cannot track event without .pageName set: \(event)")
            return false
        }
        
        if let event = event as? TrackingEventWithActionProperties {
            guard event.actionProperties.name?.nonEmpty != nil else {
                logError("Cannot track event without .actionProperties.name set: \(event)")
                return false
            }
        }
        
        if let event = event as? TrackingEventWithMediaProperties {
            guard event.mediaProperties.name?.nonEmpty != nil else {
                logError("Cannot track event without .mediaProperties.name set: \(event)")
                return false
            }
        }
        
        return true
    }
    
    private func mergeProperties(event: TrackingEvent, properties: BaseProperties, rewriteEvent: Bool) -> TrackingEvent {
        
        let mergeTool = PropertyMerger()
        var event = event
        
        if rewriteEvent {
            event.ipAddress = properties.ipAddress ?? event.ipAddress
            event.pageName = properties.pageProperties.name ?? event.pageName
        }else{
            event.ipAddress = event.ipAddress ?? properties.ipAddress
            event.pageName = event.pageName ?? properties.pageProperties.name
        }
        
        guard !(event is ActionEvent) else {
            return event
        }
        
        if var eventWithActionProperties = event as? TrackingEventWithActionProperties {
            eventWithActionProperties.actionProperties = mergeTool.mergeProperties(first: properties.actionProperties, second: eventWithActionProperties.actionProperties, from1Over2: rewriteEvent)
            event = eventWithActionProperties
        }
        if var eventWithAdvertisementProperties = event as? TrackingEventWithAdvertisementProperties {
            eventWithAdvertisementProperties.advertisementProperties = mergeTool.mergeProperties(first: properties.advertisementProperties, second: eventWithAdvertisementProperties.advertisementProperties, from1Over2: rewriteEvent)
            event = eventWithAdvertisementProperties
        }
        if var eventWithEcommerceProperties = event as? TrackingEventWithEcommerceProperties {
            eventWithEcommerceProperties.ecommerceProperties = mergeTool.mergeProperties(first: properties.ecommerceProperties, second: eventWithEcommerceProperties.ecommerceProperties, from1Over2: rewriteEvent)
            event = eventWithEcommerceProperties
        }
        if var eventWithMediaProperties = event as? TrackingEventWithMediaProperties {
            eventWithMediaProperties.mediaProperties = mergeTool.mergeProperties(first: properties.mediaProperties, second: eventWithMediaProperties.mediaProperties, from1Over2: rewriteEvent)
            event = eventWithMediaProperties
        }
        if var eventWithPageProperties = event as? TrackingEventWithPageProperties {
            eventWithPageProperties.pageProperties = mergeTool.mergeProperties(first: properties.pageProperties, second: eventWithPageProperties.pageProperties, from1Over2: rewriteEvent)
            event = eventWithPageProperties
        }
        if var eventWithSessionDetails = event as? TrackingEventWithSessionDetails {
            eventWithSessionDetails.sessionDetails = mergeTool.mergeProperties(first: properties.sessionDetails, second: eventWithSessionDetails.sessionDetails, from1Over2: rewriteEvent)
            event = eventWithSessionDetails
        }
        if var eventWithUserProperties = event as? TrackingEventWithUserProperties {
            eventWithUserProperties.userProperties = mergeTool.mergeProperties(first: properties.userProperties, second: eventWithUserProperties.userProperties, from1Over2: rewriteEvent)
            event = eventWithUserProperties
        }
        
        return event
    }
    
    private enum autoParametersAttrNumbers: Int {
        case screenOrientation = 783, requestQueueSize
        case appVersion = 804
        case connectionType = 807
        case advertisingId = 809
        case advertisingTrackingEnabled = 813
        case isFirstEventAfterAppUpdate = 815
    }
    
    private static let autoParameters: [autoParametersAttrNumbers:CustomParType] =
        [.screenOrientation: .pageParameter, .requestQueueSize: .pageParameter, .appVersion: .sessionParameter, .connectionType: .sessionParameter,
         .advertisingId: .sessionParameter, .advertisingTrackingEnabled: .sessionParameter, .isFirstEventAfterAppUpdate: .sessionParameter]
    
    
    private func getAutoParameters (requestProperties properties: TrackerRequest.Properties) -> GlobalProperties{
        
        
        var sessionDetails: [Int : TrackingValue] = [:]
        var pageDetails: [Int : TrackingValue] = [:]
        
        #if !os(watchOS) && !os(tvOS)
            if let interfaceOrientation = properties.interfaceOrientation {
                pageDetails[autoParametersAttrNumbers.screenOrientation.rawValue] = .constant(interfaceOrientation.serialized)
            }

            if let connectionType = properties.connectionType {
                sessionDetails[autoParametersAttrNumbers.connectionType.rawValue] = .constant(connectionType.serialized)
            }
        #endif
        
        if let requestQueueSize = properties.requestQueueSize {
            pageDetails[autoParametersAttrNumbers.requestQueueSize.rawValue] = .constant(String(requestQueueSize))
        }
        if let appVersion = properties.appVersion {
            sessionDetails[autoParametersAttrNumbers.appVersion.rawValue] = .constant(appVersion)
        }
        if let advertisingId = properties.advertisingId {
            sessionDetails[autoParametersAttrNumbers.advertisingId.rawValue] = .constant(advertisingId.uuidString)
        }
        if let advertisingTrackingEnabled = properties.advertisingTrackingEnabled {
            sessionDetails[autoParametersAttrNumbers.advertisingTrackingEnabled.rawValue] = .constant(advertisingTrackingEnabled ? "1" : "0")
        }
        if properties.isFirstEventAfterAppUpdate {
            sessionDetails[autoParametersAttrNumbers.isFirstEventAfterAppUpdate.rawValue] = .constant("1")
        }
        
        let pageProp = PageProperties(name: nil, details: pageDetails.count == 0 ? nil: pageDetails)
        
        return GlobalProperties(pageProperties: pageProp, sessionDetails: sessionDetails)
    }
    
    static func produceWarningForProperties(properties: BaseProperties){
        
        for (num, type) in autoParameters {
            var doWarning: Bool = false
            let value = properties.trackingParameters?.categories[type]?[num.rawValue]
            
            if value != nil {
                logWarning("auto parameter \"\(num)\" will be overwritten. If you don't want it, remove \"\(type)\" custom parameter number \(num.rawValue) definition.")
            }
        }
    }
}

private class PropertyMerger {
    
    func mergeProperties(first property1: ActionProperties, second property2: ActionProperties, from1Over2: Bool) -> ActionProperties{
        if from1Over2 {
            return property1.merged(over: property2)
        } else {
            return property2.merged(over: property1)
        }
    }
    
    func mergeProperties(first property1: AdvertisementProperties, second property2: AdvertisementProperties, from1Over2: Bool) -> AdvertisementProperties{
        if from1Over2 {
            return property1.merged(over: property2)
        } else {
            return property2.merged(over: property1)
        }
    }
    
    func mergeProperties(first property1: EcommerceProperties, second property2: EcommerceProperties, from1Over2: Bool) -> EcommerceProperties{
        
        if from1Over2 {
            return property1.merged(over: property2)
        } else {
            return property2.merged(over: property1)
        }
    }
    
    func mergeProperties(first property1: MediaProperties, second property2: MediaProperties, from1Over2: Bool) -> MediaProperties{
        if from1Over2 {
            return property1.merged(over: property2)
        } else {
            return property2.merged(over: property1)
        }
    }
    
    func mergeProperties(first property1: PageProperties, second property2: PageProperties, from1Over2: Bool) -> PageProperties{
        if from1Over2 {
            return property1.merged(over: property2)
        } else {
            return property2.merged(over: property1)
        }
    }
    
    func mergeProperties(first property1: [Int: TrackingValue], second property2: [Int: TrackingValue], from1Over2: Bool) -> [Int: TrackingValue]{
        if from1Over2 {
            return property1.merged(over: property2)
        } else {
            return property2.merged(over: property1)
        }
    }
    
    func mergeProperties(first property1: UserProperties, second property2: UserProperties, from1Over2: Bool) -> UserProperties{
        if from1Over2 {
            return property1.merged(over: property2)
        } else {
            return property2.merged(over: property1)
        }
    }
}

