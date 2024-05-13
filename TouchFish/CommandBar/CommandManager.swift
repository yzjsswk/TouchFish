import Foundation
import SwiftUI

class CommandManager {
    
    static func update(_ commandText: String) -> String {
        if RecipeManager.activeRecipeId == 0 {
            for recipe in RecipeManager.recipes.values {
                if let command = recipe.command, commandText == command + " " {
                    RecipeManager.goToRecipe(recipeId: recipe.id)
                    return ""
                }
            }
        }
        if let activeRecipe = RecipeManager.recipes[RecipeManager.activeRecipeId],
            activeRecipe.args.count < RecipeManager.activeRecipeArguments.count {
            RecipeManager.activeRecipeArguments[activeRecipe.args[RecipeManager.activeRecipeArguments.count-1]] = commandText
            NotificationCenter.default.post(name: .RecipeStatusChanged, object: nil)
            return ""
        }
        return commandText
    }
    
    static func removeCell() {
        let recipeId = RecipeManager.activeRecipeId
        let activeArgCount = RecipeManager.activeRecipeArguments.count
        if activeArgCount > 0, let recipe = RecipeManager.recipes[recipeId] {
            RecipeManager.activeRecipeArguments.removeValue(forKey: recipe.args[activeArgCount-1])
            NotificationCenter.default.post(name: .RecipeStatusChanged, object: nil)
        } else {
            RecipeManager.goToRecipe(recipeId: 0)
        }
    }
    
}
