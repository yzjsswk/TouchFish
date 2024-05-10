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
                            if let textValue = selectedFish.textValue {
                                Text(textValue.prefix(1000))
                                    .font(.callout)
                                if textValue.count > 1000 {
                                    Text("...")
                                        .font(.callout)
                                        .bold()
                                }
                            } else {
                                Text("Resource Not Found")
                                    .font(.callout)
                                    .foregroundStyle(Color.red)
                            }
                        }
                    case .tiff:
                        if let image = Storage.getImageByIdentity(selectedFish.identity) {
                            Image(nsImage: image)
                                .resizable()
                                .scaledToFit()
                        } else {
                            Text("Image File Not Found")
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
                        
                        DetailItemView(itemName: "Type", itemValue: selectedFish.type.rawValue)
//                        DetailItemView(itemName: "Source", itemValue: selectedFish.source.rawValue)
                        if selectedFish.type == .txt {
                            DetailItemView(itemName: "Char Count", itemValue: String(selectedFish.extraInfo.charCount ?? 0))
                            DetailItemView(itemName: "Word Count", itemValue: String(selectedFish.extraInfo.wordCount ?? 0))
                            DetailItemView(itemName: "Row Count", itemValue: String(selectedFish.extraInfo.rowCount ?? 0))
                        }
                        if selectedFish.type == .tiff {
                            DetailItemView(itemName: "Width", itemValue: String(selectedFish.extraInfo.width ?? 0))
                            DetailItemView(itemName: "Height", itemValue: String(selectedFish.extraInfo.height ?? 0))
                        }
                        DetailItemView(itemName: "Size", itemValue: String(selectedFish.byteCount / 1024 / 1024) + "MB")
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
    var itemValue: String
    
    var body: some View {
        HStack {
            Text(itemName)
                .font(.system(.caption2, design: .monospaced))
                .bold()
            Spacer()
            Text(itemValue)
                .font(.system(.body, design: .monospaced))
        }
    }
    
}
