import Foundation
import Alamofire

enum OperateResult: String, Codable {
    case success
    case skip
    case fail
}

struct DataServiceResponse<T: Codable>: Codable {
    
    let timeCost: Int
    let code: String
    let status: OperateResult
    let msg: String
    let data: T?
    
    enum CodingKeys: String, CodingKey {
        case timeCost = "time_cost"
        case code = "code"
        case status = "status"
        case msg = "msg"
        case data = "data"
    }
    
    func getFish() -> [Fish]? {
        if !(data is SearchFishResp) {
            Log.warning("DataServiceResponse.getFish - return nil: is not a searchFishResp")
            return nil
        }
        if status != .success {
            Log.warning("DataServiceResponse.getFish - return nil: DataServiceResponse.status != success")
            return nil
        }
        guard let fishRespList = (data as? SearchFishResp)?.fish else {
            Log.warning("DataServiceResponse.getFish - return nil: DataServiceResponse.data.fish = nil")
            return nil
        }
        return fishRespList.compactMap { fishResp in
            if let fish = fishResp.toFish() {
                return fish
            }
            Log.warning("DataServiceResponse.getFish - ignore a fish: fishResp.toFish return nil, fishResp.identity = \(fishResp.identity)")
            return nil
        }
    }
}

struct NoDataResp: Codable {
    
}

struct StatsResp: Codable {
    let totalCount: Int
    let type: [String: Int]
    let tag: [String: Int]
    let mark: [String: Int]
    let lock: [String: Int]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case type = "type"
        case tag = "tag"
        case mark = "mark"
        case lock = "lock"
    }
}

struct SearchFishResp: Codable {
    let pageNum: Int
    let pageSize: Int
    let totalPage: Int
    let totalCount: Int
    let fish: [FishResp]
    
    enum CodingKeys: String, CodingKey {
        case pageNum = "page_num"
        case pageSize = "page_size"
        case totalPage = "total_page"
        case totalCount = "total_count"
        case fish = "fish"
    }
    
}

struct FishResp: Codable {
    
    let id: Int
    let identity: String
    let type: String
    let byteCount: Int
//    let preview: Data?
    let description: String
    let tags: [[String]]
    let isMarked: Bool
    let isLocked: Bool
    let extraInfo: String
    let createTime: String
    let updateTime: String
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case identity = "identity"
        case type = "type"
        case byteCount = "byte_count"
//        case preview = "preview"
        case description = "description"
        case tags = "tags"
        case isMarked = "is_marked"
        case isLocked = "is_locked"
        case extraInfo = "extra_info"
        case createTime = "create_time"
        case updateTime = "update_time"
    }
    
    func toFish() -> Fish? {
        guard let type = FishType(rawValue: type) else {
            Log.warning("FishResp.toFish - return nil: no such fishType, fishResp.type=\(type), fishResp.identity=\(identity)")
            return nil
        }
        guard let extraInfo = ExtraInfo.load(from: extraInfo) else {
            Log.warning("FishResp.toFish - return nil: ExtraInfo.load return nil, fishResp.extraInfo=\(extraInfo), fishResp.identity=\(identity)")
            return nil
        }
        return Fish(
            id: id,
            identity: identity,
            type: type,
            byteCount: byteCount,
            description: description,
            tags: tags,
            isMarked: isMarked,
            isLocked: isLocked,
            extraInfo: extraInfo,
            createTime: createTime,
            updateTime: updateTime
        )
    }
    
}

struct DataService {
    
    static var urlPrefix: String {
        guard let dataServiceConfig = Config.enableDataServiceConfig else {
            return ""
        }
        return "http://\(dataServiceConfig.host):\(dataServiceConfig.port)"
    }
    
    static func tryConnect(host: String, port: String) async -> Int? {
        let url = "http://\(host):\(port)"
        let startTime = Date()
        let res = await AF.request(url).serializingDecodable(Int.self).result
        let endTime = Date()
        let timeCost = Int(endTime.timeIntervalSince(startTime)*1000)
        switch res {
        case .success(_):
            return timeCost
        case .failure(let err):
            Log.warning("DataService.tryConnect - failed, host=\(host), port = \(port), err=\(err)")
            return nil
        }
    }
    
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
    ) async -> Result<DataServiceResponse<SearchFishResp>, AFError> {
        let url = DataService.urlPrefix + "/fish/search"
        let para: [String:Any?] = [
            "fuzzys": fuzzys,
            "value": value,
            "description": description,
            "identity": identity,
            "type": type?.map { $0.rawValue }.joined(separator: ","),
            "tags": Functions.tagParseStr(tags),
            "is_marked": isMarked,
            "is_locked": isLocked,
            "page_num": pageNum,
            "page_size": pageSize,
            "with_preview": false
        ]
        return await AF.request(
            url, parameters: para.compactMapValues { $0 }
        ).serializingDecodable(DataServiceResponse.self).result
    }
    
    // todo: support upload path version
    static func addFish(
        value: Data, description: String?, type: FishType, tags: [[String]]?, extraInfo: ExtraInfo?
    ) async -> Result<DataServiceResponse<NoDataResp>, AFError> {
        let url = DataService.urlPrefix + "/fish/add"
        let para: [String:Any?] = [
            "description": description,
            "type": type.rawValue,
            "tags": Functions.tagParseStr(tags),
            "extra_info": (extraInfo ?? ExtraInfo()).toJsonString()
        ]
        return await AF.upload(
            multipartFormData: { multipartFormData in
                for (key, value) in para {
                    if let data = (value as? String)?.data(using: .utf8) {
                        multipartFormData.append(data, withName: key)
                    }
                }
                multipartFormData.append(value, withName: "value", fileName: "file", mimeType: "application/octet-stream")
            },
            to: url
        ).serializingDecodable(DataServiceResponse.self).result
    }
    
    static func modifyFish(
        identity: String, description: String? = nil, tags: [[String]]? = nil, extraInfo: ExtraInfo? = nil
    ) async -> Result<DataServiceResponse<NoDataResp>, AFError> {
        let url = DataService.urlPrefix + "/fish/modify"
        let para: [String:Any?] = [
            "identity": identity,
            "description": description,
            "tags": Functions.tagParseStr(tags),
            "extra_info": extraInfo?.toJsonString()
        ]
        return await AF.request(
            url, method: .post, parameters: para.compactMapValues { $0 }
        ).serializingDecodable(DataServiceResponse.self).result
    }
    
    static func removeFish(identity: String) async -> Result<DataServiceResponse<NoDataResp>, AFError> {
        let url = DataService.urlPrefix + "/fish/remove"
        let para: [String:String] = ["identity": identity]
        return await AF.request(
            url, method: .post, parameters: para
        ).serializingDecodable(DataServiceResponse.self).result
    }
    
    static func markFish(identity: String) async -> Result<DataServiceResponse<NoDataResp>, AFError> {
        let url = DataService.urlPrefix + "/fish/mark"
        let para: [String:String] = ["identity": identity]
        return await AF.request(
            url, method: .post, parameters: para
        ).serializingDecodable(DataServiceResponse.self).result
    }
    
    static func unMarkFish(identity: String) async -> Result<DataServiceResponse<NoDataResp>, AFError> {
        let url = DataService.urlPrefix + "/fish/unmark"
        let para: [String:String] = ["identity": identity]
        return await AF.request(
            url, method: .post, parameters: para
        ).serializingDecodable(DataServiceResponse.self).result
    }
    
    static func lockFish(identity: String) async -> Result<DataServiceResponse<NoDataResp>, AFError> {
        let url = DataService.urlPrefix + "/fish/lock"
        let para: [String:String] = ["identity": identity]
        return await AF.request(
            url, method: .post, parameters: para
        ).serializingDecodable(DataServiceResponse.self).result
    }
    
    static func unLockFish(identity: String) async -> Result<DataServiceResponse<NoDataResp>, AFError> {
        let url = DataService.urlPrefix + "/fish/unlock"
        let para: [String:String] = ["identity": identity]
        return await AF.request(
            url, method: .post, parameters: para
        ).serializingDecodable(DataServiceResponse.self).result
    }
    
    static func pinFish(identity: String) async -> Result<DataServiceResponse<NoDataResp>, AFError> {
        let url = DataService.urlPrefix + "/fish/pin"
        let para: [String:String] = ["identity": identity]
        return await AF.request(
            url, method: .post, parameters: para
        ).serializingDecodable(DataServiceResponse.self).result
    }
    
    static func fetchResource(identity: String, savePath: URL) async -> Result<URL, AFError> {
        let url = DataService.urlPrefix + "/resource/fetch"
        let para: [String:String] = ["identity": identity]
        let destination: DownloadRequest.Destination = { _, _ in
            return (
                savePath,
                [.removePreviousFile, .createIntermediateDirectories]
            )
        }
        return await AF.download(
            url, parameters: para, to: destination
        ).serializingDownloadedFileURL().result
    }
    
    static func fetchPreview(identity: String, savePath: URL) async -> Result<URL, AFError> {
        let url = DataService.urlPrefix + "/resource/preview"
        let para: [String:String] = ["identity": identity]
        let destination: DownloadRequest.Destination = { _, _ in
            return (
                savePath,
                [.removePreviousFile, .createIntermediateDirectories]
            )
        }
        // todo: when response return not 200, also download a error file
        return await AF.download(
            url, parameters: para, to: destination
        ).serializingDownloadedFileURL().result
    }
    
    static func statistic() async -> Result<DataServiceResponse<StatsResp>, AFError> {
        let url = DataService.urlPrefix + "/stats"
        return await AF.request(url).serializingDecodable(DataServiceResponse.self).result
    }
    
}



