import SwiftUI
import Carbon.HIToolbox.Events

class TouchFishApp {
    /**
        todo: 1. delete old file on github: Config.swift, AppleScriptRunner.swift?
            2. fix: paste not work
     */

    /**
        appSupportPath: /Users/yzjsswk/Library/Application Support/TouchFish/
         - log/: record log
         - preview/: preview of fishdata
         - resource/: downloaded fishdata
         - config.json: user configuration
     */
    static let appSupportPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("TouchFish")
    static let logPath = TouchFishApp.appSupportPath.appendingPathComponent("log")
    static let resourcePath = TouchFishApp.appSupportPath.appendingPathComponent("resource")
    static let previewPath = TouchFishApp.appSupportPath.appendingPathComponent("preview")
    static let configPath = TouchFishApp.appSupportPath.appendingPathComponent("config.json")
    
    static var statusBar: StatusBar! // todo: icon, preference action, menu keyshortcut
    static var mainWindow: MainWindow!
    
    static func start() {
        for path in [
            TouchFishApp.appSupportPath,
            TouchFishApp.logPath,
            TouchFishApp.resourcePath,
            TouchFishApp.previewPath
        ] {
            if !FileManager.default.fileExists(atPath: path.path) {
                try! FileManager.default.createDirectory(at: path, withIntermediateDirectories: false, attributes: nil)
            }
        }
        LogManager.prepare()
        Cache.start()
        RecipeManager.start()
        TouchFishApp.statusBar = StatusBar() // need init here because static member will not be compute before it been used
        TouchFishApp.mainWindow = MainWindow()
        Monitor.start(type: .showOrHideMainWindowWhenKeyShortCutPressed)
        Monitor.start(type: .openFishRepositoryWhenKeyShortCutPressed)
        Monitor.start(type: .hideMainWindowWhenClickOutside)
        Monitor.start(type: .saveFishWhenClipboardChanges)
        Monitor.start(type: .localKeyBoardPressedAsyncEvent)
        TouchFishApp.activate()
    }
    
    static func activate() {
        LogManager.updateLogFile()
        TouchFishApp.mainWindow.show()
    }
    
    static func deactivate() {
        TouchFishApp.mainWindow.hide()
        NSApp.hide(nil)
    }
    
    static func quit() {
        NSApp.terminate(nil)
    }

}
