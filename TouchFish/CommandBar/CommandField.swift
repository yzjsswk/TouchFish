import SwiftUI

struct CommandField: NSViewControllerRepresentable {
    
    @Binding var commandText: String
    
    func makeNSViewController(context: Context) -> some CommandFieldViewController {
//        Log.debug("makeNSViewController")
        return CommandFieldViewController(text: $commandText)
    }
    
    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
//        Log.debug("updateNSViewController")
        guard let textField = nsViewController.textField else {
            Log.error("update command bar - fail: get textField = nil")
            return
        }
        textField.stringValue = CommandManager.update(commandText)
//        nsViewController.simulateMouseClickOnTextField()
    }
    
}
