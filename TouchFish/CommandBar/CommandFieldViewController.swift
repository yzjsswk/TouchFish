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
//        textField.cell = VerticallyCenteredTextFieldCell()
        textField.cell = NSTextFieldCell()
        textField.isEditable = true
        textField.usesSingleLineMode = true
        textField.cell?.isScrollable = true
        textField.delegate = self
        textField.stringValue = text
        textField.backgroundColor = NSColor(Config.CommandBarBackgroundColor.color)
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
        fieldEditor.insertionPointColor = NSColor(Config.CommandBarInsertionPointColor.color)
        textField.selectText(nil)
    }
    
    func controlTextDidChange(_ obj: Notification) {
        text = textField.stringValue
    }
    
}

// Reference: https://stackoverflow.com/a/45995951/14456607
class VerticallyCenteredTextFieldCell: NSTextFieldCell {
    func adjustedFrame(in rect: NSRect) -> NSRect {
        var titleRect = super.titleRect(forBounds: rect)
        let minimumHeight = self.cellSize(forBounds: rect).height
        titleRect.origin.y += (titleRect.height - minimumHeight) / 2
        titleRect.size.height = minimumHeight
        return titleRect
    }
    override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
        super.edit(withFrame: adjustedFrame(in: rect), in: controlView, editor: textObj, delegate: delegate, event: event)
    }
    override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        super.select(withFrame: adjustedFrame(in: rect), in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
    }
    override func drawInterior(withFrame cellFrame: NSRect, in controlView: NSView) {
        super.drawInterior(withFrame: adjustedFrame(in: cellFrame), in: controlView)
    }
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        super.draw(withFrame: cellFrame, in: controlView)
    }
}

