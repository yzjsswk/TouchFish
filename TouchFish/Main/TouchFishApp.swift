import SwiftUI

class TouchFishApp {
    
    /**
        Application Support Path:
         - /log: log
         - /preview: preview of fish
         - /resource: downloaded fishdata
         - config.json: user configuration
     */
    static let appSupportPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0].appendingPathComponent("TouchFish")
    static let logPath = TouchFishApp.appSupportPath.appendingPathComponent("log")
    static let resourcePath = TouchFishApp.appSupportPath.appendingPathComponent("resource")
    static let previewPath = TouchFishApp.appSupportPath.appendingPathComponent("preview")
    static let configPath = TouchFishApp.appSupportPath.appendingPathComponent("config.json")
    
    static var statusBar: StatusBar!
    static var mainWindow: MainWindow!
    
    static func start() {
        TouchFishApp.createAppSupportPathIfNotExists()
        TFLogger.prepare()
        Cache.start()
        Monitor.start(type: .showOrHideMainWindowWhenKeyShortCutPressed)
        Monitor.start(type: .openFishRepositoryWhenKeyShortCutPressed)
        Monitor.start(type: .hideMainWindowWhenClickOutside)
        Monitor.start(type: .saveFishWhenClipboardChanges)
        Monitor.start(type: .localKeyBoardPressedAsyncEvent)
        TFTask.start()
        TouchFishApp.statusBar = StatusBar()
        TouchFishApp.mainWindow = MainWindow()
        TouchFishApp.activate()
        Log.info("application start - success, support path=\(TouchFishApp.appSupportPath.path)")
    }
    
    static private func createAppSupportPathIfNotExists() {
        for path in [
            TouchFishApp.appSupportPath,
            TouchFishApp.logPath,
            TouchFishApp.resourcePath,
            TouchFishApp.previewPath
        ] {
            if !FileManager.default.fileExists(atPath: path.path) {
                do {
                    try FileManager.default.createDirectory(at: path, withIntermediateDirectories: false, attributes: nil)
                } catch {
                    Functions.doAlert(type: .critical, title: "Error", message: "create application support path failed, path=\(path.path)")
                    TouchFishApp.quit()
                }
            }
        }
    }
    
    static func activate() {
        TFLogger.updateLogFile()
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
