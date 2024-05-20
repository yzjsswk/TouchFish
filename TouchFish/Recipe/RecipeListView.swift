import SwiftUI

struct RecipeListView: View {
    
    var body: some View {

        VStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(RecipeManager.orderedRecipeList, id: \.bundleId) { recipe in
                        RecipeItemView(recipe: recipe)
                    }
                }
                .padding(.vertical)
            }
        }
        
    }
    
}
