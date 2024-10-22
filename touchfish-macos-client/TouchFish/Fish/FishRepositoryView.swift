import SwiftUI

struct FishRepositoryView: View {
    
    @State var fishs: [String:Fish] = [:]
    @State var selectedFishIdentity: String?
    
    @State var isEditing: Bool = false
    @State var isMultSelecting: Bool = false
    @State var multSelectedFishIdentitys: Set<String> = []
    
    @State var fuzzy: String? = nil
    @State var identitys: [String]? = nil
    @State var fishTypes: [Fish.FishType]? = nil
    @State var tags: [String]? = nil
    @State var isMarked: Bool? = nil
    @State var isLocked: Bool? = nil
    @State var sortField: String = ""
    
    var isAllMultSelected: Bool {
        for identity in fishs.keys {
            if !multSelectedFishIdentitys.contains(identity) {
                return false
            }
        }
        return true
    }
    
    var isAllMultSelectedLocked: Bool {
        for identity in multSelectedFishIdentitys {
            if let fish = fishs[identity], fish.isLocked == false {
                return false
            }
        }
        return true
    }
    
    var isAllMultSelectedMarked: Bool {
        for identity in multSelectedFishIdentitys {
            if let fish = fishs[identity], fish.isMarked == false {
                return false
            }
        }
        return true
    }
    
    var body: some View {
        HStack {
            if isEditing, let identity = selectedFishIdentity, let editingFish = fishs[identity] {
                FishEditView(
                    isEditing: $isEditing,
                    identity: editingFish.identity,
                    description: editingFish.description,
                    tags: editingFish.tags
                )
                .frame(width: Constant.mainWidth-30)
            } else {
                VStack {
                    if isMultSelecting {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Constant.selectedItemBackgroundColor.color)
                            HStack(spacing: 3) {
                                if isAllMultSelected {
                                    HStack {
                                        Image(systemName: "checkmark.square")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundStyle(.white)
                                            .onTapGesture {
                                                multSelectedFishIdentitys.removeAll()
                                            }
                                    }
                                    .frame(width: 25, height: 20)
                                } else {
                                    HStack {
                                        Image(systemName: "square")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundStyle(.white)
                                            .onTapGesture {
                                                for identity in fishs.keys {
                                                    multSelectedFishIdentitys.insert(identity)
                                                }
                                            }
                                    }
                                    .frame(width: 25, height: 20)
                                }
                                Spacer()
                                // todo: icon move anima when lock
                                if isAllMultSelectedLocked {
                                    UnLockButtonView()
                                        .onTapGesture {
                                            Task {
                                                for identity in multSelectedFishIdentitys {
                                                    await Storage.unLockFish(identity)
                                                }
                                            }
                                        }
                                } else {
                                    LockButtonView()
                                        .onTapGesture {
                                            Task {
                                                for identity in multSelectedFishIdentitys {
                                                    await Storage.lockFish(identity)
                                                }
                                            }
                                        }
                                    if isAllMultSelectedMarked {
                                        UnMarkButtonView()
                                            .onTapGesture {
                                                Task {
                                                    for identity in multSelectedFishIdentitys {
                                                        await Storage.unMarkFish(identity)
                                                    }
                                                }
                                            }
                                    } else {
                                        MarkButtonView()
                                            .onTapGesture {
                                                Task {
                                                    for identity in multSelectedFishIdentitys {
                                                        await Storage.markFish(identity)
                                                    }
                                                }
                                            }
                                    }
                                    DeleteButtonView()
                                        .onTapGesture {
                                            Task {
                                                for identity in multSelectedFishIdentitys {
                                                    await Storage.removeFish(identity)
                                                }
                                            }
                                            multSelectedFishIdentitys.removeAll()
                                        }
                                }
                            }
                            .padding(.horizontal, 5)
                        }
                        .padding(.horizontal, 3)
                        .frame(height: 40)
                    }
                    FishListView(
                        fishList: fishs.values.sorted(by: {
                            if sortField.lowercased() == "create" {
                                return $0.createTime == $1.createTime ? $0.identity > $1.identity : $0.createTime > $1.createTime
                            }
                            if sortField.lowercased() == "type" {
                                return $0.fishType == $1.fishType ? $0.identity > $1.identity : $0.fishType.rawValue > $1.fishType.rawValue
                            }
                            if sortField.lowercased() == "size" {
                                let size0 = $0.dataInfo.byteCount ?? -1
                                let size1 = $1.dataInfo.byteCount ?? -1
                                return size0 == $1.dataInfo.byteCount ? $0.identity > $1.identity : size0 > size1
                            }
                            return $0.updateTime == $1.updateTime ? $0.identity > $1.identity : $0.updateTime > $1.updateTime
                        }),
                        selectedFishIdentity: $selectedFishIdentity,
                        isEditing: $isEditing,
                        isMultSelecting: $isMultSelecting,
                        multSelectedFishIdentitys: $multSelectedFishIdentitys
                    )
                    .frame(width: (Constant.mainWidth - 30)/2)
                }
                FishDetailView(
                    fishs: $fishs,
                    selectedFishIdentity: $selectedFishIdentity,
                    isMultSelecting: $isMultSelecting,
                    multSelectedFishIdentitys: $multSelectedFishIdentitys
                )
                .frame(width: (Constant.mainWidth - 30)/2)
            }
        }
        .padding(.horizontal, 5)
        .onAppear {
            isEditing = false
            // TODO: appear animation
            NotificationCenter.default.post(name: .CommandBarShouldFocus, object: nil, userInfo: nil)
            NotificationCenter.default.post(name: .ShouldRefreshFish, object: nil, userInfo: nil)
        }
        .onReceive(NotificationCenter.default.publisher(for: .ShouldRefreshFish)) { _ in
            Task {
                let fishs = await Storage.searchFish(
                    fuzzy: fuzzy, identitys: identitys, fishTypes: fishTypes, tags: tags, isMarked: isMarked, isLocked: isLocked
                )
                NotificationCenter.default.post(name: .FishRefreshed, object: nil, userInfo: ["fish":fishs])
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .FishRefreshed)) { notification in
            if let fish = notification.userInfo?["fish"] as? [String:Fish] {
                if self.fishs.isEmpty || fish.isEmpty {
                    withAnimation(.easeIn(duration: 0.2)) {
                        self.fishs = fish
                    }
                } else {
                    withAnimation(.spring(duration: 0.4)) {
                        self.fishs = fish
                    }
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .CommandBarEndEditing)) { notification in
            fuzzy = nil
            if let commandText = notification.userInfo?["commandText"] as? String, !isEditing {
                fuzzy = commandText
            }
            NotificationCenter.default.post(name: .ShouldRefreshFish, object: nil, userInfo: nil)
        }
        .onReceive(NotificationCenter.default.publisher(for: .RecipeStatusChanged)) { _ in
            identitys = nil
            fishTypes = nil
            tags = nil
            isMarked = nil
            isLocked = nil
            sortField = ""
            for (argName, argValue) in RecipeManager.activeRecipeArg {
                if argName == "identity" {
                    identitys = argValue
                }
                if argName == "type" {
                    fishTypes = argValue.compactMap { Fish.FishType(rawValue: $0.capitalized) }
                }
                if argName == "tag" {
                    tags = argValue
                }
                if argName == "marked", argValue.count > 0 {
                    if argValue[0].lowercased() == "true" || argValue[0] == "1" {
                        isMarked = true
                    }
                    if argValue[0].lowercased() == "false" || argValue[0] == "0" {
                        isMarked = false
                    }
                }
                if argName == "locked", argValue.count > 0 {
                    if argValue[0].lowercased() == "true" || argValue[0] == "1" {
                        isLocked = true
                    }
                    if argValue[0].lowercased() == "false" || argValue[0] == "0" {
                        isLocked = false
                    }
                }
                if argName == "sort", argValue.count > 0 {
                    sortField = argValue[0].lowercased()
                }
            }
            NotificationCenter.default.post(name: .ShouldRefreshFish, object: nil, userInfo: nil)
        }
    }

}
