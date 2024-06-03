import SwiftUI

struct RecipeView: View {
    
    @Binding var recipeList: [Recipe]
    
    var activeRecipeBundleId: String?
    
    @State var executeResult: RecipeExecuteResult?
    
    var body: some View {
        VStack {
            if let activeRecipeBundleId = activeRecipeBundleId,
               let activeRecipe = RecipeManager.activeRecipe {
               if let executeResult = executeResult {
                   if let err = executeResult.errorMessage {
                       Text(err)
                   } else {
                       if let type = executeResult.type {
                           if type == .text {
                               VStack {
                                   ForEach(executeResult.items, id: \.title) { item in
                                       Text(item.title)
                                   }
                               }
                           }
                           if type == .list {
                               ScrollView(showsIndicators: false) {
                                   VStack {
                                       ForEach(executeResult.items, id: \.title) { item in
                                           UserDefinedRecipeListItemView(item: item)
                                               .frame(width: Config.mainWidth-30, height: Config.userDefinedRecipeItemHeight)
                                       }
                                   }
                               }.padding(.vertical)
                           }
                       } else {
                           EmptyView()
                       }
                   }
               } else {
                   EmptyView()
               }
                Spacer()
                HStack {
                    Text("total: \((executeResult?.items.count) ?? 0)")
                        .font(.system(.footnote, design: .monospaced))
                    Spacer()
                    HStack(spacing: 0) {
                        let timeCost = executeResult?.timeCost ?? 0
                        Text("timeCost: ")
                            .font(.system(.footnote, design: .monospaced))
                        Text("\(timeCost)")
                            .font(.system(.footnote, design: .monospaced))
                            .foregroundStyle(timeCost < 500 ? .green : (timeCost < 1000 ? .yellow : .red))
                        Text(" ms")
                            .font(.system(.footnote, design: .monospaced))
                    }
                }
                .padding(.horizontal)
            } else {
                RecipeListView(recipeList: $recipeList)
            }
        }
        .onAppear {
            executeResult = RecipeManager.activeRecipe?.execute()
        }
        .onReceive(NotificationCenter.default.publisher(for: .RecipeStatusChanged)) { _ in
            withAnimation {
                executeResult = RecipeManager.activeRecipe?.execute()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .CommandBarEndEditing)) { notification in
            if let commandText = notification.userInfo?["commandText"] as? String {
                withAnimation {
                    executeResult = RecipeManager.activeRecipe?.execute()
                }
            }
        }
    }
    
}

struct UserDefinedRecipeListItemView: View {
    
    var item: RecipeExecuteResult.resultItem
    
    @State var isSelected: Bool = false
    
    var body: some View {
        HStack(spacing: 10) {
            HStack {
                (item.icon?.icon ?? Image(systemName: "link"))
                    .resizable()
                    .scaledToFit()
            }.frame(width: Config.userDefinedRecipeItemHeight)
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
        .background(isSelected ? Config.selectedItemBackgroundColor.color : Config.userDefinedRecipeDefaultIemColor.color)
        .cornerRadius(5)
        .onHover { isHovered in
            isSelected = isHovered
        }
//        .shadow(color: Color.gray.opacity(0.3), radius: 2, x: 0, y: 2)
//        .onTapGesture(count: 1, perform: action)
        
    }
    
}

