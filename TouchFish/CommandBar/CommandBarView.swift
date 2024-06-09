import SwiftUI

struct CommandBarView: View {
    
    @Binding var commandText: String
    @Binding var commandCell: [String]
    
    @FocusState var isFocused: Bool
    
    @State var lastEditTs: TimeInterval = Date().timeIntervalSince1970
    
    var body: some View {
        ZStack {
            HStack {
                ForEach(Array(commandCell.enumerated()), id: \.0) { _, cellText in
                    Text(cellText)
                        .background(
                            GeometryReader { geometry in
                                Rectangle()
                                    .cornerRadius(5)
                                    .foregroundColor(Config.selectedItemBackgroundColor.color)
                                    .frame(width: geometry.size.width+5, height: geometry.size.height+8)
                                    .offset(x: -2.5, y: -4)
                            }
                        )
                        .foregroundColor(.white)
                        .font(.custom("Menlo", size: 16))
                        .padding([.leading], 3)
                }
                CommandField(commandText: $commandText)
                    .frame(height: Config.commandFieldHeight)
                    .offset(y: 2)
                    .focused($isFocused)
            }
            .padding([.leading], 6)
            .frame(height: Config.commandBarHeight)
        }
        .background(Config.commandBarBackgroundColor.color)
        .cornerRadius(10)
        .padding(10)
        .onReceive(NotificationCenter.default.publisher(for: .DeleteKeyWasPressed)) { _ in
            if isFocused && commandText.count == 0 {
                CommandManager.removeCell()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .ReturnKeyWasPressed)) { _ in
            if isFocused {
                NotificationCenter.default.post(name: .RecipeCommited, object: nil)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .CommandTextChanged)) { notification in
            if let commandText = notification.userInfo?["commandText"] as? String {
                let curEditTs = Date().timeIntervalSince1970
                lastEditTs = curEditTs
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    if lastEditTs == curEditTs {
                        NotificationCenter.default.post(name: .CommandBarEndEditing, object: nil, userInfo: ["commandText":commandText])
                    }
                }
            }
        }
    }
}
