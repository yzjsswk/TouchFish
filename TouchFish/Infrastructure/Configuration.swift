import SwiftUI

var Config = Configuration.it

struct Configuration: Codable {
    
    static var it = read()
    
    static func read() -> Configuration {
        if !FileManager.default.fileExists(atPath: TouchFishApp.configPath.path) {
            let defaultConfig = Configuration()
            _ = defaultConfig.save()
            return defaultConfig
        }
        do {
            let configData = try Data(contentsOf: TouchFishApp.configPath)
            return try JSONDecoder().decode(Configuration.self, from: configData)
        } catch {
            Log.error("read config - use default configuration: read config file failed, path=\(TouchFishApp.configPath.path), err=\(error)")
            return Configuration()
        }
    }
    
    func save() -> Bool {
        do {
            try JSONEncoder().encode(self).write(to: TouchFishApp.configPath)
            return true
        } catch {
            Log.error("save config - failed, err=\(error)")
            return false
        }
    }
    
    // configurations
    
    // basic
    enum TFLanguage: String, Codable, CaseIterable, Identifiable {
        
        case English
        
        var id: String { self.rawValue }
        
    }
    var language: TFLanguage = .English
    var appActiveKeyShortcut = KeyboardShortcut(keyCode: 49, modifiers: [.option], events: [.keyDown])
    var hideMainWindowWhenClickOutSideEnable = true
    
    // data service
    struct DataServiceConfiguration: Codable {
        var host: String
        var port: String
    }
    var dataServiceConfigs: [String:DataServiceConfiguration] = ["local": DataServiceConfiguration(host: "127.0.0.1", port: "2233")]
    var enableDataServiceConfigName = "local"
    var enableDataServiceConfig: DataServiceConfiguration? {
        return dataServiceConfigs[enableDataServiceConfigName]
    }
    
    // fish repository
    var fishRepositoryActiveKeyShortcut = KeyboardShortcut(keyCode: 9, modifiers: [.command, .option], events: [.keyDown])
    var textFishDetailPreviewLength = 1500 // service limit: 2000
    var maxResourceSizeAutoFetch = 1024 * 1024 * 50  // 50MB
    var autoImportedFromClipboard = true
    var fastPasteToFrontmostApplication = false
    var autoRemoveFishEnable = true
    var autoRemoveFishPastHours = 3 * 24

}
