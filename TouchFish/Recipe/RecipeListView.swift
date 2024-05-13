import SwiftUI

struct RecipeListView: View {
    
    var body: some View {

        VStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(Array(RecipeManager.recipes.values).sorted(by: {$0.id < $1.id}), id: \.id) { recipe in
                        RecipeItemView(recipe: recipe)
                    }
                }
                .padding(.vertical)
            }
        }
        
    }
    
}
