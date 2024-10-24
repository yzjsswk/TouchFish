import SwiftUI

struct FishDetailView: View {
    
    @Binding var fishs: [String:Fish]
    @Binding var selectedFishIdentity: String?
    @Binding var isMultSelecting: Bool
    @Binding var multSelectedFishIdentitys: Set<String>
    
    var selectedFish: Fish? {
        if let identity = selectedFishIdentity {
            return fishs[identity]
        }
        return nil
    }
    
    @State var showDetail: Bool = false
    @State var showDetailWithAnima: Bool = false
    
    var body: some View {
        VStack {
            if let selectedFish = self.selectedFish, 
                selectedFish.tags.count > 0 || selectedFish.description.count > 0 {
                VStack {
                    if selectedFish.tags.count > 0 {
                        DetailTagView(fish: selectedFish)
                    }
                    if selectedFish.description.count > 0 {
                        DetailDescView(fish: selectedFish)
                    }
                }
            }
            if let selectedFish = self.selectedFish {
                ScrollView {
                    DetailValueView(fish: selectedFish)
                }
            }
            Spacer()
            if showDetail {
                Divider().background(Color.gray.opacity(0.2))
            }
            ArrowView()
                .rotationEffect(.degrees(180))
                .offset(y: showDetailWithAnima ? 0 : Constant.mainWidth*0.4)
                .onTapGesture {
                    withAnimation {
                        showDetailWithAnima = false
                    }
                    showDetail = false
                }
            if let selectedFish = self.selectedFish {
                DetailExtraInfoView(fish: selectedFish)
                    .frame(height: showDetailWithAnima ? Constant.mainHeight*0.3 : 0)
            }
            if !showDetail {
                ArrowView()
                    .onTapGesture {
                        withAnimation(.spring) {
                            showDetailWithAnima = true
                        }
                        showDetail = true
                    }
            }
        }
        .onTapGesture {
            withAnimation {
                isMultSelecting = false
            }
            multSelectedFishIdentitys.removeAll()
        }
    }
    
}

struct DetailTagView: View {
    
    var fish: Fish
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Array(fish.tags.enumerated()), id: \.0) { (idx, tg) in
                    Text(tg)
                        .frame(minWidth: 40)
                        .background(
                            GeometryReader { geometry in
                                Rectangle()
                                    .cornerRadius(10)
                                    .foregroundColor(String(Functions.getMD5(of: tg).suffix(6)).color)
                                    .frame(width: geometry.size.width+5, height: geometry.size.height+8)
                                    .offset(x: -2.5, y: -4)
                            }
                        )
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .frame(height: 20)
            .padding(3)
        }
        
    }
    
}
    
struct DetailDescView: View {
    
    var fish: Fish
    
    var body: some View {
        HStack {
            Text(fish.description)
                .font(.title3)
                .bold()
                .padding([.top, .horizontal], 3)
            Spacer()
        }
    }
    
}

struct DetailValueView: View {
    
    var fish: Fish
    
    var body: some View {
        switch fish.fishType {
        case .Text:
            VStack {
                if let textValue = fish.textData {
                    Text(textValue.prefix(Config.textFishDetailPreviewLength))
                        .font(.callout)
                    if textValue.count > Config.textFishDetailPreviewLength {
                        Text("...")
                            .font(.callout)
                            .bold()
                    }
                } else {
                    Text("No Preview (This may be dirty data)")
                        .font(.callout)
                        .bold()
                        .foregroundColor(.gray)
                }
            }
        case .Image:
            if let image = fish.imageData {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Text("No Preview (This may be dirty data)")
                    .font(.callout)
                    .bold()
                    .foregroundColor(.gray)
            }
        default:
            Text("Not Supported To Preview")
                .font(.callout)
                .bold()
                .foregroundColor(.gray)
        }
    }
    
}

struct DetailExtraInfoView: View {
    
    var fish: Fish
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                DetailItemView(itemName: "Type", itemValue: fish.fishType.rawValue)
                DetailItemView(itemName: "Repeats Number", itemValue: fish.count)
                DetailItemView(itemName: "Source Application", itemValue: fish.extraInfo.sourceAppName)
                switch fish.fishType {
                case .Text:
                    DetailItemView(itemName: "Char Count", itemValue: fish.dataInfo.charCount)
                    DetailItemView(itemName: "Word Count", itemValue: fish.dataInfo.wordCount)
                    DetailItemView(itemName: "Row Count", itemValue: fish.dataInfo.rowCount)
                case .Image:
                    DetailItemView(itemName: "Width", itemValue: fish.dataInfo.width)
                    DetailItemView(itemName: "Height", itemValue: fish.dataInfo.height)
                default:
                    EmptyView()
                }
                if let byteCount = fish.dataInfo.byteCount {
                    DetailItemView(itemName: "Size", itemValue: Functions.descByteCount(byteCount))
                }
                DetailItemView(itemName: "Create Time", itemValue: fish.createTime)
                DetailItemView(itemName: "Update Time", itemValue: fish.updateTime)
            }
            .padding(.vertical, 5)
        }
//        .frame(height: Config.mainHeight.get()*0.3)
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
            .frame(height: Constant.fishDetailItemHeight)
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
            .frame(width: Constant.mainWidth*0.15, height: 10)
            .background(Color.gray.opacity(0.01))
            .offset(y: isHovered ? 0 : 5)
            .onHover { isHovered in
                withAnimation {
                    self.isHovered = isHovered
                }
            }
    }
    
}

