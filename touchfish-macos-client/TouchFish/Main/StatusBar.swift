import SwiftUI

class StatusBar {
    
    private var statusBar: NSStatusItem!
    private var actionMenu: NSMenu!
    
    init() {
        self.statusBar = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = statusBar.button else {
            Log.warning("initialize status bar - failed: got statusBar.button=nil")
            return
        }
        button.image = NSImage(systemSymbolName: "fish.fill", accessibilityDescription: nil)
        
        self.actionMenu = NSMenu()
        let openActionItem = NSMenuItem(
            title: "Open",
            action: #selector(self.openAction),
            keyEquivalent: " "
        )
        openActionItem.keyEquivalentModifierMask = .option
        let quitActionItem = NSMenuItem(
            title: "Quit",
            action: #selector(self.quitAction),
            keyEquivalent: ""
        )
        for menuItem in [openActionItem, quitActionItem] {
            menuItem.target = self
            actionMenu.addItem(menuItem)
        }
        statusBar.menu = actionMenu
    }
    
    @objc func openAction() {
        TouchFishApp.activate()
    }
    
    @objc func quitAction() {
        TouchFishApp.quit()
    }
    
}
