import SwiftUI

struct Storage {
    
    static func searchFish(
        fuzzys: String? = nil,
        value: String? = nil,
        description: String? = nil,
        identity: String? = nil,
        type: [FishType]? = nil,
        tags: [String]? = nil,
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
        value: Data, description: String?, type: FishType, tags: [String]?, extraInfo: ExtraInfo?
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
        _ identity: String, description: String? = nil, tags: [String]? = nil, extraInfo: ExtraInfo? = nil
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
                break
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
        tags: [String]? = nil,
        extraInfo: ExtraInfo? = nil
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
        let pinResult = await Storage.pinFish(identity)
        if pinResult == .fail {
            Log.error("Storage.addOrPinFish - fail: pin fish fail")
            return false
        }
        return true
    }
    
    static func getFishOfSearchCondition() -> [Fish] {
        let fishList = Array(Cache.fishCache.values)
        //       fishList = Array<Fish>(res.prefix(100))
        //       totalCount = res.count
        //       fishList.sort { $0.updateTime > $1.updateTime }
        return fishList.sorted { (fish1, fish2) -> Bool in
            if fish1.updateTime == fish2.updateTime {
                return fish1.identity > fish2.identity
            }
            return fish1.updateTime > fish2.updateTime
        }
    }
    
    static func getDataOfFish(_ identity: String) -> Data? {
        return Cache.resourceCache[identity]
    }
    
    static func getTextByIdentity(_ identity: String) -> String? {
        return Cache.textValueCache[identity]
    }
    
    static func getImageByIdentity(_ identity: String) -> NSImage? {
        return Cache.imageValueCache[identity]
    }
    

    
//    // return if succeed
//    static func saveTextFish(value: String, description: String? = nil, source: Source, tag: [String]? = nil, extraInfo: ExtraInfo? = nil, id: Int? = nil) -> Bool {
//        let identity = Functions.getMD5(of: value)
//        var extraInfo = extraInfo ?? ExtraInfo()
//        extraInfo.fillTextInfo(value, description)
//        // if id is not nil, do update
//        if let id = id {
//            return DB.updateFish(of: id, identity: identity, type: .text, value: value, description: description, tag: tag, extraInfo: extraInfo)
//        }
//        // if (identity, type, source) is not existed, do insert
//        let searchRes = DB.searchFish(identity: identity, type: [.text], source: [source])
//        if searchRes.isEmpty {
//            return DB.addFish(value: value, description: description ?? "", identity: identity, type: .text, source: source, tag: tag ?? [], extraInfo: extraInfo) != nil
//        }
//        // if (identity, type, source) is existed, update and pin it
//        if searchRes.count == 1 {
//            return DB.updateFish(of: searchRes[0].id, identity: identity, type: .text, value: value, description: description, tag: tag, source: source, extraInfo: extraInfo)
//        }
//        Log.warning("(identity=\(identity), type=text, source=\(source) duplicated in database")
//        return false;
//    }
//    
//    // return if succeed
//    static func saveImageFish(image: NSImage, description: String? = nil, source: Source, tag: [String]? = nil, extraInfo: ExtraInfo? = nil, id: Int? = nil) -> Bool {
//        guard let imageData = image.tiffRepresentation else {
//            Log.warning("save image fish failed: data of image is nil")
//            return false
//        }
//        guard let savedPath = Storage.saveDataToFile(data: imageData) else {
//            Log.warning("save image fish failed: save image to file failed")
//            return false
//        }
//        let value = savedPath.path
//        let identity = Functions.getMD5(of: imageData)
//        var extraInfo = extraInfo ?? ExtraInfo()
//        extraInfo.fillTextInfo(value, description)
//        extraInfo.fillImageInfo(image)
//        // if id is not nil, do update
//        if let id = id {
//            return DB.updateFish(of: id, identity: identity, type: .image, value: value, description: description, tag: tag, extraInfo: extraInfo)
//        }
//        // if (identity, type, source) is not existed, do insert
//        let searchRes = DB.searchFish(identity: identity, type: [.image], source: [source])
//        if searchRes.isEmpty {
//            return DB.addFish(value: value, description: description ?? "", identity: identity, type: .image, source: source, tag: tag ?? [], extraInfo: extraInfo) != nil
//        }
//        // if (identity, type, source) is existed, update and pin it
//        if searchRes.count == 1 {
//            return DB.updateFish(of: searchRes[0].id, identity: identity, type: .image, value: value, description: description, tag: tag, source: source, extraInfo: extraInfo)
//        }
//        Log.warning("(identity=\(identity), type=image, source=\(source) duplicated in database")
//        return false;
//    }
    
//    static func getTextByIdentity(identity: String) -> String? {
//        let searchRes = DB.searchFish(identity: identity, type: [.text])
//        return searchRes.first?.value
//    }
//    
//    static func getImageByIdentity(identity: String) -> NSImage? {
//        if let image = Cache.ImageCache.searchImageByIdentity(identity: identity) {
//            return image
//        }
//        let searchRes = DB.searchFish(identity: identity, type: [.image])
//        if let path = searchRes.first?.value, let image = Cache.ImageCache.images[URL(fileURLWithPath: path)] {
//            return image
//        }
//        return nil
//    }
//    
//    static func searchFileURLByIdentity(identity: String) -> URL? {
//        let resourcePath = Config.workPath.appendingPathComponent("resource")
//        let resources = (try? FileManager.default.contentsOfDirectory(atPath: resourcePath.path)) ?? []
//        for resource in resources {
//            if resource.starts(with: identity) {
//                return resourcePath.appendingPathComponent(resource)
//            }
//        }
//        return nil
//    }
//    
//    static func searchFileURLByIdentityWithCheck(identity: String) -> URL? {
//        let resourcePath = Config.workPath.appendingPathComponent("resource")
//        let resources = (try? FileManager.default.contentsOfDirectory(atPath: resourcePath.path)) ?? []
//        for resource in resources {
//            if !resource.starts(with: identity) {
//                continue
//            }
//            let curPath = resourcePath.appendingPathComponent(resource)
//            if let curData = Storage.readDataFromFile(of: curPath), Functions.getMD5(of: curData) == identity {
//                return curPath
//            }
//        }
//        return nil
//    }
//    
//    static private var lastTs: TimeInterval = Date().timeIntervalSince1970
//    static private var saveCount: Int = 0
//    static private func fileSaveFrequencyControl() -> Bool {
//        let curTs = Date().timeIntervalSince1970
//        if curTs - Storage.lastTs > Config.fileSaveLimitInterval {
//            Storage.lastTs = curTs
//            Storage.saveCount = 0
//        }
//        if Storage.saveCount > Config.fileSaveLimitCount {
//            return false
//        }
//        Storage.saveCount += 1
//        return true
//    }
//    
//    static func saveDataToFile(data: Data) -> URL? {
//        let identity = Functions.getMD5(of: data)
//        if let existFile = Storage.searchFileURLByIdentityWithCheck(identity: identity) {
//            return existFile
//        }
//        if !Storage.fileSaveFrequencyControl() {
//            Log.error("save data to file failed: too frequent")
//            return nil
//        }
//        let savePath = Config.workPath.appendingPathComponent("resource/\(identity)_\(Int(Date().timeIntervalSince1970))")
//        do {
//            try data.write(to: savePath)
//            Cache.ImageCache.refresh()
//        } catch {
//            Log.error("save data to file failed: \(error)")
//            return nil
//        }
//        return savePath;
//    }
//    
//    // tood: remove
//    static func readDataFromFile(of filePath: URL) -> Data? {
//        return FileManager.default.contents(atPath: filePath.path)
//    }
    
}

