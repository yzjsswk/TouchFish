import SwiftUI

struct CommandField: NSViewControllerRepresentable {
    
    @Binding var commandText: String
    
    func makeNSViewController(context: Context) -> some CommandFieldViewController {
        return CommandFieldViewController(text: $commandText)
    }
    
    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
        guard let textField = nsViewController.textField else {
            Log.error("update command bar - fail: get textField = nil")
            return
        }
        textField.stringValue = CommandManager.update(commandText)
        CommandManager.commandText = textField.stringValue
        NotificationCenter.default.post(name: .CommandTextChanged, object: nil, userInfo: ["commandText":textField.stringValue])
    }
    
}
