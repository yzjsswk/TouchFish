import AppKit
import SwiftUI

// todo: sub type ?
enum FishType: String, CaseIterable {
    case txt
    case tiff
    case png
    case jpg
    case pdf
}

extension FishType {
    var index: Int? {
        return FishType.allCases.firstIndex { $0 == self }
    }
}

struct Fish {
    
    var id: Int
    var identity: String
    var type: FishType
    var byteCount: Int
    var description: String
    var tags: [String]
    var isMarked: Bool
    var isLocked: Bool
    var extraInfo: ExtraInfo
    var createTime: String
    var updateTime: String
    
    var value: Data? {
        return Storage.getDataOfFish(self.identity)
    }
    
    var textValue: String? {
        return Storage.getTextByIdentity(self.identity)
    }
    
    var imageValue: NSImage? {
        return Storage.getImageByIdentity(self.identity)
    }
    
    var itemPreview: String {
        switch type {
        case .txt:
            return self.extraInfo.linePreview ?? "..."
        case .tiff:
            return "[image\(self.id)]"
        default:
            return "undefined item preview"
        }
    }
    
    var sourceAppIcon: Image {
        if let sourceAppIconIdentity = self.extraInfo.sourceAppIconIdentity,
           let sourceAppIcon = Storage.getImageByIdentity(sourceAppIconIdentity) {
            return Image(nsImage: sourceAppIcon)
        }
        return Image(systemName: "fish")
    }
    
    func copyToClipboard() {
        guard let fishData = self.value else {
            Log.warning("copy fishdata to clipboard - fail: fish.value return nil, fish.identity=\(self.identity)")
            return
        }
        switch self.type {
        case .txt:
                NSPasteboard.general.declareTypes([.string], owner: nil)
                NSPasteboard.general.setData(fishData, forType: .string)
        case .tiff:
                NSPasteboard.general.declareTypes([.tiff], owner: nil)
                NSPasteboard.general.setData(fishData, forType: .tiff)
        default:
            Log.warning("copy fishdata to clipboard - fail: unsupported fish type, fish.type=\(self.type), fish.identity=\(self.identity)")
        }
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
                Log.error("extra info decode error: \(error)")
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
            Log.error("extra info encode error: \(error)")
        }
        return nil
    }
    
    mutating func fillTextInfo(_ value: String, _ description: String?) {
        let linePreviewText = description ?? value
        let firstLine = linePreviewText.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: "\n", omittingEmptySubsequences: false).first ?? ""
        linePreview = firstLine.count < Config.fishItemPreviewLength ? String(firstLine) : firstLine.prefix(Config.fishItemPreviewLength - 3)+"..."
        charCount = value.count
        wordCount = value.split(separator: " ", omittingEmptySubsequences: false).count
        rowCount = value.split(separator: "\n").count
    }
    
    mutating func fillImageInfo(_ image: NSImage) {
        height = Int(image.size.height)
        width = Int(image.size.width)
        if let tiffRepresentation = image.tiffRepresentation,
           let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) {
            let properties = [NSBitmapImageRep.PropertyKey.compressionFactor: NSNumber(value: 1.0)]
            if let imageData = bitmapImage.representation(using: .png, properties: properties) {
                let imageSize = Double(imageData.count) / 1024.0 // 图片大小以 KB 为单位
                size = Int(imageSize)
            }
        }
    }
    
    var sourceAppIconIdentity: String?
    var linePreview: String?
    var charCount: Int?
    var wordCount: Int?
    var rowCount: Int?
    var height: Int?
    var width: Int?
    var size: Int?
    
}

