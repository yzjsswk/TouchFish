import SwiftUI

struct RecipeItemView: View {
    
    var recipe: Recipe
    
    @State var isSelected: Bool = false
    
    var body: some View {
        HStack(spacing: 10) {
            HStack {
                recipe.icon
                .resizable()
                .scaledToFit()
                .foregroundColor(isSelected ? Color.white: Color.black)
            }
            .frame(width: Config.recipeItemHeight.get())
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(recipe.name)
                        .font(.title3)
                        .foregroundColor(isSelected ? Color.white: Color.black)
                    if let command = recipe.command {
                        Text(command)
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundColor(isSelected ? Color.white: Color.black)
                    }
                }
                if let desc = recipe.description, isSelected {
                    Text(desc)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
        .padding(5)
        .frame(width: Config.mainWidth.get()-30, height: isSelected ? Config.recipeItemSelectedHeight.get() : Config.recipeItemHeight.get())
        .background(isSelected ? Config.selectedItemBackgroundColor.get().color : recipe.color)
        .saturation(1.0)
        .cornerRadius(5)
        .onHover { isHovered in
            withAnimation(.spring(duration: 0.1)) {
                isSelected = isHovered
            }
        }
        .onTapGesture(count: 1) {
            RecipeManager.goToRecipe(recipeId: recipe.bundleId)
        }
    }
    
}
