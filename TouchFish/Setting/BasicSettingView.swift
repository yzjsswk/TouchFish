import SwiftUI

struct BasicSettingView: View {
    
    @Binding var tempSetting: Configuration
    
    var body: some View {
        VStack {
            // language
            HStack {
                    Text("Language")
                        .font(.title3)
                        .bold()
                    Spacer()
                Picker("", selection: $tempSetting.language) {
                        ForEach(Configuration.TFLanguage.allCases) { lan in
                            Text(lan.rawValue)
                                .tag(lan)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 150)
            }
            .padding(.vertical, 2)
            HStack{
                Text("the language of the application")
                    .font(.callout)
                    .foregroundStyle(.gray)
                Spacer()
            }
            .padding(.vertical, 2)
            Divider()
            // call application of keyboard shortCut
            HStack {
                Text("Call Application KeyBoard ShortCut")
                    .font(.title3)
                    .bold()
                Spacer()
                ZStack {
                    Constant.commandBarBackgroundColor.color
                    HStack(spacing: 2) {
                        Image(systemName: "option")
                        Image(systemName: "space")
                    }
                }
                .frame(width: 50)
                .padding(.horizontal, 5)
            }
            .padding(.vertical, 2)
            HStack{
                Text("when pressed, the application activates and shows")
                    .font(.callout)
                    .foregroundStyle(.gray)
                Spacer()
            }
            .padding(.vertical, 2)
            Divider()
            // hideMainWindowWhenClickOutSideEnable
            HStack {
                Text("Hide When Click Outside")
                    .font(.title3)
                    .bold()
                Spacer()
                Toggle(isOn: $tempSetting.hideMainWindowWhenClickOutSideEnable) {}
                    .padding(.horizontal, 5)
            }
            .padding(.vertical, 2)
            HStack{
                Text("if enabled, when click outside the window, the application will hide and deactivate")
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


