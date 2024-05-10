import AppKit
import SwiftUI
import Carbon.HIToolbox.Events

let Monitor = MonitorManager.self

enum MonitorType {
    case hideMainWindowWhenClickOutside
    case showOrHideMainWindowWhenKeyShortCutPressed
    case openFishRepositoryWhenKeyShortCutPressed
    case localKeyBoardPressedAsyncEvent
    case saveFishWhenClipboardChanges
}

enum ClipboardListenerState {
    case unStarted // app just run and listener function has not start running
    case stop // function has been running, but stop working
    case ready // function has been running, but waiting for clipboard data change once (should ignore the first data)
    case running // normal running, works whenever clipbaord data changes
}

struct MonitorManager {
    
    private static func addGlobalKeyboardEventListener(keyboardShortcut: KeyboardShortcut, actionOnEvent: @escaping (KeyEvent) -> Void) {
        KeyboardShortcutManager(keyboardShortcut: keyboardShortcut).startListeningForEvents(actionOnEvent: actionOnEvent)
    }
    
    static var localKeyBoardPressedAsyncEventMonitor: Any?
    static var clipboardListenerState: ClipboardListenerState = .unStarted
    static var lastClipboardData = UUID().uuidString.data(using: .utf8)
    
    static func start(type: MonitorType) {
        switch type {
        case .hideMainWindowWhenClickOutside:
            NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) {
                [] event in
                if TouchFishApp.mainWindow.isVisible {
                    TouchFishApp.deactivate()
                }
            }
        case .showOrHideMainWindowWhenKeyShortCutPressed:
            MonitorManager.addGlobalKeyboardEventListener(
                keyboardShortcut: Config.appActiveKeyShortcut,
                actionOnEvent: { [] _ in
                    if TouchFishApp.mainWindow.isVisible {
                        TouchFishApp.deactivate()
                    } else {
                        TouchFishApp.activate()
                    }
                }
            )
        case .openFishRepositoryWhenKeyShortCutPressed:
            MonitorManager.addGlobalKeyboardEventListener(
                keyboardShortcut: Config.fishRepositoryActiveKeyShortcut,
                actionOnEvent: { [] _ in
                    if !TouchFishApp.mainWindow.isVisible {
                        NotificationCenter.default.post(name: .ShouldShowFishView, object: nil)
                        TouchFishApp.activate()
                    }
                }
            )
        case .localKeyBoardPressedAsyncEvent:
            MonitorManager.localKeyBoardPressedAsyncEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [] event in
                if event.keyCode == kVK_UpArrow {
                    NotificationCenter.default.post(name: .UpArrowKeyWasPressed, object: nil)
                    return event
                }
                if event.keyCode == kVK_DownArrow {
                    NotificationCenter.default.post(name: .DownArrowKeyWasPressed, object: nil)
                    return event
                }
                if event.keyCode == kVK_Tab {
                    NotificationCenter.default.post(name: .TabKeyWasPressed, object: nil)
                    return event
                }
                if event.keyCode == kVK_Escape {
                    NotificationCenter.default.post(name: .EscapeKeyWasPressed, object: nil)
                    return nil
                }
                let characters = event.charactersIgnoringModifiers ?? ""
                if characters == "\r" {
                    NotificationCenter.default.post(name: .ReturnKeyWasPressed, object: nil)
                    return event
                }
                return event
            }
            case .saveFishWhenClipboardChanges:
                if MonitorManager.clipboardListenerState == .unStarted {
                    listenToClipboardChanges()
                }
                MonitorManager.clipboardListenerState = .ready
                // loop running:
                func listenToClipboardChanges() {
                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                        if let clipboardData = Functions.getDataFromClipboard(),
                                clipboardData.1 != MonitorManager.lastClipboardData {
                            Log.debug("clipboard changed")
                            MonitorManager.lastClipboardData = clipboardData.1
                            if MonitorManager.clipboardListenerState == .ready {
                                MonitorManager.clipboardListenerState = .running
                                listenToClipboardChanges()
                                return
                            }
                            if MonitorManager.clipboardListenerState != .running {
                                listenToClipboardChanges()
                                return
                            }
                            var extraInfo = ExtraInfo()
                            if let sourceAppIcon = NSWorkspace.shared.frontmostApplication?.icon,
                               let sourceAppIconData = sourceAppIcon.tiffRepresentation {
                                extraInfo.sourceAppIconIdentity = Functions.getMD5(of: sourceAppIconData)
                                Task {
                                    // todo: icon does not need pin
                                    let ok = await Storage.addOrPinFish(value: sourceAppIconData, type: .tiff)
                                    if !ok {
                                        Log.warning("save fish from clipboard - sourceAppIcon save failed: Storage.addOrPinFish return false")
                                    }
                                }
                            }
                            Task {
                                let ok = await Storage.addOrPinFish(
                                    value: clipboardData.1, type: clipboardData.0, extraInfo: extraInfo
                                )
                                if !ok {
                                    Log.error("save fish from clipboard - fail: Storage.addOrPinFish return false")
                                }
                            }
                        }
                        listenToClipboardChanges()
                    }
                }
        }
    }
    
    static func stop(type: MonitorType) {
        switch type {
        case .localKeyBoardPressedAsyncEvent:
            guard let monitor = MonitorManager.localKeyBoardPressedAsyncEventMonitor else { return }
            NSEvent.removeMonitor(monitor)
            MonitorManager.localKeyBoardPressedAsyncEventMonitor = nil
        case .saveFishWhenClipboardChanges:
            if MonitorManager.clipboardListenerState != .unStarted {
                MonitorManager.clipboardListenerState = .stop
            }
        default:
            Log.warning("monitor type not support: stop \(type)")
        }
    }
    
}
