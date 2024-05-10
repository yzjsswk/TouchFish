import SwiftUI

struct FishListItemView: View {
    
    var id: Int
    var identity: String
    @Binding var selectedFishId: Int
    var isSelected: Bool {
        return id == selectedFishId
    }
    
    var name: String?
    var desc: String?
    var icon: Image?
    var isMarked: Bool
    var action: () -> Void
    
    init(id: Int, identity: String, selectedFishId: Binding<Int>, name: String? = nil, desc: String? = nil,  icon: Image? = nil, isMarked: Bool = false, action: @escaping () -> Void) {
        self.id = id
        self.identity = identity
        self._selectedFishId = selectedFishId
        self.name = name
        self.desc = desc
        self.icon = icon
        self.isMarked = isMarked
        self.action = action
    }
    
    var body: some View {
        HStack(spacing: 10) {
            icon?
            .resizable()
            .scaledToFit()
//            .font(.largeTitle)
//            .foregroundColor(.red)
            VStack(alignment: .leading, spacing: 4) {
                if let name = name {
                    Text(name)
                    .font(.title2)
//                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? Color.white: Color.black)
                }
                if let desc = desc {
                    Text(desc)
                    .font(.caption)
                    .foregroundColor(.gray)
                }
            }
            Spacer()
            if isMarked {
                Image(systemName: "bookmark.fill")
                    .foregroundColor(.orange)
                    .onTapGesture {
                        Task {
                            let res = await Storage.unMarkFish(identity)
                            if res == .fail {
                                Log.error("click button to unmark fish - fail: storage.unMarkFish return fail, identity = \(identity)")
                            }
                        }
                    }
            } else if isSelected {
                Image(systemName: "bookmark")
                    .foregroundColor(.orange)
                    .onTapGesture {
                        Task {
                            let res = await Storage.markFish(identity)
                            if res == .fail {
                                Log.error("click button to mark fish - fail: storage.markFish return fail, identity = \(identity)")
                            }
                        }
                    }
            }
        }
        .frame(maxWidth: Config.mainWidth)
        .padding(5)
        .background(isSelected ? Config.selectedItemBackgroundColor.color : Config.mainBackgroundColor.color)
        .cornerRadius(5)
//        .shadow(color: Color.gray.opacity(0.3), radius: 2, x: 0, y: 2)
        .onTapGesture(count: 1, perform: action)
        .onHover { isHovered in
//            Log.info(" \(id) \(isHovered)")
            if isHovered {
//                Log.info("selected fish id \(selectedFishId) -> \(id)")
                selectedFishId = id
            }
        }
        
    }
    
}
