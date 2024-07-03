import AppKit
import SwiftUI

// todo: sub type ?
enum FishType: String, CaseIterable {
    case txt
    case tiff
    case png
    case jpg
    case pdf
    case other
}

struct Fish {
    
    var id: Int
    var identity: String
    var type: FishType
    var byteCount: Int
    var description: String
    var tags: [[String]]
    var isMarked: Bool
    var isLocked: Bool
    var extraInfo: ExtraInfo
    var createTime: String
    var updateTime: String
    
    var preview: Data? {
        return Storage.getPreviewOfFish(self.identity)
    }
    
    var textPreview: String? {
        return Storage.getTextPreviewByIdentity(self.identity)
    }
    
    var imagePreview: NSImage? {
        return Storage.getImagePreviewByIdentity(self.identity)
    }
    
    var defaultLinePreview: String {
        return "\(self.type.rawValue):\(self.identity)"
    }
    
    var linePreview: String {
        switch type {
        case .txt:
            if self.description.count > 0 {
                return Functions.getLinePreview(self.description)
            }
            if let textPreview = self.textPreview {
                return Functions.getLinePreview(textPreview)
            }
            return self.defaultLinePreview
        case .tiff, .png, .jpg:
            if self.description.count > 0 {
                return Functions.getLinePreview(self.description)
            }
            return self.defaultLinePreview
        default:
            if self.description.count > 0 {
                return Functions.getLinePreview(self.description)
            }
            return self.defaultLinePreview
        }
    }
    
    var fishIcon: Image {
        switch type {
        case .txt:
            return Image(systemName: "doc.plaintext")
        case .tiff, .png, .jpg:
            return Image(systemName: "photo")
        case .pdf:
            return Image(systemName: "book.pages")
        default:
            return Image(systemName: "fish")
        }
    }
    
    var fishIconColor: Color {
        switch type {
        case .txt:
            return .black
        case .tiff, .png, .jpg:
            return .blue
        case .pdf:
            return .red
        default:
            return .black
        }
    }
    
    func copyToClipboard() {
        guard let fishData = self.preview else {
            Log.warning("copy fishdata to clipboard - fail: fish.value return nil, fish.identity=\(self.identity)")
            return
        }
        Functions.copyDataToClipboard(data: fishData, type: self.type)
    }
    
}

struct ExtraInfo: Codable {
    
    static func load(from jsonStr: String) -> ExtraInfo? {
        if jsonStr.isEmpty {
            return ExtraInfo()
        }
        let decoder = JSONDecoder()
        let data = jsonStr.data(using: .utf8)
        if let data = data {
            do {
                return try decoder.decode(ExtraInfo.self, from: data)
            } catch {
                Log.error("parse extraInfo from json str - fail, err=\(error)")
            }
        }
        return nil;
    }
    
    func toJsonString() -> String? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(self)
            return String(data: data, encoding: .utf8)
        } catch {
            Log.error("parse extraInfo to json str - fail, err=\(error)")
        }
        return nil
    }
    
    // extra info
    
    var sourceAppName: String?
    var charCount: Int?
    var wordCount: Int?
    var rowCount: Int?
    var width: Int?
    var height: Int?
    var pageCount: Int?

    enum CodingKeys: String, CodingKey {
        case sourceAppName = "source_app_name"
        case charCount = "char_count"
        case wordCount = "word_count"
        case rowCount = "row_count"
        case width = "width"
        case height = "height"
        case pageCount = "page_count"
    }
    
}

