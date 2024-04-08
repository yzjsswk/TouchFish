import Foundation

enum operateResult {
    case success
    case skip
    case fail
}

protocol FishOperator {
    
    static func searchFish (
        fuzzys: String?,
        value: String?,
        description: String?,
        identity: String?,
        type: FishType?,
        tags: [String]?,
        isMarked: Bool?,
        isLocked: Bool?,
        pageNum: Int?,
        pageSize: Int?
    ) -> [Fish]
    
    static func pickFish (
        id: Int
    ) -> Fish
    
    static func addFish (
        value: Data,
        description: String?,
        type: FishType,
        tags: [String],
        extraInfo: ExtraInfo
    ) -> operateResult
    
    static func modifyFish (
        identity: String,
        description: String?,
        tags: [String]?,
        extraInfo: ExtraInfo?
    ) -> operateResult
    
    static func removeFish (
        identity: String
    ) -> operateResult
    
    static func markFish (
        identity: String
    ) -> operateResult
    
    static func unMarkFish (
        identity: String
    ) -> operateResult
    
    static func lockFish (
        identity: String
    ) -> operateResult
    
    static func unLockFish (
        identity: String
    ) -> operateResult
    
    static func pinFish (
        identity: String
    ) -> operateResult
    
}





