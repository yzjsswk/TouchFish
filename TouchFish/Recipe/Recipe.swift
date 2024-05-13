import SwiftUI

struct Recipe {
    var id: Int
    var name: String
    var commandCellName: String
    var desc: String?
    var icon: Image = Image(systemName: "frying.pan")
    var args: [String] = []
    var command: String?
    var action: () -> Void = {}
}

struct RecipeManager {
    
    static var activeRecipeId = 0
    static var activeRecipeArguments: [String:String] = [:]
    
    static var recipes: [Int:Recipe] = [
        1: Recipe(
            id: 1,
            name: "Fish Repository",
            commandCellName: "Fish Repository",
            desc: "master your information",
            icon: Image(systemName: "fish"),
            command: "fish"
        ),
        2: Recipe(
            id: 2,
            name: "Setting",
            commandCellName: "Setting",
            icon: Image(systemName: "gearshape"),
            command: "set"
        ),
        3: Recipe(
            id: 3,
            name: "Recipe Store",
            commandCellName: "Recipe Store",
            icon: Image(systemName: "books.vertical"),
            command: "store"
        ),
        4: Recipe(
            id: 4,
            name: "Statistics",
            commandCellName: "Statistics",
            icon: Image(systemName: "chart.line.uptrend.xyaxis.circle.fill"),
            command: "stats"
        ),
        5: Recipe(
            id: 5,
            name: "Web BookMark",
            commandCellName: "Web BookMark",
            icon: Image(systemName: "globe"),
            command: "bm"
        )
    ]
    
    static func goToRecipe(recipeId: Int) {
        activeRecipeId = recipeId
        activeRecipeArguments.removeAll()
        NotificationCenter.default.post(name: .RecipeStatusChanged, object: nil)
    }
    
}

