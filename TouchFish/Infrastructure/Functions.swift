import AppKit
import CryptoKit
import SwiftUI

struct Functions {
    
    static func getDataFromClipboard() -> (FishType, Data, Any)? {
        if let types = NSPasteboard.general.types, types.count > 0 {
            if let str = NSPasteboard.general.string(forType: .string),
               let data = str.data(using: .utf8) {
                return (.txt, data, str)
            }
            if let data = NSPasteboard.general.data(forType: types[0]) {
                if let img = NSImage(data: data) {
                    return (.tiff, data, img)
                }
            }
            Log.warning("data type not supported from clipboard")
            Log.verbose(types)
        }
        return nil
    }
    
    static func copyDataToClipboard(data: Data, type: FishType) {
        switch type {
        case .txt:
            NSPasteboard.general.declareTypes([.string], owner: nil)
            NSPasteboard.general.setData(data, forType: .string)
        case .tiff, .png, .jpg: // todo: ok?
            NSPasteboard.general.declareTypes([.tiff], owner: nil)
            NSPasteboard.general.setData(data, forType: .tiff)
        default:
            Log.warning("copy data to clipboard - fail: unsupported fish type, type=\(type)")
        }
    }
    
    static func getMD5(of string: String) -> String {
        let data = Data(string.utf8)
        return Functions.getMD5(of: data)
    }
    
    static func getMD5(of filePath: URL) -> String? {
        do {
            let data = try Data(contentsOf: filePath)
            return Functions.getMD5(of: data)
        } catch {
            Log.error("read data of file error: \(error)")
            return nil
        }
    }
    
    static func getMD5(of data: Data) -> String {
        let hashedData = Insecure.MD5.hash(data: data)
        let hashString = hashedData.map { String(format: "%02hhx", $0) }.joined()
        return hashString
    }
    
    static func getLinePreview(_ text: String) -> String {
        let firstLine = text.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: "\n", omittingEmptySubsequences: false).first ?? ""
//        let linePreview = firstLine.count < Config.fishItemPreviewLength ? String(firstLine) : String(firstLine.prefix(Config.fishItemPreviewLength))
        return String(firstLine)
    }
    
    static func descByteCount(_ byteCount: Int) -> String {
        if byteCount < 1024 {
            return "\(byteCount)B"
        }
        let KBCount = byteCount / 1024
        if KBCount < 1024 {
            return "\(KBCount)KB"
        }
        let MBCount = KBCount / 1024
        if MBCount < 1024 {
            return "\(MBCount)MB"
        }
        let GBCount = Double(MBCount) / 1024
        return "\(GBCount)GB"
    }
    
    static func tagParseStr(_ tags: [[String]]?) -> String? {
        guard let tags = tags else {
            return nil
        }
        var tagPara: [String] = []
        for tagGroup in tags {
            tagPara.append(tagGroup.joined(separator: ","))
        }
        return tagPara.joined(separator: "|")
    }
    
    static func runCommand(cmd: String, args: [String] = []) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: cmd)
        process.arguments = args

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
        } catch {
            Log.error("runCommand - fail: \(error.localizedDescription)")
            return nil
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)
    }
    
    static func getFileSize(atPath path: String) -> UInt64? {
        let fileManager = FileManager.default
        do {
            let attributes = try fileManager.attributesOfItem(atPath: path)
            if let fileSize = attributes[.size] as? UInt64 {
                return fileSize
            } else {
                return nil
            }
        } catch {
            Log.error("Functions.getFileSize - fail: \(error)")
            return nil
        }
    }
    
}



extension String {
    // This lets you subscript a String.
    subscript(idx: Int) -> String {
        String(self[index(startIndex, offsetBy: idx)])
    }
    
    public func firstCharacterCapitalized() -> String {
        let capitalizedFirstCharacter = self.first!.uppercased()
        let stringWithoutFirstCharacter = self.dropFirst()
        
        return capitalizedFirstCharacter + stringWithoutFirstCharacter
    }
    
    func splitOnce(separator: Character) -> (String, String)? {
        if let index = self.firstIndex(of: separator) {
            let before = self[..<index]
            let after = self[self.index(after: index)...]
            return (String(before), String(after))
        }
        return nil
    }
    
    var nsColor: NSColor {
        let hexString = self.replacingOccurrences(of: "#", with: "").replacingOccurrences(of: "0x", with: "")
        let scanner = Scanner(string: hexString)
        var resultInt: UInt64 = 0
        scanner.scanHexInt64(&resultInt)
        let red = CGFloat((resultInt & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((resultInt & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((resultInt & 0xFF)) / 255.0
        return NSColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    var color: Color {
        return Color(nsColor)
    }
    
    var icon: Image? {
        if self.hasPrefix("system:") {
            let systemIconName = String(self.dropFirst(7))
            return Image(systemName: systemIconName)
        }
        if self.hasPrefix("fish:") {
            let fishIdentity = String(self.dropFirst(5))
            // todo: use resource
            if let fishImage = Storage.getImagePreviewByIdentity(fishIdentity) {
                return Image(nsImage: fishImage)
            }
        }
        return nil
    }
    
}

extension Notification.Name {
    static let ReturnKeyWasPressed = Notification.Name("ReturnKeyWasPressed")
    static let UpArrowKeyWasPressed = Notification.Name("UpArrowKeyWasPressed")
    static let DownArrowKeyWasPressed = Notification.Name("DownArrowKeyWasPressed")
    static let TabKeyWasPressed = Notification.Name("TabKeyWasPressed")
    static let EscapeKeyWasPressed = Notification.Name("EscapeKeyWasPressed")
    static let SpaceKeyWasPressed = Notification.Name("SpaceKeyWasPressed")
    static let DeleteKeyWasPressed = Notification.Name("DeleteKeyWasPressed")
    static let CommandKeyWasPressed = Notification.Name("CommandKeyWasPressed")
    static let ApplicationShouldExit = Notification.Name("ApplicationShouldExit")
    static let ShouldPresentQuickLook = Notification.Name("ShouldPresentQuickLook")
    static let ShouldDeleteClipboardHistoryItem = Notification.Name("ShouldDeleteClipboardHistoryItem")
    static let ShouldDeleteClipboardHistory = Notification.Name("ShouldDeleteClipboardHistory")
    static let ShouldShowFishView = Notification.Name("ShouldShowFishView")
    static let CacheRefreshed = Notification.Name("CacheRefreshed")
    static let RecipeStatusChanged = Notification.Name("RecipeStatusChanged")
    static let CommandTextChanged = Notification.Name("CommandTextChanged")
    static let CommandBarEndEditing = Notification.Name("CommandBarEndEditing")
}

