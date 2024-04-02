import SwiftUI

// todo: file name and class name -> Configuration; global name -> Config

let Config = Configuration.it

struct Configuration: Codable {
    
    static let it = readFromFile()
    
    static let configPath = TouchFishApp.appSupportPath.appendingPathComponent("config.json")
    
    static func readFromFile() -> Configuration {
        if FileManager.default.fileExists(atPath: Configuration.configPath.path) {
            do {
                let configData = try Data(contentsOf: Configuration.configPath)
                return try JSONDecoder().decode(Configuration.self, from: configData)
            } catch {
                Log.error("Error when read config file, path=\(Configuration.configPath.path), error=\(error)")
                let alert = NSAlert()
                alert.alertStyle = .warning
                alert.messageText = "Configuration Error"
                alert.informativeText = "Something is wrong with your configuration file at: \(Configuration.configPath.path).\n\n Use default configuration."
                alert.runModal()
                return Configuration()
            }
        }
        Log.warning("config file \(Configuration.configPath.path) not found, use default configuration.")
        return Configuration()
    }
    
    func save() {
        do {
            try JSONEncoder().encode(self).write(to: Configuration.configPath)
        } catch {
            fatalError("Failed to write the configuration. Error: \n\(error)")
        }
    }
    
    // configurations
    
    var workPath: URL = TouchFishApp.appSupportPath
    var appActiveKeyShortcut: KeyboardShortcut = KeyboardShortcut(key: Key(keyCode: 49), modifiers: [.option], events: [.keyDown])
    var fishRepositoryActiveKeyShortcut: KeyboardShortcut = KeyboardShortcut(key: Key(keyCode: 9), modifiers: [.command,.option], events: [.keyDown])
    var maximumWidth: CGFloat = 775
    var maximumHeight: CGFloat = 600
    var mainBackgroundColor: String = "#ECEEF1"
    var promptBarBackgroundColor: String = "D8D8DB"
    var selectedItemBackgroundColor: String = "#502A70"
    var CommandBarBackgroundColor: String = "#282A36"
    var CommandBarInsertionPointColor: String = "#F8F8F2"
    var mainWidth: CGFloat = 800
    var mainHeight: CGFloat = 600
    var promptBarHeight: CGFloat = 40
    var webURLItemHeight: CGFloat = 50
    var processItemWidth: CGFloat = 240
    var processItemHeight: CGFloat = 40
    var fishItemHeight: CGFloat = 24
    var fishItemPreviewLength: Int = 40
    var fileSaveLimitInterval: TimeInterval = 60
    var fileSaveLimitCount: Int = 5
    
}
