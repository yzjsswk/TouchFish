import AppKit
import SwiftUI

class Fish {
    
    enum FishType: String, CaseIterable {
        case Text
        case Image
    }
    
    struct DataInfo: Codable {
        let byteCount: Int?
        let charCount: Int?
        let wordCount: Int?
        let rowCount: Int?
        let width: Int?
        let height: Int?
    }
    
    struct ExtraInfo: Codable {
        
        var sourceAppName: String?

        enum CodingKeys: String, CodingKey {
            case sourceAppName = "source_app_name"
        }
        
        static func from_json_string(json_str: String) -> ExtraInfo? {
            if json_str.isEmpty {
                return ExtraInfo()
            }
            let decoder = JSONDecoder()
            let data = json_str.data(using: .utf8)
            if let data = data {
                do {
                    return try decoder.decode(ExtraInfo.self, from: data)
                } catch {
                    Log.error("parse extraInfo from json string - failed, err=\(error)")
                }
            }
            return nil;
        }
        
        func to_json_string() -> String? {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            do {
                let data = try encoder.encode(self)
                return String(data: data, encoding: .utf8)
            } catch {
                Log.error("parse extraInfo to json string - failed, err=\(error)")
            }
            return nil
        }
        
    }

    let identity: String
    let count: Int
    let fishType: FishType
    let fishData: Data
    let dataInfo: DataInfo
    let description: String
    let tags: [String]
    let isMarked: Bool
    let isLocked: Bool
    let extraInfo: ExtraInfo
    let createTime: String
    let updateTime: String
    
    let textData: String?
    let imageData: NSImage?
    
    init(identity: String, count: Int, fishType: FishType, fishData: Data, dataInfo: DataInfo, description: String, tags: [String], isMarked: Bool, isLocked: Bool, extraInfo: ExtraInfo, createTime: String, updateTime: String) {
        self.identity = identity
        self.count = count
        self.fishType = fishType
        self.fishData = fishData
        self.dataInfo = dataInfo
        self.description = description
        self.tags = tags
        self.isMarked = isMarked
        self.isLocked = isLocked
        self.extraInfo = extraInfo
        self.createTime = createTime
        self.updateTime = updateTime
        
        switch fishType {
        case .Text:
            self.textData = String(data: fishData, encoding: .utf8)
            self.imageData = nil
        case .Image:
            self.textData = nil
            self.imageData = NSImage(data: fishData)
        }
        
    }
    
    var defaultLinePreview: String {
        return "\(self.fishType.rawValue):\(self.identity)"
    }
    
    var linePreview: String {
        var ret: String = self.defaultLinePreview
        switch self.fishType {
        case .Text:
            if self.description.count > 0 {
                ret = Functions.getLinePreview(self.description)
            }
            if let textData = self.textData {
                ret = Functions.getLinePreview(textData)
            }
        case .Image:
            if self.description.count > 0 {
                ret = Functions.getLinePreview(self.description)
            }
        default:
            if self.description.count > 0 {
                ret = Functions.getLinePreview(self.description)
            }
        }
        if self.count > 1 {
            ret = "(\(self.count))" + ret
        }
        return ret
    }
    
    var fishIcon: Image {
        switch self.fishType {
        case .Text:
            return Image(systemName: "doc.plaintext")
        case .Image:
            return Image(systemName: "photo")
        default:
            return Image(systemName: "fish")
        }
    }
    
    var fishIconColor: Color {
        switch self.fishType {
        case .Text:
            return .black
        case .Image:
            return .blue
        default:
            return .black
        }
    }
    
    func copyToClipboard() {
        Functions.copyDataToClipboard(data: self.fishData, type: self.fishType)
    }
    
}
