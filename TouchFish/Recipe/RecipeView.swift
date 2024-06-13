import SwiftUI

struct RecipeView: View {
    
    @Binding var recipeList: [Recipe]
    
    var activeRecipeBundleId: String?
    
    @State var userDefinedRecipeView: UserDefinedRecipeView?
    
    var body: some View {
        VStack {
            if let activeRecipeBundleId = activeRecipeBundleId,
               let activeRecipe = RecipeManager.activeRecipe {
                switch activeRecipe.type {
                case .task, .commit:
                    RecipeListView(recipeList: $recipeList)
                case .view:
                    if let userDefinedRecipeView = userDefinedRecipeView {
                       switch userDefinedRecipeView.type {
                       case .empty:
                           EmptyView()
                       case .error:
                           ScrollView(showsIndicators: false) {
                               if let err = userDefinedRecipeView.errorMessage {
                                   Text(err)
                                       .font(.title3)
                                       .foregroundColor(.red)
                               } else {
                                   Text("Unknown Error")
                                       .font(.title3)
                                       .foregroundColor(.red)
                               }
                           }
                       case.text:
                           VStack {
                               ForEach(userDefinedRecipeView.items, id: \.title) { item in
                                   Text(item.title)
                               }
                           }
                       case .list:
                           ScrollView(showsIndicators: false) {
                               VStack {
                                   ForEach(userDefinedRecipeView.items, id: \.title) { item in
                                       UserDefinedRecipeListItemView(item: item)
                                           .frame(width: Config.mainWidth.get()-30, height: Config.userDefinedRecipeItemHeight.get())
                                   }
                               }
                           }.padding(.vertical)
                       }
                   } else {
                       EmptyView()
                   }
                    Spacer()
                    HStack {
                        Text("total: \((userDefinedRecipeView?.items.count) ?? 0)")
                            .font(.system(.footnote, design: .monospaced))
                        Spacer()
                        HStack(spacing: 0) {
                            let timeCost = userDefinedRecipeView?.timeCost ?? 0
                            Text("timeCost: ")
                                .font(.system(.footnote, design: .monospaced))
                            Text("\(timeCost)")
                                .font(.system(.footnote, design: .monospaced))
                                .foregroundStyle(timeCost < 100 ? .green : (timeCost < 500 ? .yellow : .red))
                            Text(" ms")
                                .font(.system(.footnote, design: .monospaced))
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                RecipeListView(recipeList: $recipeList)
            }
        }
//        .onAppear {
//            RecipeManager.activeRecipe?.execute()
//        }
        // todo: carefully controll event, avoid repeat execute
        .onReceive(NotificationCenter.default.publisher(for: .RecipeStatusChanged)) { _ in
            if let recipe = RecipeManager.activeRecipe, recipe.type != .commit {
                recipe.execute()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .RecipeCommited)) { _ in
            if let recipe = RecipeManager.activeRecipe, recipe.type == .commit {
                recipe.execute()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .CommandBarEndEditing)) { notification in
            if let recipe = RecipeManager.activeRecipe, recipe.type == .view {
                recipe.execute()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .UserDefinedRecipeViewChanged)) { notification in
            if let view = notification.userInfo?["view"] as? UserDefinedRecipeView {
                withAnimation(.spring) {
                    self.userDefinedRecipeView = view
                }
            }
        }
    }
    
}

struct UserDefinedRecipeListItemView: View {
    
    var item: UserDefinedRecipeView.UserDefinedRecipeViewItem
    
    @State var isSelected: Bool = false
    
    var body: some View {
        HStack(spacing: 10) {
            HStack {
                (item.icon?.icon ?? Image(systemName: "doc.plaintext"))
                    .resizable()
                    .scaledToFit()
            }.frame(width: Config.userDefinedRecipeItemHeight.get())
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                .font(.title2)
//                    .fontWeight(.bold)
                .foregroundColor(isSelected ? Color.white: Color.black)
                if let desc = item.description {
                    Text(desc)
                    .font(.caption)
                    .foregroundColor(.gray)
                }
            }
            Spacer()
        }
//        .frame(maxWidth: Config.mainWidth)
        .padding(5)
        .background(isSelected ? Config.selectedItemBackgroundColor.get().color : Config.userDefinedRecipeDefaultIemColor.get().color)
        .cornerRadius(5)
        .onHover { isHovered in
            isSelected = isHovered
        }
        .onTapGesture {
            if let actions = item.actions {
                for action in actions {
                    action.execute()
                }
            }
        }
//        .shadow(color: Color.gray.opacity(0.3), radius: 2, x: 0, y: 2)
//        .onTapGesture(count: 1, perform: action)
    }
    
}

