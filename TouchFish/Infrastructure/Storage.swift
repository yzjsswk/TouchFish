import SwiftUI

struct Storage {
    
    static func searchFish(
        fuzzys: String? = nil,
        value: String? = nil,
        description: String? = nil,
        identity: String? = nil,
        type: [FishType]? = nil,
        tags: [[String]]? = nil,
        isMarked: Bool? = nil,
        isLocked: Bool? = nil,
        pageNum: Int? = 1,
        pageSize: Int? = 10
    ) async -> [Fish]? {
        let result = await DataService.searchFish(
            fuzzys: fuzzys,
            value: value,
            description: description,
            identity: identity,
            type: type,
            tags: tags,
            isMarked: isMarked,
            isLocked: isLocked,
            pageNum: pageNum,
            pageSize: pageSize
        )
        switch result {
        case .success(let resp):
            return resp.getFish()
        case .failure(let err):
            Log.error("Storage.searchFish - fail: request data service fail, err=\(err)")
            return nil
        }
    }
    
    static func addFish(
        value: Data, 
        description: String?,
        type: FishType,
        tags: [[String]]?,
        extraInfo: ExtraInfo?
    ) async -> OperateResult {
        defer {
            Cache.refresh()
        }
        let result = await DataService.addFish(
            value: value, description: description, type: type, tags: tags, extraInfo: extraInfo
        )
        switch result {
        case .success(let resp):
            switch resp.status {
            case .success:
                break
            case .skip:
                Log.warning("Storage.addFish - skip: resp.status = skip, msg=\(resp.msg)")
            case .fail:
                Log.error("Storage.addFish - fail: resp.status = fail, msg=\(resp.msg)")
            }
            return resp.status
        case .failure(let err):
            Log.error("Storage.addFish - fail: request data service fail, err=\(err)")
            return .fail
        }
    }
    
    static func modifyFish(
        _ identity: String, description: String? = nil, tags: [[String]]? = nil, extraInfo: ExtraInfo? = nil
    ) async -> OperateResult {
        defer {
            Cache.refresh()
        }
        let result = await DataService.modifyFish(
            identity: identity, description: description, tags: tags, extraInfo: extraInfo
        )
        switch result {
        case .success(let resp):
            switch resp.status {
            case .success:
                break
            case .skip:
                Log.warning("Storage.modifyFish - skip: resp.status = skip, msg=\(resp.msg)")
            case .fail:
                Log.error("Storage.modifyFish - fail: resp.status = fail, msg=\(resp.msg)")
            }
            return resp.status
        case .failure(let err):
            Log.error("Storage.modifyFish - fail: request data service fail, err=\(err)")
            return .fail
        }
    }
    
    static func removeFish(_ identity: String) async -> OperateResult {
        defer {
            Cache.refresh()
        }
        let result = await DataService.removeFish(identity: identity)
        switch result {
        case .success(let resp):
            switch resp.status {
            case .success:
                try? FileManager.default.removeItem(at: TouchFishApp.previewPath.appendingPathComponent(identity))
            case .skip:
                Log.warning("Storage.removeFish - skip: resp.status = skip, msg=\(resp.msg)")
            case .fail:
                Log.error("Storage.removeFish - fail: resp.status = fail, msg=\(resp.msg)")
            }
            return resp.status
        case .failure(let err):
            Log.error("Storage.removeFish - fail: request data service fail, err=\(err)")
            return .fail
        }
    }
    
    static func markFish(_ identity: String) async -> OperateResult {
        defer {
            Cache.refresh()
        }
        let result = await DataService.markFish(identity: identity)
        switch result {
        case .success(let resp):
            switch resp.status {
            case .success:
                break
            case .skip:
                Log.warning("Storage.markFish - skip: resp.status = skip, msg=\(resp.msg)")
            case .fail:
                Log.error("Storage.markFish - fail: resp.status = fail, msg=\(resp.msg)")
            }
            return resp.status
        case .failure(let err):
            Log.error("Storage.markFish - fail: request data service fail, err=\(err)")
            return .fail
        }
    }
    
    static func unMarkFish(_ identity: String) async -> OperateResult {
        defer {
            Cache.refresh()
        }
        let result = await DataService.unMarkFish(identity: identity)
        switch result {
        case .success(let resp):
            switch resp.status {
            case .success:
                break
            case .skip:
                Log.warning("Storage.unMarkFish - skip: resp.status = skip, msg=\(resp.msg)")
            case .fail:
                Log.error("Storage.unMarkFish - fail: resp.status = fail, msg=\(resp.msg)")
            }
            return resp.status
        case .failure(let err):
            Log.error("Storage.unMarkFish - fail: request data service fail, err=\(err)")
            return .fail
        }
    }
    
    static func lockFish(_ identity: String) async -> OperateResult {
        defer {
            Cache.refresh()
        }
        let result = await DataService.lockFish(identity: identity)
        switch result {
        case .success(let resp):
            switch resp.status {
            case .success:
                break
            case .skip:
                Log.warning("Storage.lockFish - skip: resp.status = skip, msg=\(resp.msg)")
            case .fail:
                Log.error("Storage.lockFish - fail: resp.status = fail, msg=\(resp.msg)")
            }
            return resp.status
        case .failure(let err):
            Log.error("Storage.lockFish - fail: request data service fail, err=\(err)")
            return .fail
        }
    }
    
    static func unLockFish(_ identity: String) async -> OperateResult {
        defer {
            Cache.refresh()
        }
        let result = await DataService.unLockFish(identity: identity)
        switch result {
        case .success(let resp):
            switch resp.status {
            case .success:
                break
            case .skip:
                Log.warning("Storage.unLockFish - skip: resp.status = skip, msg=\(resp.msg)")
            case .fail:
                Log.error("Storage.unLockFish - fail: resp.status = fail, msg=\(resp.msg)")
            }
            return resp.status
        case .failure(let err):
            Log.error("Storage.unLockFish - fail: request data service fail, err=\(err)")
            return .fail
        }
    }
    
    static func pinFish(_ identity: String) async -> OperateResult {
        defer {
            Cache.refresh()
        }
        let result = await DataService.pinFish(identity: identity)
        switch result {
        case .success(let resp):
            switch resp.status {
            case .success:
                break
            case .skip:
                Log.warning("Storage.pinFish - skip: resp.status = skip, msg=\(resp.msg)")
            case .fail:
                Log.error("Storage.pinFish - fail: resp.status = fail, msg=\(resp.msg)")
            }
            return resp.status
        case .failure(let err):
            Log.error("Storage.pinFish - fail: request data service fail, err=\(err)")
            return .fail
        }
    }
    
    static func addOrPinFish(
        value: Data,
        type: FishType,
        description: String? = nil,
        tags: [[String]]? = nil,
        extraInfo: ExtraInfo? = nil,
        pin: Bool
    ) async -> Bool {
        let identity = Functions.getMD5(of: value)
        guard let sameFish = await Storage.searchFish(identity: identity) else {
            Log.error("Storage.addOrPinFish - fail: check if fishdata exists fail")
            return false
        }
        if sameFish.isEmpty {
            let addResult = await Storage.addFish(
                value: value, description: description, type: type, tags: tags, extraInfo: extraInfo
            )
            if addResult == .fail {
                Log.error("Storage.addOrPinFish - fail: add fish fail")
                return false
            }
            return true
        }
        if !pin {
            return true
        }
        let pinResult = await Storage.pinFish(identity)
        if pinResult == .fail {
            Log.error("Storage.addOrPinFish - fail: pin fish fail")
            return false
        }
        return true
    }
    
    static func getFishOfSearchCondition() -> [String:Fish] {
        return Cache.fishCache
    }
    
    static func getPreviewOfFish(_ identity: String) -> Data? {
        return Cache.previewDataCache[identity]
    }
    
    static func getTextPreviewByIdentity(_ identity: String) -> String? {
        return Cache.textPreviewCache[identity]
    }
    
    static func getImagePreviewByIdentity(_ identity: String) -> NSImage? {
        return Cache.imagePreviewCache[identity]
    }
    
    static func getTagList() -> [String] {
        return Array(Cache.tagCount.keys).sorted(by: { $0 < $1 } )
    }
    
}

