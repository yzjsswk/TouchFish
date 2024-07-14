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
            HStack{
                Text("when pressed, the application activates and shows, and enters fish repository")
                    .font(.callout)
                    .foregroundStyle(.gray)
                Text("(edit here not supported currently)")
                    .font(.callout)
                    .bold()
                    .foregroundStyle(.gray)
                Spacer()
            }
            .padding(.vertical, 2)
            Divider()
        }
        .padding()
    }
    
}

