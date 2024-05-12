import AppKit

struct Cache {
    
    static var fishCache: [String:Fish] = [:]
    static var previewDataCache: [String:Data] = [:]
    static var textPreviewCache: [String:String] = [:]
    static var imagePreviewCache: [String:NSImage] = [:]
    
    static var totalCount = 0
    static var typeCount = [String:Int]()
    static var tagCount = [String:Int]()
    static var markCount = 0
    static var unMarkCount = 0
    static var lockCount = 0
    static var unLockCount = 0
    
    static var fuzzys: String? = nil { didSet { refresh() } }
    static var value: String? = nil { didSet { refresh() } }
    static var description: String? = nil { didSet { refresh() } }
    static var identity: String? = nil { didSet { refresh() } }
    static var type: [FishType]? = nil { didSet { refresh() } }
    static var tags: [String]? = nil { didSet { refresh() } }
    static var isMarked: Bool? = nil { didSet { refresh() } }
    static var isLocked: Bool? = nil { didSet { refresh() } }
    static var pageNum: Int? = nil { didSet { refresh() } }
    static var pageSize: Int? = nil { didSet { refresh() } }
    
    static func start() {
        refresh()
//        refreshByTime()
//        func refreshByTime() {
//            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 60) {
//                refresh()
//                refreshByTime()
//            }
//        }
    }
    
    static private var refreshLock = DispatchSemaphore(value: 1)
    static func refresh() {
        refreshLock.wait()
        Task {
//            Log.debug("refresh cache - start")
            refreshStats()
            await refreshFish()
            await refreshPreview()
            refreshPreviewByType()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .ShouldRefreshFishList, object: nil)
            }
//            Log.debug("refresh cache - end")
            refreshLock.signal()
        }
    }
    
    static func refreshStats() {
        Task {
            let result = await DataService.statistic()
            guard case .success(let resp) = result else {
                Log.warning("refresh statistic - fail: request data service fail")
                Log.verbose(result)
                return
            }
            guard let stats = resp.data else {
                Log.warning("refresh statistic - fail: resp.data = nil")
                return
            }
            totalCount = stats.totalCount
            typeCount = stats.type
            tagCount = stats.tag
            markCount = stats.mark["marked", default: 0]
            unMarkCount = stats.mark["unmarked", default: 0]
            lockCount = stats.mark["locked", default: 0]
            unLockCount = stats.mark["unlocked", default: 0]
        }
    }
    
    static func refreshFish() async {
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
        guard case .success(let resp) = result else {
            Log.warning("refresh fish cache - fail: request data service fail")
            Log.verbose(result)
            return
        }
        guard let fishList = resp.getFish() else {
            Log.warning("refresh fish cache - fail: dataService.searchFish..getFish return nil")
            return
        }
        fishCache = fishList.reduce(into: [:]) { $0[$1.identity] = $1 }
    }
    
    static func refreshPreview() async {
//        let existingPreviewIdentitys = (try? FileManager.default.contentsOfDirectory(atPath: TouchFishApp.previewPath.path)) ?? []
//        for identity in existingPreviewIdentitys {
//            if fishCache
//        }
        await withTaskGroup(of: URL?.self) { taskgroup in
            for (identity, _) in fishCache {
                if previewDataCache.keys.contains(identity) {
                    continue
                }
                let curPath = TouchFishApp.previewPath.appendingPathComponent(identity)
                if let curData = FileManager.default.contents(atPath: curPath.path) {
                    previewDataCache[identity] = curData
                    continue
                }
                // todo: max resource size auto fetch
                taskgroup.addTask {
                    let result = await DataService.fetchPreview(identity: identity, savePath: curPath)
                    switch result {
                    case .success(let url):
                        let curData = FileManager.default.contents(atPath: url.path)
                        previewDataCache[identity] = curData
                        return url
                    case .failure(let err):
                        Log.error("refresh preview cache - fetch preview data failed: DataService.fetchPreview return failure, err=\(err)")
                        return nil
                    }
                }
            }
        }
    }
    
    static func refreshPreviewByType() {
        for (identity, fish) in fishCache {
            guard let previewData = previewDataCache[identity] else {
                Log.warning("refresh preview by type - ignore a preview: preview data not found in previewCache, identity=\(identity)")
                continue
            }
            if previewData.isEmpty {
                Log.warning("refresh preview by type - ignore a preview: preview data is empty, identity=\(identity)")
                continue
            }
            switch fish.type {
            case .txt:
                if textPreviewCache.keys.contains(identity) {
                    continue
                }
                if let value = String(data: previewData, encoding: .utf8) {
                    textPreviewCache[identity] = value
                } else {
                    Log.warning("refresh preview by type - ignore a preview: preview data parse fail, identity=\(identity), type=\(fish.type)")
                }
            case .tiff, .png, .jpg:
                if imagePreviewCache.keys.contains(identity) {
                    continue
                }
                if let value = NSImage(data: previewData) {
                    imagePreviewCache[identity] = value
                } else {
                    Log.warning("refresh preview by type - ignore a preview: preview data parse fail, identity=\(identity), type=\(fish.type)")
                }
            default:
                break
            }
        }
    }
    
//    struct FishCache {
//        static var fishList: [Fish] = []
//        static var totalCount = 0
//        static var valueOrDesc: String? = nil { didSet { refresh() } }
//        static var identity: String? = nil { didSet { refresh() } }
//        static var type: [FishType]? = nil { didSet { refresh() } }
//        static var tag: [String]? = nil { didSet { refresh() } }
//        static var source: [Source]? = nil { didSet { refresh() } }
//        static var isMarked: Bool? = nil { didSet { refresh() } }
//        
//        static func refresh() {
//            Log.debug("fish cache refresh start")
//            let res = DB.searchFish(valueOrDesc: valueOrDesc, identity: identity, type: type, tag: tag, source: source, isMarked: isMarked)
//            fishList = Array<Fish>(res.prefix(100))
//            totalCount = res.count
////            fishList.sort { $0.updateTime > $1.updateTime }
//            DispatchQueue.main.async {
//                NotificationCenter.default.post(name: .ShouldRefreshFishList, object: nil)
//            }
//            Log.debug("fish cache refresh end")
//        }
//    }

//    struct ResourceCache {
//        static var images: [URL:NSImage] = [:]
//        static var totalBytes: Int = 0
//        
//        static func refresh() {
//            var newImages: [URL:NSImage] = [:]
//            var newTotalBytes = 0
//            let resourcePath = Config.workPath.appendingPathComponent("resource")
//            let resources = (try? FileManager.default.contentsOfDirectory(atPath: resourcePath.path)) ?? []
//            for resource in resources {
//                let curPath = resourcePath.appendingPathComponent(resource)
//                if let curData = FileManager.default.contents(atPath: curPath.path),
//                   let image = NSImage(data: curData) {
//                    newImages[curPath] = image
//                    newTotalBytes += curData.count
//                }
//            }
//            images = newImages
//            totalBytes = newTotalBytes
//        }
//        
//        static func searchImageByIdentity(identity: String) -> NSImage? {
//            if let url = searchURLByIdentity(identity: identity) {
//                return images[url]
//            }
//            return nil
//        }
//        
//        static func searchURLByIdentity(identity: String) -> URL? {
//            return images.keys.first(where: { $0.lastPathComponent.starts(with: identity) })
//        }
//    }
    
}
