import SwiftUI

struct RecipeView: View {
    
    @Binding var recipeList: [Recipe]
    
    var body: some View {
        RecipeListView(recipeList: $recipeList)
    }
    
}
