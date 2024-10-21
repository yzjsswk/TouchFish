import AppKit
import CryptoKit
import SwiftUI
import Cocoa

struct Constant {
    
    static let mainWidth: CGFloat = 800
    static let mainHeight: CGFloat = 600
    static let commandBarHeight: CGFloat = 40
    static let commandFieldHeight: CGFloat = 28
    static let userDefinedRecipeItemHeight: CGFloat = 50
    static let recipeItemHeight: CGFloat = 40
    static let recipeItemSelectedHeight: CGFloat = 55
    static let fishItemHeight: CGFloat = 24
    static let fishItemIconWidth: CGFloat = 20
    static let fishItemPreviewLength: CGFloat = 40
    static let fishDetailItemHeight: CGFloat = 10
    static let messageItemHeight: CGFloat = 60
    
    static let backgroundColor = LinearGradient(colors: ["ECEEF1".color, "F1FAF1".color, "ECEEF1".color], startPoint: .leading, endPoint: .trailing)
    static let mainBackgroundColor: String = "ECEEF1"
    static let commandBarBackgroundColor: String = "D8D8DB"
    static let selectedItemBackgroundColor: String = "502A70"
    static let commandFieldBackgroundColor: String = "282A36"
    static let commandFieldInsertionPointColor: String = "F8F8F2"
    static let internalRecipeItemColor: String = "D8D8DB"
    static let userDefinedRecipeDefaultIemColor: String = "D8D8DB"
    static let errorMessageColor: String = "DA5448"
    static let unreadMessageTipColor: String = "E2503F"
    
    static let maxDataSizeAddFish = 1024 * 1024 * 1024 // 1GB
    
}

struct Functions {
    
    static func getDataFromClipboard() -> (Fish.FishType, Data, Any)? {
        if let types = NSPasteboard.general.types, types.count > 0 {
            if let str = NSPasteboard.general.string(forType: .string),
               let data = str.data(using: .utf8) {
                return (.Text, data, str)
            }
            if let data = NSPasteboard.general.data(forType: types[0]) {
                if let img = NSImage(data: data) {
                    return (.Image, data, img)
                }
            }
            // reach here would repeat logging
//            Log.warning("get data from clipboard - return nil: data type not supported, types=\(types)")
        }
        return nil
    }
    
    static func copyDataToClipboard(data: Data, type: Fish.FishType) {
        switch type {
        case .Text:
            NSPasteboard.general.declareTypes([.string], owner: nil)
            NSPasteboard.general.setData(data, forType: .string)
        case .Image:
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
    
    static func runCommand(cmd: String, args: [String] = []) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: cmd)
        process.arguments = args
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        do {
            try process.run()
            Log.debug("here")
            process.waitUntilExit()
            Log.debug("here")
            if let data = try pipe.fileHandleForReading.readToEnd() {
                Log.debug("here")
                return String(data: data, encoding: .utf8)
            }
        } catch {
            Log.error("runCommand - fail: \(error)")
        }
        return nil
    }
    
    static func runCommandAsync(cmd: String, args: [String] = [], completion: @escaping (String?) -> Void) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: cmd)
        process.arguments = args
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        process.terminationHandler = { _ in
            do {
                if let data = try pipe.fileHandleForReading.readToEnd() {
                    let res = String(data: data, encoding: .utf8)
                    completion(res)
                }
            } catch {
                Log.error("runCommand - fail: \(error)")
            }
        }
        do {
            try process.run()
        } catch {
            Log.error("runCommand - fail: \(error)")
            completion(nil)
        }
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
    
    static func doAlert(type: NSAlert.Style, title: String, message: String) {
        let alert = NSAlert()
        alert.alertStyle = type
        alert.messageText = title
        alert.informativeText = message
        if let appIcon = NSImage(named: NSImage.applicationIconName) {
            Log.debug("here")
            alert.icon = appIcon
        }
        alert.runModal()
    }
    
    static func sendDataServiceErrorMessage() {
        if let config = Config.enableDataServiceConfig {
            MessageCenter.send(level: .error, title: "Data Service Error", content: "request the data service(host=\(config.host), port=\(config.port)) fail, please check [data service]-[connection info] in setting and ensure the data service running normally")
        } else {
            MessageCenter.send(level: .error, title: "Data Service Error", content: "no valid data service configuration, please check [data service]-[connection info] in setting")
        }
    }
    
    static func getCurrentDateString(format: String) -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let dateString = dateFormatter.string(from: currentDate)
        return dateString
    }
    
    static func convertIsoDateToE8(_ isoDateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXX"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        guard let date = dateFormatter.date(from: isoDateString) else {
            Log.error("convert iso date to e8 date - failed: parse input date string failed, input=\(isoDateString)")
            return nil
        }
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        return dateFormatter.string(from: date)
    }
    
    static func getAllFiles(in directory: URL) -> [URL] {
        var fileURLs: [URL] = []
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles])
            for fileURL in contents {
                if fileURL.hasDirectoryPath {
                    fileURLs.append(contentsOf: getAllFiles(in: fileURL))
                } else {
                    fileURLs.append(fileURL)
                }
            }
        } catch {
            print("get files in dirctory - fail: got contentsOfDirectory fail, err=\(error)")
        }
        return fileURLs
    }
    
}

extension String {

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
            let identity = String(self.dropFirst(5))
            Task {
                guard let imageData = await Storage.pickFish(identity: identity)?.imageData else {
                    return Image?(nil)
                }
                return Image(nsImage: imageData)
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
    static let ShouldRefreshFish = Notification.Name("ShouldRefreshFish")
    static let FishRefreshed = Notification.Name("FishRefreshed")
    static let RecipeStatusChanged = Notification.Name("RecipeStatusChanged")
    static let CommandTextChanged = Notification.Name("CommandTextChanged")
    static let CommandBarEndEditing = Notification.Name("CommandBarEndEditing")
    static let CommandBarShouldFocus = Notification.Name("CommandBarShouldFocus")
    static let UserDefinedRecipeViewChanged = Notification.Name("UserDefinedRecipeViewChanged")
    static let RecipeCommited = Notification.Name("RecipeCommited")
    static let MessageCenterHasUpdated = Notification.Name("MessageCenterHasUpdated")
}


