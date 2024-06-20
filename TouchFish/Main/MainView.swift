import SwiftUI

struct MainView: View {
    
    @State var fishs: [String:Fish] = [:]
    @State var recipeList: [Recipe] = []
    
    @State var commandText = ""
    @State var commandCell: [String] = []
    
    @State var activeRecipeBundleId: String?
    
    @State var isEditing: Bool = false // todo: remove
    
    var body: some View {
        ZStack {
            Config.mainBackgroundColor.get().color
            VStack {
                CommandBarView(commandText: $commandText, commandCell: $commandCell)
                if let activeRecipeBundleId = activeRecipeBundleId {
                    switch activeRecipeBundleId {
                    case "com.touchfish.FishRepository":
                        FishRepositoryView(fishs: $fishs, isEditing: $isEditing)
                    case "com.touchfish.AddFish":
                        FishAddView()
                    case "com.touchfish.Statistics":
                        StatsView()
                    case "com.touchfish.Setting":
                        SettingView()
                    case "com.touchfish.MessageCenter":
                        EmptyView()
                    case "com.touchfish.RecipeStore":
                        EmptyView()
                    default:
                        RecipeView(recipeList: $recipeList, activeRecipeBundleId: activeRecipeBundleId)
                    }
                } else {
                    RecipeView(recipeList: $recipeList)
                }
                Spacer()
            }
        }
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.1), lineWidth: 1))
        .onReceive(NotificationCenter.default.publisher(for: .RecipeStatusChanged)) { _ in
            if let recipe = RecipeManager.activeRecipe {
                activeRecipeBundleId = recipe.bundleId
                commandCell.removeAll()
                commandCell.append(recipe.name)
                for (k, v) in RecipeManager.activeRecipeAddOrderArg {
                    commandCell.append("\(k):\(v)")
                }
            } else {
                activeRecipeBundleId = nil
                commandCell.removeAll()
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
//        .onAppear {
//            withAnimation {
//                fishs = Storage.getFishOfSearchCondition()
//                recipeList = RecipeManager.orderedRecipeList
//            }
//        }
        .onReceive(NotificationCenter.default.publisher(for: .CacheRefreshed)) { _ in
            withAnimation {
                fishs = Storage.getFishOfSearchCondition()
                recipeList = RecipeManager.orderedRecipeList
            }
        }
    }
    
}
