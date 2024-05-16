import SwiftUI

struct FishListView: View {
    
    var fishList: [Fish]
    
    @Binding var selectedFishId: Int?
    @State var hoveringFishId: Int?
    
    @State var lastHoverTs: TimeInterval = Date().timeIntervalSince1970
    
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators: false) {
                VStack {
                    ForEach(fishList, id: \.id) { fish in
                        FishListItemView(fish: fish, selectedFishId: $selectedFishId, hoveringFishId: $hoveringFishId)
                            .onHover { isHovered in
                                if isHovered {
                                    selectedFishId = fish.id
                                    if hoveringFishId != fish.id {
                                        hoveringFishId = nil
                                    }
                                    lastHoverTs = Date().timeIntervalSince1970
                                    let hoverTs = lastHoverTs
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        if isHovered && lastHoverTs == hoverTs {
                                            withAnimation(.spring(duration: 0.4)) {
                                                hoveringFishId = fish.id
                                            }
                                        }
                                    }
                                }
                            }
                    }
                }
                .padding(.vertical, 5)
            }
            HStack {
                Text("total: \(fishList.count)")
                    .font(.footnote)
                Spacer()
            }
            
        }

    }
    
}



