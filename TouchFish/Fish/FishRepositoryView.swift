import SwiftUI

struct FishRepositoryView: View {
    
    var fishList: [Fish]
    @State var selectedFishId: Int
    @State var isEditing: Bool = false
    @State var isFiltering: Bool = false
    
    init(fishList: [Fish]) {
        self.fishList = fishList
        self._selectedFishId = State(initialValue: fishList.first?.id ?? 0)
    }
    
    var body: some View {
        if isEditing, let selectedFish = fishList.first(where: { $0.id == selectedFishId} ) {
            FishEditView(
                id: selectedFish.id,
                identity: selectedFish.identity,
                description: selectedFish.description,
                content: selectedFish.textPreview ?? "",
                selectedTypeIndex: selectedFish.type.index!,
                tags: selectedFish.tags,
                isEditing: $isEditing
            )
            .padding(.horizontal)
            .padding(.vertical, 5)
        } else {
            HStack {
                if fishList.count > 0 {
                    FishListView(fishList: fishList, selectedFishId: $selectedFishId)
                } else {
                    Text("No Fish")
                        .font(.title)
                        .frame(width: (Config.mainWidth - 30)/2)
                }
                VStack {
                    HStack {
                        BookmarkButtonView()
                        FilterButtonView()
                            .onTapGesture {
                                isFiltering.toggle()
                            }
                        Spacer()
                        AddButtonView()
                        EditButtonView()
                            .onTapGesture {
                                if fishList.first(where: { $0.id == selectedFishId}) != nil {
                                    isEditing = true
                                }
                            }
                        DeleteButtonView()
                            .onTapGesture {
                                let idx = fishList.firstIndex(where: { $0.id == selectedFishId })
                                let nextFishId = (idx == nil || fishList.count < 2) ? 0 : fishList[idx == 0 ? 1 : idx!-1].id
                                let toDeleteFishIdentity = fishList[idx!].identity
                                Task {
                                    let res = await Storage.removeFish(toDeleteFishIdentity)
                                    if res == .fail {
                                        Log.error("click button to delete fish - fail: Storage.removeFish return fail, identity=\(toDeleteFishIdentity)")
                                    } else {
//                                        withAnimation {
                                        selectedFishId = nextFishId
//                                        }
                                    }
                                }
                            }
                    }
                    .padding(.horizontal, 5)
                    if isFiltering {
                        FishFilterView()
                    } else {
                        FishDetailView(fishList: fishList, selectedFishId: $selectedFishId)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 5)
            .onReceive(NotificationCenter.default.publisher(for: .CommandTextChanged)) { notification in
                if let commandText = notification.userInfo?["commandText"] as? String {
                    Cache.fuzzys = commandText
                }
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

struct EditButtonView: View {
    
    @State private var isHovered = false
    
    var body: some View {
        Image(systemName: "square.and.pencil")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(isHovered ? Config.selectedItemBackgroundColor.color : .gray)
            .onHover { isHovered in
                self.isHovered = isHovered
            }
    }
    
}

struct DeleteButtonView: View {
    
    @State private var isHovered = false
    
    var body: some View {
        Image(systemName: "trash.fill")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(isHovered ? .red : .gray)
            .onHover { isHovered in
                self.isHovered = isHovered
            }
    }
    
}

