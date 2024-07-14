import SwiftUI

struct FishRepositorySettingView: View {
    
    @Binding var tempSetting: Configuration
    
    var body: some View {
        VStack {
            // call fish Repository keyboard shortcut
            HStack {
                Text("Call Fish Repository KeyBoard ShortCut")
                    .font(.title3)
                    .bold()
                Spacer()
                ZStack {
                    Constant.commandBarBackgroundColor.color
                    HStack(spacing: 2) {
                        Image(systemName: "command")
                        Image(systemName: "option")
                        Image(systemName: "v.square")
                    }
                }
                .frame(width: 60)
                .padding(.horizontal, 5)
            }
            .padding(.vertical, 2)
            HStack{
                Text("when pressed, the application activates and shows, and enters fish repository")
                    .font(.callout)
                    .foregroundStyle(.gray)
                Spacer()
            }
            .padding(.vertical, 2)
            Divider()
            // auto imported from clipboard
            HStack {
                Text("Auto Imported From Clipboard")
                    .font(.title3)
                    .bold()
                Spacer()
                Toggle(isOn: $tempSetting.autoImportedFromClipboard) {}
                    .padding(.horizontal, 5)
            }
            .padding(.vertical, 2)
            HStack{
                Text("if enabled, when something (support text/image currently) copyed to clipboard, it will also be imported to fish repository")
                    .font(.callout)
                    .foregroundStyle(.gray)
                Spacer()
            }
            .padding(.vertical, 2)
            Divider()
            // fast paste to frontmost application
            HStack {
                Text("Fast Paste To Frontmost Application")
                    .font(.title3)
                    .bold()
                Spacer()
                Toggle(isOn: $tempSetting.fastPasteToFrontmostApplication) {}
                    .padding(.horizontal, 5)
            }
            .padding(.vertical, 2)
            HStack{
                Text("if enabled, when click a fish (support text/image currently) in fish repository, the application will hide and the fish will be tried to paste to the frontmost application")
                    .font(.callout)
                    .foregroundStyle(.gray)
                Spacer()
            }
            .padding(.vertical, 2)
            Divider()
            // textFishDetailPreviewLength
            HStack {
                Text("Max Preview Length of Text Fish")
                    .font(.title3)
                    .bold()
                Spacer()
                NumberInputView(value: $tempSetting.textFishDetailPreviewLength, maxLength: 4)
                    .frame(width: 80)
            }
            .padding(.vertical, 2)
            HStack{
                Text("the maximum number of characters displayed by text fish at the detail area (maximum: 2000)")
                    .font(.callout)
                    .foregroundStyle(.gray)
                Spacer()
            }
            .padding(.vertical, 2)
            Divider()
        }
        .padding()
    }
    
}

struct NumberInputView: View {
    
    @Binding var value: Int
    @State var valueText: String
    
    var maxLength: Int
    
    init(value: Binding<Int>, maxLength: Int) {
        self._value = value
        self._valueText = State(initialValue: String(value.wrappedValue))
        self.maxLength = maxLength
    }
    
    var body: some View {
        TextField("", text: $valueText)
            .cornerRadius(5)
            .onChange(of: valueText) { oldValue, newValue in
                if newValue.isEmpty {
                    value = 0
                    return
                }
                if newValue.count > maxLength {
                    valueText = oldValue
                    return
                }
                if let value = Int(newValue) {
                    self.value = value
                } else {
                    valueText = oldValue
                }
            }
            .onChange(of: value) {
                if valueText != String(value) {
                    valueText = String(value)
                }
            }
    }
    
    
}

