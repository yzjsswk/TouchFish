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
    
    static var fuzzys: String? = nil { didSet { needRefresh = true } }
    static var value: String? = nil { didSet { needRefresh = true } }
    static var description: String? = nil { didSet { needRefresh = true } }
    static var identity: String? = nil { didSet { needRefresh = true } }
    static var type: [FishType]? = nil { didSet { needRefresh = true } }
    static var tags: [[String]]? = nil { didSet { needRefresh = true } }
    static var isMarked: Bool? = nil { didSet { needRefresh = true } }
    static var isLocked: Bool? = nil { didSet { needRefresh = true } }
    static var pageNum: Int? = nil { didSet { needRefresh = true } }
    static var pageSize: Int? = nil { didSet { needRefresh = true } }
    
    static private var needRefresh = false
    static func start() {
        refresh()
        refreshIfNeed()
        func refreshIfNeed() {
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.5) {
                if needRefresh {
                    needRefresh = false
                    refresh()
                }
                refreshIfNeed()
            }
        }
    }
    
    static private var refreshLock = DispatchSemaphore(value: 1)
    static func refresh() {
        refreshLock.wait()
        Task {
            let startTime = Date()
            refreshStats()
            await refreshFish()
            await refreshPreview()
            refreshPreviewByType()
            await RecipeManager.refresh()
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .CacheRefreshed, object: nil)
            }
            let endTime = Date()
            let timeCost = Int(endTime.timeIntervalSince(startTime)*1000)
//            Log.debug("refresh cache: finished - timeCost=\(timeCost)ms")
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
            pageNum: 1,
            pageSize: 100
        )
        guard case .success(let resp) = result else {
            fishCache.removeAll()
            Log.warning("refresh fish cache - fail: request data service fail")
            Log.verbose(result)
            return
        }
        guard let fishList = resp.getFish() else {
            fishCache.removeAll()
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
            case .tiff, .png, .jpg, .pdf:
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
    
}
