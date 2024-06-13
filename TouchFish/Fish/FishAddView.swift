import SwiftUI

struct FishAddView: View {
    
    @State var toAddFiles: [URL:AddInfo] = [:]
    @State var selectedFile: URL = URL(filePath: "")
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                Picker("", selection: $selectedFile) {
                    let urls = Array(toAddFiles.keys).sorted {$0.path < $1.path}
                    ForEach(urls, id: \.self) { url in
                        Text(url.lastPathComponent)
                    }
                }
                .pickerStyle(.segmented)
            }
            if let addInfo = toAddFiles[selectedFile] {
                ScrollView(showsIndicators: false) {
                    AddInfoView(selectedFile: selectedFile, addInfo: addInfo)
                }
                .padding()
                HStack {
                    Spacer()
                    AddButtonView(addFileCount: toAddFiles.count) {
                        for (url, info) in toAddFiles {
                            if let data = FileManager.default.contents(atPath: url.path) {
                                if let type = FishType(rawValue: info.selectedType) {
                                    Task {
                                        let res = await Storage.addFish(
                                            value: data,
                                            description: info.description,
                                            type: type,
                                            tags: info.tags,
                                            extraInfo: ExtraInfo(sourceAppName: "TouchFish")
                                        )
                                        if res == .fail {
                                            Log.error("click button to add fish - fail to add a fish: storage.addFish returns fail, url=\(url.path)")
                                        }
                                        if res == .skip {
                                            Log.error("click button to add fish - skip to add a fish: storage.addFish returns skip, url=\(url.path)")
                                        }
                                    }
                                } else {
                                    Log.error("click button to add fish - skip a fish: parse type=nil, url=\(url.path), type=\(info.selectedType)")
                                }
                            } else {
                                Log.error("click button to add fish - skip a fish: got file data=nil, url=\(url.path)")
                            }
                        }
                        RecipeManager.goToRecipe(recipeId: nil)
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .onAppear {
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = true
            panel.canChooseDirectories = false
            panel.canChooseFiles = true
            Monitor.stop(type:.hideMainWindowWhenClickOutside)
            let res = panel.runModal()
            Monitor.start(type:.hideMainWindowWhenClickOutside)
            if res == .OK && panel.urls.count > 0 {
                let urls = panel.urls.sorted {$0.path < $1.path}
                for url in urls {
                    if let fileSize = Functions.getFileSize(atPath: url.path) {
                        if fileSize > Config.maxDataSizeAddFish.get() {
                            Log.warning("select file to add fish - skip a file: size out of limited, url=\(url.path), size=\(fileSize), limited=\(Config.maxDataSizeAddFish.get())")
                            continue
                        }
                        var addInfo = AddInfo(fileSize: Int(fileSize))
                        // todo: sub type management
                        var ext = url.pathExtension.lowercased()
                        if ext == "jpeg" {
                            ext = "jpg"
                        }
                        if let type = FishType(rawValue: ext) {
                            addInfo.selectedType = type.rawValue
                        }
                        addInfo.description = url.lastPathComponent
                        toAddFiles[url] = addInfo
                    } else {
                        Log.error("select file to add fish - skip a file: got size of the file failed, url=\(url.path)")
                        continue
                    }
                }
                selectedFile = urls[0]
            } else {
                RecipeManager.goToRecipe(recipeId: nil)
            }
        }

    }
    
}

struct AddButtonView: View {
        
    var addFileCount: Int
    @State private var isHovered = false
    
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Add \(addFileCount) File\(addFileCount == 1 ? "":"s")")
                .font(.title3)
                .bold()
                .foregroundColor(isHovered ? .black : .gray)
        }
        .onHover { isHovered in
            self.isHovered = isHovered
        }
    }
    
}


struct AddInfoView: View {
    
    var selectedFile: URL
    @ObservedObject var addInfo: AddInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 10) {
                Text("Data")
                    .font(.title2)
                    .bold()
                Text("\(selectedFile.path) (\(Functions.descByteCount(addInfo.fileSize)))")
                    .font(.title3)
            }
            HStack(spacing: 10) {
                Text("Type")
                    .font(.title2)
                    .bold()
                Picker("", selection: $addInfo.selectedType) {
                    ForEach(FishType.allCases, id: \.rawValue) { type in
                        Text(type.rawValue)
                    }
                }
                .frame(width: Config.mainWidth.get()*0.1)
                .pickerStyle(.menu)
            }
            HStack(spacing: 10) {
                Text("Tag")
                    .font(.title2)
                    .bold()
                AddTagGroupView(tags: $addInfo.tags)
            }
            
            ForEach(Array(addInfo.tags.enumerated()), id: \.0) { (idx, tagGroup) in
                HStack {
                    Text("Group\(idx+1)")
                        .font(.system(.body, design: .monospaced))
                        .bold()
                        .padding(.horizontal, 10)
                    ForEach(tagGroup, id: \.self) { tg in
                        TagView(label: tg, tags: $addInfo.tags[idx])
                    }
                    TagEditView(tags: $addInfo.tags[idx], allTags: $addInfo.tagsFlatten)
                }
            }
            
            Text("Description")
                .font(.title2)
                .bold()
                ZStack {
                    VStack {
                        Spacer()
                        TextEditor(text: $addInfo.description)
                            .font(.custom("Menlo", size: 16))
                        Spacer()
                    }
                }
                .background(Color.white)
                .cornerRadius(5)
                .frame(height: Config.mainWidth.get()*0.3)

        }
        .onAppear {
            addInfo.tagsFlatten = addInfo.tags.reduce(into: []) { (res, cur) in
                res.append(contentsOf: cur)
            }
        }
        .onChange(of: addInfo.tags) {
            addInfo.tagsFlatten = addInfo.tags.reduce(into: []) { (res, cur) in
                res.append(contentsOf: cur)
            }
        }
    }
    
}

class AddInfo: ObservableObject {
    @Published var description: String = ""
    @Published var tags: [[String]] = []
    @Published var tagsFlatten: [String] = []
    @Published var selectedType = "other"
    var fileSize: Int
    
    init(fileSize: Int) {
        self.fileSize = fileSize
    }
    
}
