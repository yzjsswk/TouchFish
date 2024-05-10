import AppKit

struct Cache {
    
    static var fishCache: [String:Fish] = [:]
    static var resourceCache: [String:Data] = [:]
    static var textValueCache: [String:String] = [:]
    static var imageValueCache: [String:NSImage] = [:]
    
    static var totalCount = 0
    // todo: statistics
    
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
            Log.debug("refresh cache - start")
            await refreshFish()
            await refreshResource()
            refreshValueCache()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .ShouldRefreshFishList, object: nil)
            }
            Log.debug("refresh cache - end")
            refreshLock.signal()
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
    
    static func refreshResource() async {
        let resourcePath = Config.workPath.appendingPathComponent("resource")
//        let resourceFileNames = (try? FileManager.default.contentsOfDirectory(atPath: resourcePath.path)) ?? []
        await withTaskGroup(of: URL?.self) { taskgroup in
            for (identity, _) in fishCache {
                if resourceCache.keys.contains(identity) {
                    continue
                }
                let curPath = resourcePath.appendingPathComponent(identity)
                if let curData = FileManager.default.contents(atPath: curPath.path) {
                    resourceCache[identity] = curData
                    continue
                }
                // todo: max resource size auto fetch
                taskgroup.addTask {
                    let result = await DataService.fetchResource(identity: identity, savePath: curPath)
                    switch result {
                    case .success(let url):
                        let curData = FileManager.default.contents(atPath: url.path)
                        resourceCache[identity] = curData
                        return url
                    case .failure(let err):
                        Log.error("refresh resource cache - fetch fishdata failed: DataService.fetchResource return failure, err=\(err)")
                        return nil
                    }
                }
            }
        }
    }
    
    static func refreshValueCache() {
        for (identity, fish) in fishCache {
            guard let fishData = resourceCache[identity] else {
                Log.warning("refresh value cache - value cache lose one: fishdata not found in resourceCache, identity=\(identity)")
                continue
            }
            switch fish.type {
            case .txt:
                if textValueCache.keys.contains(identity) {
                    continue
                }
                if let value = String(data: fishData, encoding: .utf8) {
                    textValueCache[identity] = value
                } else {
                    Log.warning("refresh value cache - value cache lose one: fishdata parse fail, identity=\(identity), type=\(fish.type)")
                }
            case .tiff:
                if imageValueCache.keys.contains(identity) {
                    continue
                }
                if let value = NSImage(data: fishData) {
                    imageValueCache[identity] = value
                } else {
                    Log.warning("refresh value cache - value cache lose one: fishdata parse fail, identity=\(identity), type=\(fish.type)")
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
