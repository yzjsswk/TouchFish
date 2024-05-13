import SwiftUI

struct Recipe {
    var id: Int
    var name: String
    var desc: String?
    var icon: Image?
    var args: [String] = []
    var command: String?
    var action: () -> Void = {}
}

struct RecipeManager {
    static var activeRecipeId = 0
    static var activeRecipeArguments: [String:String] = [:]
    static var Recipes: [Int:Recipe] = [
        1: Recipe(
            id: 1,
            name: "Fish Repository",
            desc: "master your information",
            icon: Image(systemName: "fish"),
            command: "fish"
        ) {
            NotificationCenter.default.post(name: .ShouldShowFishView, object: nil)
        },
        2: Recipe(
            id: 2,
            name: "Web BookMark",
            icon: Image(systemName: "globe"),
            command: "bm"
        )
    ]
}

