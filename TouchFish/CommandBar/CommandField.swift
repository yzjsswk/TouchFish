import SwiftUI

struct CommandField: NSViewControllerRepresentable {
    
    @Binding var text: String
    
    func makeNSViewController(context: Context) -> some CommandFieldViewController {
        return CommandFieldViewController(text: $text)
    }
    
    func updateNSViewController(_ nsViewController: NSViewControllerType, context: Context) {
        let textField = nsViewController.textField
        textField?.stringValue = text
    }
    
}
