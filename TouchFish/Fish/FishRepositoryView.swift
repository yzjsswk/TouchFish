import SwiftUI

struct FishRepositoryView: View {
    
    var fishs: [String:Fish]
    
    @State var selectedFishIdentity: String?
    
    @Binding var isEditing: Bool
    
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
                .frame(width: Config.mainWidth - 30)
            } else {
                if fishs.count > 0 {
                    // todo: command
                    FishListView(
                        fishList: fishs.values.sorted(by: {$0.createTime > $1.createTime}),
                        isEditing: $isEditing,
                        selectedFishIdentity: $selectedFishIdentity
                    )
                    .frame(width: (Config.mainWidth - 30)/2)
                } else {
                    Text("No Fish")
                        .font(.title)
                        .frame(width: (Config.mainWidth - 30)/2)
                }
                VStack {
                    FishDetailView(fishs: fishs, selectedFishIdentity: $selectedFishIdentity)
                        .frame(width: (Config.mainWidth - 30)/2)
                }
            }
        }
        .padding(.horizontal, 5)
        .onReceive(NotificationCenter.default.publisher(for: .CommandTextChanged)) { notification in
            if let commandText = notification.userInfo?["commandText"] as? String, !isEditing {
                Cache.fuzzys = commandText
            }
        }
    }

}

struct BookmarkButtonView: View {
    
    @State private var isFiltering = false
    @State private var isHovered = false
    
    var body: some View {
        if isFiltering {
            Image(systemName: "bookmark.fill")
                .resizable()
                .frame(width: 15, height: 20)
                .foregroundColor(.orange)
                .onTapGesture {
                    Cache.isMarked = nil
                    isFiltering = false
                }
        } else {
            Image(systemName: "bookmark")
                .resizable()
                .frame(width: 15, height: 20)
                .foregroundColor(isHovered ? .orange : .gray)
                .onTapGesture {
                    Cache.isMarked = true
                    isFiltering = true
                }
                .onHover { isHovered in
                    self.isHovered = isHovered
                }
        }
    }
    
}

struct FilterButtonView: View {
    
    @State private var isHovered = false
    
    var body: some View {
        Image(systemName: "line.3.horizontal.decrease.circle")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(isHovered ? Config.selectedItemBackgroundColor.color : .gray)
            .onHover { isHovered in
                self.isHovered = isHovered
            }
    }
    
}

struct AddButtonView: View {
    
    @State private var isHovered = false
    
    var body: some View {
        Image(systemName: "plus.circle")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(isHovered ? Config.selectedItemBackgroundColor.color : .gray)
            .onHover { isHovered in
                self.isHovered = isHovered
            }
    }
    
}

