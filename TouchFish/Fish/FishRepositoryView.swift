import SwiftUI

struct FishRepositoryView: View {
    
    @Binding var fishs: [String:Fish]
    
    @State var selectedFishIdentity: String?
    
    @Binding var isEditing: Bool
    
    @State var sortField: String = ""
    
    var body: some View {
        HStack {
            if isEditing, 
                let identity = selectedFishIdentity,
               let editingFish = fishs[identity] {
                FishEditView(
                    isEditing: $isEditing,
                    identity: editingFish.identity,
                    description: editingFish.description,
                    tags: editingFish.tags
                )
                .frame(width: Constant.mainWidth - 30)
            } else {
                FishListView(
                    fishList: fishs.values.sorted(by: {
                        if sortField.lowercased() == "update" {
                            return $0.updateTime == $1.updateTime ? $0.identity > $1.identity : $0.updateTime > $1.updateTime
                        }
                        if sortField.lowercased() == "type" {
                            return $0.type == $1.type ? $0.identity > $1.identity : $0.type.rawValue > $1.type.rawValue
                        }
                        if sortField.lowercased() == "size" {
                            return $0.byteCount == $1.byteCount ? $0.identity > $1.identity : $0.byteCount > $1.byteCount
                        }
                        return $0.createTime == $1.createTime ? $0.identity > $1.identity : $0.createTime > $1.createTime
                    }),
                    isEditing: $isEditing,
                    selectedFishIdentity: $selectedFishIdentity
                )
                .frame(width: (Constant.mainWidth - 30)/2)
                VStack {
                    FishDetailView(fishs: fishs, selectedFishIdentity: $selectedFishIdentity)
                        .frame(width: (Constant.mainWidth - 30)/2)
                }
            }
        }
        .padding(.horizontal, 5)
        .onAppear() {
            isEditing = false
            Cache.refresh()
        }
        .onReceive(NotificationCenter.default.publisher(for: .CommandBarEndEditing)) { notification in
            if let commandText = notification.userInfo?["commandText"] as? String, !isEditing {
                Cache.fuzzys = commandText
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .RecipeStatusChanged)) { _ in
            // todo: do not refresh cache 
            Cache.identity = nil
            Cache.type = nil
            Cache.tags = nil
            Cache.isMarked = nil
            Cache.isLocked = nil
            sortField = ""
            for (argName, argValue) in RecipeManager.activeRecipeArg {
                if argName == "identity", argValue.count > 0 {
                    Cache.identity = argValue[0]
                }
                if argName == "type" {
                    Cache.type = argValue.compactMap { FishType(rawValue: $0) }
                }
                if argName == "tag" {
                    // todo: mult tag search may work uncorrert
                    Cache.tags = [argValue]
                }
                if argName == "marked", argValue.count > 0 {
                    if argValue[0].lowercased() == "true" || argValue[0] == "1" {
                        Cache.isMarked = true
                    }
                    if argValue[0].lowercased() == "false" || argValue[0] == "0" {
                        Cache.isMarked = false
                    }
                }
                if argName == "locked", argValue.count > 0 {
                    if argValue[0].lowercased() == "true" || argValue[0] == "1" {
                        Cache.isLocked = true
                    }
                    if argValue[0].lowercased() == "false" || argValue[0] == "0" {
                        Cache.isLocked = false
                    }
                }
                if argName == "sort", argValue.count > 0 {
                    sortField = argValue[0]
                }
            }
        }
    }

}
