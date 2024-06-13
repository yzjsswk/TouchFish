import SwiftUI

var Config = Configuration.it

struct ConfigField<T: Codable>: Codable {
    
    private var defaultValue: T
    private var value: T?
    private var canEdit: Bool // todo: not effect
    
    init(defaultValue: T, value: T? = nil, canEdit: Bool = false) {
        self.defaultValue = defaultValue
        self.value = value
        self.canEdit = canEdit
    }
    
    func get() -> T {
        if !canEdit {
            return defaultValue
        }
        return value ?? defaultValue
    }
    
    mutating func set(value: T) {
        self.value = value
    }
    
    mutating func reSet() {
        self.value = defaultValue
    }
    
}

struct Configuration: Codable {
    
    static var it = read()
    
    static func read() -> Configuration {
        if !FileManager.default.fileExists(atPath: TouchFishApp.configPath.path) {
            Log.warning("read config - use default configuration: config file not exists, path=\(TouchFishApp.configPath.path)")
            return Configuration()
        }
        do {
            let configData = try Data(contentsOf: TouchFishApp.configPath)
            return try JSONDecoder().decode(Configuration.self, from: configData)
        } catch {
            Log.warning("read config - use default configuration: read config file failed, path=\(TouchFishApp.configPath.path), err=\(error)")
            return Configuration()
        }
    }
    
    func save() -> Bool {
        do {
            try JSONEncoder().encode(self).write(to: TouchFishApp.configPath)
            return true
        } catch {
            Log.warning("save config - failed, err=\(error)")
            return false
        }
    }
    
    // configurations
    
    // data service
    struct DataServiceConfiguration: Codable {
        var host: String
        var port: String
    }
    var dataServiceConfigs = ConfigField<[String:DataServiceConfiguration]>(
        defaultValue: ["local": DataServiceConfiguration(host: "127.0.0.1", port: "2233")], canEdit: true
    )
    var enableDataServiceConfigName = ConfigField<String>(defaultValue: "local", canEdit: true)
    var enableDataServiceConfig: DataServiceConfiguration? {
        return dataServiceConfigs.get()[enableDataServiceConfigName.get()]
    }
    var maxResourceSizeAutoFetch = ConfigField<Int>(defaultValue: 1024 * 1024 * 50, canEdit: true)  // 50MB
    var maxDataSizeAddFish = ConfigField<Int>(defaultValue: 1024 * 1024 * 1024) // 1GB
    
    // basic
    enum TFLanguage: String, Codable, CaseIterable {
        case Chinese
    }
    var language = ConfigField<TFLanguage>(defaultValue: .Chinese, canEdit: true)
    var appActiveKeyShortcut = ConfigField<KeyboardShortcut>(
        defaultValue: KeyboardShortcut(keyCode: 49, modifiers: [.option], events: [.keyDown]), canEdit: true
    )
    var fishRepositoryActiveKeyShortcut = ConfigField<KeyboardShortcut>(
        defaultValue: KeyboardShortcut(keyCode: 9, modifiers: [.command, .option], events: [.keyDown]), canEdit: true
    ) // todo: remove to recipe setting
    
    var textFishDetailPreviewLength = ConfigField<Int>(defaultValue: 1500) // service limit: 2000; todo: remove to recipe setting

    // ui
    var mainWidth = ConfigField<CGFloat>(defaultValue: 800)
    var mainHeight = ConfigField<CGFloat>(defaultValue: 600)
    var commandBarHeight = ConfigField<CGFloat>(defaultValue: 40)
    var commandFieldHeight = ConfigField<CGFloat>(defaultValue: 28)
    var userDefinedRecipeItemHeight = ConfigField<CGFloat>(defaultValue: 50)
    var recipeItemHeight = ConfigField<CGFloat>(defaultValue: 40)
    var recipeItemSelectedHeight = ConfigField<CGFloat>(defaultValue: 55)
    var fishItemHeight = ConfigField<CGFloat>(defaultValue: 24)
    var fishItemIconWidth = ConfigField<CGFloat>(defaultValue: 20)
    var fishItemPreviewLength = ConfigField<CGFloat>(defaultValue: 40)
    var fishDetailItemHeight = ConfigField<CGFloat>(defaultValue: 10)
    var mainBackgroundColor = ConfigField<String>(defaultValue: "ECEEF1")
    var commandBarBackgroundColor = ConfigField<String>(defaultValue: "D8D8DB")
    var selectedItemBackgroundColor = ConfigField<String>(defaultValue: "502A70")
    var commandFieldBackgroundColor = ConfigField<String>(defaultValue: "282A36")
    var commandFieldInsertionPointColor = ConfigField<String>(defaultValue: "F8F8F2")
    var internalRecipeItemColor = ConfigField<String>(defaultValue: "D8D8DB")
    var userDefinedRecipeDefaultIemColor = ConfigField<String>(defaultValue: "D8D8DB")
    
}
