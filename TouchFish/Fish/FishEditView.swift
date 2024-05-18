import SwiftUI

struct FishEditView: View {
    
    @Binding var isEditing: Bool
    
    var identity: String
    @State var description: String
    @State var tags: [[String]]
    
    @State var tagsFlatten: [String] = []
    
    @State var showSaveAlert = false
    @State var alertMessage = ""
    
    var body: some View {
        VStack {
            HStack {
                BackButtonView()
                    .onTapGesture {
                        isEditing = false
                    }
                Spacer()
                Text("Editing of \(identity)")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                SaveButtonView()
                    .onTapGesture {
                        Task {
                            let res = await Storage.modifyFish(
                                identity,
                                description: description,
                                tags: tags.filter {!$0.isEmpty}
                            )
                            switch res {
                            case .success:
                                isEditing = false
                            case .skip:
                                showSaveAlert = true
                                alertMessage = "save skipped"
                            case .fail:
                                showSaveAlert = true
                                alertMessage = "save failed"
                            }
                        }
                    }
                    .alert(isPresented: $showSaveAlert) {
                        Alert(
                            title: Text("modify fish"),
                            message: Text(alertMessage),
                            dismissButton: .default(Text("ok"))
                        )
                    }
            }
            Divider().background(Color.gray.opacity(0.2))
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 10) {
                        Text("Tag")
                            .font(.title2)
                            .bold()
                        AddTagGroupView(tags: $tags)
                    }
                    ForEach(Array(tags.enumerated()), id: \.0) { (idx, tagGroup) in
                        HStack {
                            Text("Group\(idx+1)")
                                .font(.system(.body, design: .monospaced))
                                .bold()
                                .padding(.horizontal, 10)
                            ForEach(tagGroup, id: \.self) { tg in
                                TagView(label: tg, tags: $tags[idx])
                            }
                            TagEditView(tags: $tags[idx], allTags: $tagsFlatten)
                        }
                    }
                    Text("Description")
                        .font(.title2)
                        .bold()
                    ZStack {
                        VStack {
                            Spacer()
                            TextEditor(text: $description)
                                .font(.custom("Menlo", size: 16))
                            Spacer()
                        }
                    }
                    .background(Color.white)
                    .cornerRadius(5)
                    .frame(height: Config.mainWidth*0.3)
                    
                }
            }
            .padding()
        }
        .onAppear() {
            tagsFlatten = tags.reduce(into: []) { (res, cur) in
                res.append(contentsOf: cur)
            }
        }
        .onChange(of: tags) {
            tagsFlatten = tags.reduce(into: []) { (res, cur) in
                res.append(contentsOf: cur)
            }
        }
    }
    
}

struct BackButtonView: View {
    
    @State private var isHovered = false
    
    var body: some View {
        Image(systemName: "arrow.backward.square")
        .resizable()
        .frame(width: 25, height: 25)
        .foregroundColor(isHovered ? .yellow : .gray)
        .onHover { isHovered in
            self.isHovered = isHovered
        }
    }
    
}

struct SaveButtonView: View {
    
    @State private var isHovered = false
    
    var body: some View {
        Image(systemName: "checkmark.square.fill")
        .resizable()
        .frame(width: 25, height: 25)
        .foregroundColor(isHovered ? .green : .gray)
        .onHover { isHovered in
            self.isHovered = isHovered
        }
    }
    
}

struct TagView: View {
    
    var label: String
    
    @State private var isHovered = false
    
    @Binding var tags: [String]
    
    var body: some View {
        Text(label)
            .frame(minWidth: 40)
            .background(
                GeometryReader { geometry in
                    Rectangle()
                        .cornerRadius(10)
                        .foregroundColor(String(Functions.getMD5(of: label).prefix(6)).color)
                        .frame(width: geometry.size.width+5, height: geometry.size.height+8)
                        .offset(x: -2.5, y: -4)
                }
            )
            .foregroundColor(.white)
            .strikethrough(isHovered, color: .red)
            .onHover { isHovered in
                self.isHovered = isHovered
            }
            .onTapGesture {
                tags.removeAll(where: { $0 == label } )
            }
    }
    
}

struct AddTagGroupView: View {
    
    @State private var isHovered = false
    
    @Binding var tags: [[String]]
    
    var body: some View {
        Image(systemName: "plus.circle")
        .resizable()
        .frame(width: 20, height: 20)
        .foregroundColor(isHovered ? Config.selectedItemBackgroundColor.color : .gray)
        .onHover { isHovered in
            self.isHovered = isHovered
        }
        .onTapGesture {
            withAnimation {
                tags.append([])
            }
        }
    }
}


struct TagEditView: View {
    
    @State private var isOpening = false
    
    @State private var isHovered1 = false
    @State private var isHovered2 = false
    @State private var isHovered3 = false
    
    @State private var tagSearchText = ""
    @State private var isShowTagPreview = false
    @State private var tagPreviewList: [String] = []
    
    @Binding var tags: [String]
    @Binding var allTags: [String]
    
    var body: some View {
        
        if !isOpening {
            Image(systemName: "plus.circle")
            .resizable()
            .frame(width: 20, height: 20)
            .foregroundColor(isHovered1 ? Config.selectedItemBackgroundColor.color : .gray)
            .onHover { isHovered in
                self.isHovered1 = isHovered
            }
            .onTapGesture {
                isOpening = true
            }
        } else {
            HStack {
                TextField("Search", text: $tagSearchText)
                .frame(width: 100, height: 20)
                .onChange(of: tagSearchText) {
                    let allTags = Array(Cache.tagCount.keys)
                    tagPreviewList = allTags.filter { tg in
                        return tg.lowercased().contains(tagSearchText.lowercased())
                    }
                    isShowTagPreview = !tagPreviewList.isEmpty
                }
                .popover(isPresented: $isShowTagPreview, arrowEdge: .bottom) {
                    VStack {
                        ForEach(tagPreviewList, id: \.self) { item in
                            TagPreviewView(label: item, tagSearchText: $tagSearchText)
                        }
                    }
                }
                Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(isHovered2 ? .green : .gray)
                .onHover { isHovered in
                    self.isHovered2 = isHovered
                }
                .onTapGesture {
                    if !allTags.contains(tagSearchText) {
                        tags.append(tagSearchText)
                    }
                    isOpening = false
                    tagSearchText = ""
                    tagPreviewList = []
                }
                Image(systemName: "xmark.circle.fill")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(isHovered3 ? .red : .gray)
                .onHover { isHovered in
                    self.isHovered3 = isHovered
                }
                .onTapGesture {
                    isOpening = false
                    tagSearchText = ""
                    tagPreviewList = []
                }
            }
        }
    }

}

struct TagPreviewView: View {
    
    var label: String
    
    @State private var isHovered = false
    
    @Binding var tagSearchText: String
    
    var body: some View {
        Text(label)
            .padding()
            .foregroundColor(isHovered ? .black : .gray)
//            .font(isHovered ? .custom("Menlo", size: 12) : .custom("Menlo", size: 10))
            .onHover { isHovered in
                self.isHovered = isHovered
            }
            .onTapGesture {
                tagSearchText = label
            }
    }
    
}

