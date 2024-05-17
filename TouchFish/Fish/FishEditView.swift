import SwiftUI

struct FishEditView: View {
    
    @Binding var isEditing: Bool
    
    var identity: String
    @State var description: String
    @State var tags: [[String]]
    
    @State var descriptionAreaHeight: Int = 100
    
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
                SaveButtonView()
                    .onTapGesture {
                        Task {
                            let res = await Storage.modifyFish(identity, description: description, tags: tags)
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
                    
//                    HStack(spacing: 10) {
//                        Text("tag")
//                            .font(.title2)
//                            .bold()
//                        TagEditView(tags: $tags[0])
//                    }
//                    LazyVGrid(columns: [
//                        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()),
//                        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
//                    ], spacing: 16) {
//                        ForEach(tags[0], id: \.self) { tg in
//                            TagView(label: tg, tags: $tags[0])
//                        }
//                    }
                        
                        
                    Text("description")
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
                    .frame(height: 100)

                }
            }
            .frame(width: Config.mainWidth - 30)
            .padding(5)
        }
        .onChange(of: description) {
            descriptionAreaHeight = min(100, description.count / 30)
        }
    }
    
}

struct BackButtonView: View {
    
    @State private var isHovered = false
    
    var body: some View {
        Image(systemName: "arrow.backward.square")
        .resizable()
        .frame(width: 25, height: 25)
        .foregroundColor(isHovered ? Config.selectedItemBackgroundColor.color : .gray)
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
        ZStack {
            Rectangle()
                .fill(String(Functions.getMD5(of: label).prefix(6)).color)
            .overlay(
                Text(label)
                .foregroundColor(.white)
            )
            .frame(width: 100, height: 25)
            .cornerRadius(10)
            
            if isHovered {
                Image(systemName: "xmark.circle.fill")
                .resizable()
                .frame(width: 15, height: 15)
                .offset(x: 40)
                .foregroundColor(.orange)
                .onTapGesture {
                    tags.removeAll(where: { $0 == label } )
                }
            }
        }
        .onHover { isHovered in
            withAnimation {
                self.isHovered = isHovered
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
                    if !tags.contains(tagSearchText) {
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

