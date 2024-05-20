import SwiftUI
import Foundation

struct MainView: View {
    
    @State var fishs: [String:Fish] = [:]
    
    @State var commandText = ""
    @State var commandCell: [String] = []
    
    @State var activeRecipeBundleId: String?
    
    @State var isEditing: Bool = false // todo: remove
    
    var body: some View {
        ZStack {
            Config.mainBackgroundColor.color
            VStack {
                CommandBarView(commandText: $commandText, commandCell: $commandCell)
                if let activeRecipeBundleId = activeRecipeBundleId {
                    switch activeRecipeBundleId {
                    case "com.touchfish.FishRepository":
                        FishRepositoryView(fishs: $fishs, isEditing: $isEditing)
                    case "com.touchfish.Statistics":
                        StatsView()
                    default:
                        EmptyView()
                    }
                } else {
                    RecipeView()
                }
                Spacer()
            }
        }
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.1), lineWidth: 1))
        .onAppear {
            fishs = Storage.getFishOfSearchCondition()
        }
        .onReceive(NotificationCenter.default.publisher(for: .RecipeStatusChanged)) { _ in
            if let recipe = RecipeManager.activeRecipe {
                activeRecipeBundleId = recipe.bundleId
                commandCell.removeAll()
                commandCell.append(recipe.name)
                for (k, v) in RecipeManager.activeRecipeOrderedArg {
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
        .onReceive(NotificationCenter.default.publisher(for: .ShouldRefreshFishList)) { _ in
            withAnimation {
                fishs = Storage.getFishOfSearchCondition()
            }
        }
    }
    
}
