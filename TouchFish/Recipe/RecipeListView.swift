import SwiftUI

struct RecipeListView: View {
    
    @Binding var recipeList: [Recipe]
    
    var body: some View {

        VStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(recipeList, id: \.bundleId) { recipe in
                        RecipeItemView(recipe: recipe)
                    }
                }
                .padding(.vertical)
            }
        }
        
    }
    
}
