import AppKit
import CryptoKit
import SwiftUI

struct Functions {
    
    static func getDataFromClipboard() -> (FishType, Data, Any)? {
        if let types = NSPasteboard.general.types, types.count > 0 {
            if let str = NSPasteboard.general.string(forType: .string),
               let data = str.data(using: .utf8) {
                return (.text, data, str)
            }
            if let data = NSPasteboard.general.data(forType: types[0]) {
                if let img = NSImage(data: data) {
                    return (.image, data, img)
                }
            }
            Log.warning("data type not supported from clipboard")
            Log.verbose(types)
        }
        return nil
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
    
    static func compressImageByPNG(_ image: NSImage, _ compressionFactor: CGFloat) -> NSImage? {
        guard let imageData = image.tiffRepresentation else {
            return nil
        }
        guard let imageRep = NSBitmapImageRep(data: imageData) else {
            return nil
        }
        let properties: [NSBitmapImageRep.PropertyKey: Any] = [
            .compressionFactor: compressionFactor
        ]
        guard let compressedData = imageRep.representation(using: .tiff, properties: properties) else {
            return nil
        }
        return NSImage(data: compressedData)
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
    
    /// Converts a hex string to a SwiftUI color.
    var color: Color {
        // Remove the optional beginning (#, 0x) of a hex string.
        let hexString = self.replacingOccurrences(of: "#", with: "").replacingOccurrences(of: "0x", with: "")
        
        let scanner = Scanner(string: hexString)
        var resultInt: UInt64 = 0
        scanner.scanHexInt64(&resultInt)
        let red = CGFloat((resultInt & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((resultInt & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((resultInt & 0xFF)) / 255.0
        
        let nsColor = NSColor(red: red, green: green, blue: blue, alpha: 1.0)
        
        return Color(nsColor)
    }
    
}

extension Notification.Name {
    static let ReturnKeyWasPressed = Notification.Name("ReturnKeyWasPressed")
    static let UpArrowKeyWasPressed = Notification.Name("UpArrowKeyWasPressed")
    static let DownArrowKeyWasPressed = Notification.Name("DownArrowKeyWasPressed")
    static let TabKeyWasPressed = Notification.Name("TabKeyWasPressed")
    static let EscapeKeyWasPressed = Notification.Name("EscapeKeyWasPressed")
    static let CommandKeyWasPressed = Notification.Name("CommandKeyWasPressed")
    static let ApplicationShouldExit = Notification.Name("ApplicationShouldExit")
    static let ShouldPresentQuickLook = Notification.Name("ShouldPresentQuickLook")
    static let ShouldDeleteClipboardHistoryItem = Notification.Name("ShouldDeleteClipboardHistoryItem")
    static let ShouldDeleteClipboardHistory = Notification.Name("ShouldDeleteClipboardHistory")
    static let ShouldShowFishView = Notification.Name("ShouldShowFishView")
    static let ShouldRefreshFishList = Notification.Name("ShouldRefreshFishList")
}

