import SwiftUI

let Config = Configuration.it

struct Configuration: Codable {
    
    static let it = readFromFile()
    
    static func readFromFile() -> Configuration {
        if !FileManager.default.fileExists(atPath: TouchFishApp.configPath.path) {
            Log.warning("read config - use default configuration: config file not exists, path=\(TouchFishApp.configPath.path)")
            return Configuration()
        }
        do {
            let configData = try Data(contentsOf: TouchFishApp.configPath)
            return try JSONDecoder().decode(Configuration.self, from: configData)
        } catch {
            Log.warning("read config - use default configuration: read config file failed, path=\(TouchFishApp.configPath.path), err=\(error)")
//            let alert = NSAlert()
//            alert.alertStyle = .warning
//            alert.messageText = "Configuration Error"
//            alert.informativeText = "Something is wrong with your configuration file at: \(Configuration.configPath.path).\n\n Use default configuration."
//            alert.runModal()
            return Configuration()
        }
    }
    
    func save() {
        do {
            try JSONEncoder().encode(self).write(to: TouchFishApp.configPath)
        } catch {
            fatalError("Failed to write the configuration. Error: \n\(error)")
        }
    }
    
    // configurations
    
    var dataServiceHost = "127.0.0.1"
    var dataServicePort = "2233"
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
    var cacheRefreshLimitInterval: TimeInterval = 1
    var fileSaveLimitInterval: TimeInterval = 60
    var fileSaveLimitCount: Int = 5
    
    var maxResourceSizeAutoFetch: Int = 1024 * 1024 * 50
    
}
