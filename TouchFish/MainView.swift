import SwiftUI
import Foundation

struct MainView: View {
    
    @State var commandText = ""
    @State var commandCell: [String] = []
    @State var viewState = 0
    @State var fishList: [Fish] = []
    
    var body: some View {
        ZStack {
            Config.mainBackgroundColor.color
            VStack {
                CommandBarView(commandText: $commandText, commandCell: $commandCell)
                switch viewState {
                case 1:
                    FishRepositoryView(fishList: fishList)
                case 2:
                    EmptyView()
                case 3:
                    EmptyView()
                case 4:
                    StatsView()
                case 5:
                    WebBrowserView(text: $commandText)
                default:
                    RecipeView()
                }
                Spacer()
            }
        }
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.1), lineWidth: 1))
        .onAppear {
            fishList = Storage.getFishOfSearchCondition()
        }
        .onReceive(NotificationCenter.default.publisher(for: .RecipeStatusChanged)) { _ in
            let recipeId = RecipeManager.activeRecipeId
            if let recipe = RecipeManager.recipes[recipeId] {
                viewState = recipeId
                commandCell.removeAll()
                commandCell.append(recipe.name)
                for (k, v) in RecipeManager.activeRecipeArguments {
                    commandCell.append("\(k):\(v)")
                }
            } else {
                viewState = 0
                commandCell.removeAll()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .DeleteKeyWasPressed)) { _ in
            if commandText.count == 0 {
                CommandManager.removeCell()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .CommandTextChanged)) { notification in
            if let commandText = notification.userInfo?["commandText"] as? String {
                self.commandText = commandText
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .EscapeKeyWasPressed)) { _ in
            TouchFishApp.deactivate()
        }
        .onReceive(NotificationCenter.default.publisher(for: .ShouldRefreshFishList)) { _ in
            withAnimation {
                fishList = Storage.getFishOfSearchCondition()
            }
        }
    }
    
}
