import Foundation

internal struct AdClearId {
    private static let bitsOfMilliseconds: UInt64 = 39
    private static let bitsOfRandom: UInt64 = 10
    private static let bitsOfApplication: UInt64 = 10
    private static let bitsOfProcess: UInt64 = 4
    private static let bitShiftForApplication: UInt64 = bitsOfProcess
    private static let bitShiftForCounter: UInt64 = bitShiftForApplication + bitsOfApplication
    private static let bitShiftForTimestamp: UInt64 = bitShiftForCounter + bitsOfRandom
    private static let milliSecondsUntil01122011: UInt64 = 1293840000000
    private static let applicationId = 713
    
    public static func getAdClearId() -> UInt64 {
        var adClearId = UserDefaults.standardDefaults.child(namespace: "webtrekk").uInt64ForKey(DefaultsKeys.adClearId)
        
        if adClearId != nil {
            return adClearId!
        }
        
        adClearId = generateAdClearId()
        UserDefaults.standardDefaults.child(namespace: "webtrekk").set(key: DefaultsKeys.adClearId, to: adClearId)
        
        return adClearId!
    }
    
    private static func generateAdClearId() -> UInt64 {
        let diffInMilliseconds = UInt64(round(Date().timeIntervalSince1970 * 100000)) - milliSecondsUntil01122011
        let randomInt = UInt64(arc4random_uniform(99999999) + 1)
        let processId = UInt64(ProcessInfo().processIdentifier)
        
        return combineAdClearId(diffInMilliseconds: diffInMilliseconds, randomInt: randomInt, processId: processId)
    }
    
    private static func combineAdClearId(diffInMilliseconds: UInt64, randomInt: UInt64, processId: UInt64) -> UInt64 {
        
        let adClearId = ((AdClearId.limitBitsTo(value: diffInMilliseconds, maxBits: bitsOfMilliseconds) << bitShiftForTimestamp)
            + (AdClearId.limitBitsTo(value: randomInt, maxBits: bitsOfRandom) << bitShiftForCounter)
            + (AdClearId.limitBitsTo(value: UInt64(AdClearId.applicationId), maxBits: bitsOfApplication) << bitShiftForApplication)
            + AdClearId.limitBitsTo(value: processId, maxBits: bitsOfProcess))
        
        return adClearId
    }
    
    private static func limitBitsTo(value: UInt64, maxBits: UInt64) -> UInt64 {
        let maxLength = (1 << maxBits) - 1
        
        return value & maxLength
    }
}
