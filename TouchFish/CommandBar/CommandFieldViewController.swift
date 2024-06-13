import SwiftUI

class CommandFieldViewController: NSViewController, NSTextFieldDelegate {
    
    @Binding var text: String
    
    init(text: Binding<String>) {
        _text = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    var textField: NSTextField!
    
    lazy var textColor: NSColor = {
        let color = Color.black
        return NSColor(color)
    }()
    
    override func loadView() {
        textField = NSTextField()
        textField.cell = NSTextFieldCell()
        textField.isEditable = true
        textField.usesSingleLineMode = true
        textField.cell?.isScrollable = true
        textField.delegate = self
        textField.stringValue = text
        textField.backgroundColor = Config.commandFieldBackgroundColor.get().nsColor
        textField.textColor = textColor
        textField.font = NSFont(name: "Menlo", size: 22)
        textField.isBordered = false
        textField.focusRingType = .none
        view = textField
    }
    
    lazy var fieldEditor: NSTextView = {
        return textField.window?.fieldEditor(true, for: textField) as! NSTextView
    }()
    
    override func viewDidAppear() {
        view.window?.makeFirstResponder(view)
        fieldEditor.insertionPointColor = Config.commandFieldInsertionPointColor.get().nsColor
        textField.selectText(nil) // todo: do not select
    }
    
    func controlTextDidChange(_ obj: Notification) {
        text = textField.stringValue
    }
    
}

