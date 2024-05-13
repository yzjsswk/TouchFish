import SwiftUI

struct RecipeListView: View {
    
    var body: some View {
        ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
                        ], spacing: 20)  {
                            ForEach(Array(RecipeManager.Recipes.values).sorted(by: {$0.id < $1.id}), id: \.id) { recipe in
                                RecipeItemView(
                                    name: recipe.name,
                                    desc: recipe.desc,
                                    icon: recipe.icon,
                                    command: recipe.command
                                )
                                .onTapGesture(count: 1, perform: recipe.action)
                            }
                        }
                        .padding()
                    }
                    
        }
    }
    
}
