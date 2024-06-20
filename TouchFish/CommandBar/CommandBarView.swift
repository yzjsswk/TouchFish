import SwiftUI

struct CommandBarView: View {
    
    @Binding var commandText: String
    @Binding var commandCell: [String]
    
    @FocusState var isFocused: Bool
    
    @State var placeHolderString: String = ""
    @State var lastEditTs: TimeInterval = Date().timeIntervalSince1970
    
    var body: some View {
        ZStack {
            HStack {
                ForEach(Array(commandCell.enumerated()), id: \.0) { _, cellText in
                    Text(cellText.count > 25 ? "\(cellText.prefix(22))..." : cellText)
                        .background(
                            GeometryReader { geometry in
                                Rectangle()
                                    .cornerRadius(5)
                                    .foregroundColor(Config.selectedItemBackgroundColor.get().color)
                                    .frame(width: geometry.size.width+5, height: geometry.size.height+8)
                                    .offset(x: -2.5, y: -4)
                            }
                        )
                        .foregroundColor(.white)
                        .font(.custom("Menlo", size: 16))
                        .padding([.leading], 3)
                }
                ZStack {
                    CommandField(commandText: $commandText)
                        .frame(height: Config.commandFieldHeight.get())
                        .offset(y: 2)
                        .focused($isFocused)
                    if commandText.count == 0 {
                        HStack {
                            Text(placeHolderString)
                                .font(.custom("Menlo", size: 20))
                                .foregroundStyle(.gray)
                            Spacer()
                        }
                    }
                }
            }
            .padding([.leading], 6)
            .frame(height: Config.commandBarHeight.get())
        }
        .background(Config.commandBarBackgroundColor.get().color)
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
        .onReceive(NotificationCenter.default.publisher(for: .RecipeStatusChanged)) { _ in
            if let recipe = RecipeManager.activeRecipe {
                placeHolderString = recipe.parameters
                    .filter { !RecipeManager.activeRecipeArg.keys.contains($0.name) }
//                    .map {$0.separator != nil ? "\($0.name)[\($0.separator!)]:" : "\($0.name):"}
                    .map {"\($0.name):"}
                    .joined()
            } else {
                placeHolderString = ""
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
