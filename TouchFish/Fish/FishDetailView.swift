import SwiftUI

struct FishDetailView: View {
    
    var fishList: [Fish]
    var fishMap: [Int: Fish]
    @Binding var selectedFishId: Int
    
    init(fishList: [Fish], selectedFishId: Binding<Int>) {
        self.fishList = fishList
        self.fishMap = Dictionary(uniqueKeysWithValues: fishList.map { ($0.id, $0) })
        self._selectedFishId = selectedFishId
    }
    
    var body: some View {
        if let selectedFish = fishMap[selectedFishId] ?? fishList.first {
            VStack {
                ScrollView {
                    switch selectedFish.type {
                    case .txt:
                        VStack {
                            if let textValue = selectedFish.textPreview {
                                Text(textValue.prefix(1000))
                                    .font(.callout)
                                if textValue.count > 1000 {
                                    Text("...")
                                        .font(.callout)
                                        .bold()
                                }
                            } else {
                                Text("No Preview")
                                    .font(.callout)
                                    .foregroundStyle(Color.red)
                            }
                        }
                    case .tiff, .png, .jpg:
                        if let image = selectedFish.imagePreview {
                            Image(nsImage: image)
                                .resizable()
                                .scaledToFit()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(maxWidth: (Config.mainWidth - 30)/2)
                                
                        } else {
                            Text("No Preview")
                                .font(.callout)
                                .foregroundColor(.red)
                        }
                    default:
                        Text("Not Supported To Preview")
                            .font(.callout)
                            .foregroundColor(.red)
                    }
                }
                Spacer()
                VStack(alignment: .leading) {
                    Divider().background(Color.gray.opacity(0.2))
                    ScrollView(showsIndicators: false) {
                        
                        if selectedFish.tags.count > 0 {
                            HStack {
                                Text("Tags")
                                    .font(.system(.caption2, design: .monospaced))
                                    .bold()
                                Spacer()
                                HStack {
                                    ForEach(selectedFish.tags, id: \.self) { tg in
                                        Rectangle()
                                            .fill(String(Functions.getMD5(of: tg).prefix(6)).color)
                                            .overlay(
                                                Text(tg)
                                                    .foregroundColor(.white)
                                            )
                                            .frame(width: max(CGFloat(tg.count*10), 40), height: 20)
                                            .cornerRadius(10)
                                    }
                                }
                            }
                        }
                        
                        if selectedFish.description.count > 0 {
                            DetailItemView(itemName: "Description", itemValue: selectedFish.description)
                        }
                        DetailItemView(itemName: "Identity", itemValue: selectedFish.identity)
                        DetailItemView(itemName: "Type", itemValue: selectedFish.type.rawValue)
                        DetailItemView(itemName: "Source Application", itemValue: selectedFish.extraInfo.sourceAppName)
                        switch selectedFish.type {
                        case .txt:
                            DetailItemView(itemName: "Char Count", itemValue: selectedFish.extraInfo.charCount)
                            DetailItemView(itemName: "Word Count", itemValue: selectedFish.extraInfo.wordCount)
                            DetailItemView(itemName: "Row Count", itemValue: selectedFish.extraInfo.rowCount)
                        case .tiff, .png, .jpg:
                            DetailItemView(itemName: "Width", itemValue: selectedFish.extraInfo.width)
                            DetailItemView(itemName: "Height", itemValue: selectedFish.extraInfo.height)
                        default:
                            DetailItemView(itemName: "", itemValue: "")
                        }
                        DetailItemView(itemName: "Size", itemValue: Functions.descByteCount(selectedFish.byteCount))
                        DetailItemView(itemName: "Create Time", itemValue: selectedFish.createTime)
                        DetailItemView(itemName: "Update Time", itemValue: selectedFish.updateTime)
                    }
                }
                .frame(height: Config.mainHeight * 0.2)
                
            }
        }
    }
    
}

struct DetailItemView: View {
    
    var itemName: String
    var itemValue: String?
    
    init(itemName: String, itemValue: String? = nil) {
        self.itemName = itemName
        self.itemValue = itemValue
    }
    
    init(itemName: String, itemValue: Int? = nil) {
        self.itemName = itemName
        if let itemValue = itemValue {
            self.itemValue = String(itemValue)
        }
    }
    
    var body: some View {
        HStack {
            if let itemValue = itemValue {
                Text(itemName)
                    .font(.system(.caption2, design: .monospaced))
                    .bold()
                Spacer()
                Text(itemValue)
                    .font(.system(.body, design: .monospaced))
            }

        }
    }
    
}
