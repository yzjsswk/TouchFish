import SwiftUI
import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
	func applicationDidFinishLaunching(_ aNotification: Notification) {
        TouchFishApp.start()
        let options: NSDictionary = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options)

        if !accessEnabled {
            print("Access Not Enabled")
        } else {
            print("Access Enabled")
        }
	}

    
}
