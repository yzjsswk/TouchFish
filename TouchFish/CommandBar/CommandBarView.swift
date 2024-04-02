import SwiftUI

struct CommandBarView: View {
    
    @Binding var text: String
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                CommandField(text: $text)
                    .padding([.leading, .trailing], 8)
                Spacer()
            }
            .frame(height: Config.promptBarHeight)
        }
        .background(Config.promptBarBackgroundColor.color) // todo: change name
        .cornerRadius(10)
        .padding(10)
    }
}
