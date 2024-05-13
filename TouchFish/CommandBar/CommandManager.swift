import Foundation
import SwiftUI

class CommandManager {
    
    static func update(_ commandText: String) -> String {
        if RecipeManager.activeRecipeId == 0 {
            for recipe in RecipeManager.Recipes.values {
                if let command = recipe.command, commandText == command + " " {
                    RecipeManager.activeRecipeId = recipe.id
                    NotificationCenter.default.post(name: .RecipeStatusChanged, object: nil)
                    return ""
                }
            }
        }
        if let activeRecipe = RecipeManager.Recipes[RecipeManager.activeRecipeId],
            activeRecipe.args.count < RecipeManager.activeRecipeArguments.count {
            RecipeManager.activeRecipeArguments[activeRecipe.args[RecipeManager.activeRecipeArguments.count-1]] = commandText
            return ""
        }
        return commandText
    }
    
    static func removeCell() {
        let recipeId = RecipeManager.activeRecipeId
        let activeArgCount = RecipeManager.activeRecipeArguments.count
        if activeArgCount > 0, let recipe = RecipeManager.Recipes[recipeId] {
            RecipeManager.activeRecipeArguments.removeValue(forKey: recipe.args[activeArgCount-1])
        } else {
            RecipeManager.activeRecipeId = 0
        }
        NotificationCenter.default.post(name: .RecipeStatusChanged, object: nil)
    }
    
}
