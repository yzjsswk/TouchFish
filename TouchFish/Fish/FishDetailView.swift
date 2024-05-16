import SwiftUI

struct FishDetailView: View {
    
    var fishList: [Fish]
    var fishMap: [Int: Fish]
    
    @Binding var selectedFishId: Int?
    
    @State var showDetail: Bool = false
    @State var showDetailWithAnima: Bool = false
    
    init(fishList: [Fish], selectedFishId: Binding<Int?>) {
        self.fishList = fishList
        self.fishMap = Dictionary(uniqueKeysWithValues: fishList.map { ($0.id, $0) })
        self._selectedFishId = selectedFishId
    }
    
    var body: some View {
        if let selectedFish = selectedFishId != nil ? fishMap[selectedFishId!] ?? fishList.first : fishList.first {
            VStack {
                VStack {
                    DetailTagView(fish: selectedFish)
                    DetailDescView(fish: selectedFish)
                }
                .padding()
                //                .background(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    //                        .padding()
                )
                //                Divider().background(Color.gray.opacity(0.2))
                ScrollView {
                    DetailValueView(fish: selectedFish)
                }
                Spacer()
                VStack {
                    Divider().background(Color.gray.opacity(0.2))
                    ArrowView()
                        .rotationEffect(.degrees(180))
                        .onTapGesture {
                            withAnimation {
                                showDetailWithAnima = false
                            }
                            showDetail = false
                        }
                    DetailExtraInfoView(fish: selectedFish)
                }
                .offset(y: showDetailWithAnima ? 0 : 500)
                .onTapGesture {
                    Log.debug("clicked")
                }
                if !showDetail {
                    ArrowView()
                        .onTapGesture {
                            withAnimation {
                                showDetailWithAnima = true
                            }
                            showDetail = true
                        }
                }
            }
        }
    }
    
}

struct DetailTagView: View {
    
    var fish: Fish?
    
    var body: some View {
        if let fish = fish, fish.tags.count > 0 {
            HStack {
                ForEach(Array(fish.tags.enumerated()), id: \.0) { (idx, tagGroup) in
                    ForEach(tagGroup, id: \.self) { tg in
                        Rectangle()
                            .fill(String(Functions.getMD5(of: tg).prefix(6)).color)
                            .overlay(
                                Text(tg)
                                    .foregroundColor(.white)
                            )
                            .frame(width: max(CGFloat(tg.count*10), 40), height: 20)
                            .cornerRadius(10)
                    }
                    if idx < fish.tags.count-1 {
                        Divider()
                    }
                }
                Spacer()
            }
            .frame(height: 20)
        } else {
            EmptyView()
        }
    }
    
}
    
struct DetailDescView: View {
    
    var fish: Fish?
    
    var body: some View {
        if let fish = fish, fish.description.count > 0 {
            HStack {
                Text(fish.description)
                    .font(.title3)
                    .bold()
                Spacer()
            }
        } else {
            EmptyView()
        }
    }
    
}

struct DetailValueView: View {
    
    var fish: Fish?
    
    var body: some View {
        if let fish = fish {
            switch fish.type {
            case .txt:
                    VStack {
                        if let textValue = fish.textPreview {
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
                                .foregroundColor(Color.red)
                        }
                    }
                case .tiff, .png, .jpg:
                    if let image = fish.imagePreview {
                        Image(nsImage: image)
                            .resizable()
                            .scaledToFit()
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
        } else {
            EmptyView()
        }
    }
    
}

struct DetailExtraInfoView: View {
    
    var fish: Fish?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            if let fish = fish {
                VStack(alignment: .leading) {
                    DetailItemView(itemName: "Type", itemValue: fish.type.rawValue)
                    DetailItemView(itemName: "Source Application", itemValue: fish.extraInfo.sourceAppName)
                    switch fish.type {
                    case .txt:
                        DetailItemView(itemName: "Char Count", itemValue: fish.extraInfo.charCount)
                        DetailItemView(itemName: "Word Count", itemValue: fish.extraInfo.wordCount)
                        DetailItemView(itemName: "Row Count", itemValue: fish.extraInfo.rowCount)
                    case .tiff, .png, .jpg:
                        DetailItemView(itemName: "Width", itemValue: fish.extraInfo.width)
                        DetailItemView(itemName: "Height", itemValue: fish.extraInfo.height)
                    case .pdf:
                        EmptyView()
                    }
                    DetailItemView(itemName: "Size", itemValue: Functions.descByteCount(fish.byteCount))
                    DetailItemView(itemName: "Create Time", itemValue: fish.createTime)
                    DetailItemView(itemName: "Update Time", itemValue: fish.updateTime)
                }
                .padding(.vertical, 5)
            } else {
                EmptyView()
            }
        }
        .frame(height: Config.mainHeight*0.3)
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
        if let itemValue = itemValue {
            HStack {
                Text(itemName)
                    .font(.system(.caption2, design: .monospaced))
                    .bold()
                Spacer()
                Text(itemValue)
                    .font(.system(.body, design: .monospaced))
            }
            .frame(height: Config.fishDetailItemHeight)
        }
    }
    
}

struct ArrowView: View {
    
    @State var isHovered: Bool = false
    
    struct ArrowShap: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            return path
        }
    }

    var body: some View {
        ArrowShap()
            .stroke(.gray, lineWidth: 2)
            .frame(width: Config.mainWidth*0.15, height: 10)
            .background(Color.gray.opacity(0.01))
            .offset(y: isHovered ? 0 : 5)
            .onHover { isHovered in
                withAnimation {
                    self.isHovered = isHovered
                }
            }
    }
    
}

