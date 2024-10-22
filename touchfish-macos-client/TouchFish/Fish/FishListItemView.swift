import SwiftUI

struct FishListItemView: View {
    
    var fish: Fish
    @Binding var selectedFishIdentity: String?
    @Binding var hoveringFishIdentity: String?
    
    @Binding var isEditing: Bool
    @Binding var isMultSelecting: Bool
    @Binding var multSelectedFishIdentitys: Set<String>
    
    @State var showCopyed: Bool = false
    
    var isSelected: Bool {
        selectedFishIdentity == fish.identity
    }
    
    var isHovering: Bool {
        !isMultSelecting && hoveringFishIdentity == fish.identity
    }
    
    var body: some View {
        HStack() {
            HStack {
                if isMultSelecting {
                    if multSelectedFishIdentitys.contains(fish.identity) {
                        Image(systemName: "checkmark.square")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(isSelected ? Color.white: Color.black)
                    } else {
                        Image(systemName: "square")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(isSelected ? Color.white: Color.black)
                    }
                } else {
                    fish.fishIcon
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(isSelected ? Color.white: fish.fishIconColor)
                }
            }
            .frame(width: Constant.fishItemIconWidth)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if fish.isMarked {
                        Text(fish.linePreview)
                            .font(.title3)
                            .foregroundColor(isSelected ? Color.white: Color.black)
                    } else {
                        Text(fish.linePreview)
                            .font(.title3)
                            .foregroundColor(isSelected ? Color.white: Color.gray)
                    }
                    Spacer()
                }
                if isHovering {
                    HStack(spacing: 3) {
                        Text(fish.identity)
                            .font(.caption)
                            .foregroundColor(.gray)
                            CopyButtonView()
                            .onTapGesture {
                                if let data = fish.identity.data(using: .utf8) {
                                    Functions.copyDataToClipboard(data: data, type: .Text)
                                } else {
                                    Log.warning("copy fish identity to clipboard: fail - fish.identity.data return nil, fish.identity=\(fish.identity)")
                                }
                            }
                        Spacer()
                        // todo: icon move anima when lock
                        if fish.isLocked {
                            UnLockButtonView()
                                .onTapGesture {
                                    Task {
                                        await Storage.unLockFish(fish.identity)
                                    }
                                }
                        } else {
                            LockButtonView()
                                .onTapGesture {
                                    Task {
                                        await Storage.lockFish(fish.identity)
                                    }
                                }
                            EditButtonView()
                                .onTapGesture {
                                    isEditing = true
                                }
                            if fish.isMarked {
                                UnMarkButtonView()
                                    .onTapGesture {
                                        Task {
                                            await Storage.unMarkFish(fish.identity)
                                        }
                                    }
                            } else {
                                MarkButtonView()
                                    .onTapGesture {
                                        Task {
                                            await Storage.markFish(fish.identity)
                                        }
                                    }
                            }
                            DeleteButtonView()
                                .onTapGesture {
                                    Task {
                                        await Storage.removeFish(fish.identity)
                                    }
                                }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: Constant.mainWidth)
        .padding(5)
        .background(isSelected ? Constant.selectedItemBackgroundColor.color : Constant.mainBackgroundColor.color)
//        .shadow(color: Color.gray.opacity(0.3), radius: 2, x: 0, y: 2)
        .cornerRadius(5)
        .frame(width: (Constant.mainWidth-30)/2, height: isHovering ? Constant.fishItemHeight+20 : Constant.fishItemHeight)
        .popover(isPresented: $showCopyed, arrowEdge: .trailing) {
            Text("Copyed")
                .padding(10)
        }
        .onHover { isHovered in
            if !isHovered {
                showCopyed = false
            }
        }
        .onTapGesture {
            if isMultSelecting {
                if multSelectedFishIdentitys.contains(fish.identity) {
                    multSelectedFishIdentitys.remove(fish.identity)
                } else {
                    multSelectedFishIdentitys.insert(fish.identity)
                }
            } else {
                fish.copyToClipboard()
                if Config.fastPasteToFrontmostApplication {
                    TouchFishApp.deactivate()
                    pasteToFrontmostApp()
                } else {
                    showCopyed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showCopyed = false
                    }
                }

            }
        }
        .onLongPressGesture(minimumDuration: 1.0) { isPressing in
//            if isPressing {
//                print("Pressing...")
//            }
        } perform: {
            withAnimation {
                isMultSelecting = true
            }
            multSelectedFishIdentitys.insert(fish.identity)
        }

    }
}

struct CopyButtonView: View {
    
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            Image(systemName: isHovered ? "list.clipboard.fill" : "list.clipboard")
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.white)
                .onHover { isHovered in
                    self.isHovered = isHovered
                }
        }
        .frame(width: 20, height: 20)
    }
}

struct EditButtonView: View {
    
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            Image(systemName: "square.and.pencil")
                .resizable()
                .scaledToFit()
                .foregroundColor(isHovered ? .brown : .brown)
                .onHover { isHovered in
                    self.isHovered = isHovered
                }
        }
        .frame(width: 20, height: 20)
    }
    
}

struct LockButtonView: View {
    
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            Image(systemName: "lock")
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.yellow)
                .onHover { isHovered in
                    self.isHovered = isHovered
                }
        }
        .frame(width: 25, height: 20)
    }
}

struct UnLockButtonView: View {
    
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            Image(systemName: "lock.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.yellow)
                .onHover { isHovered in
                    self.isHovered = isHovered
                }
        }
        .frame(width: 25, height: 20)
    }
}

struct MarkButtonView: View {
    
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            Image(systemName: "bookmark")
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.orange)
                .onHover { isHovered in
                    self.isHovered = isHovered
                }
        }
        .frame(width: 20, height: 20)
        .offset(y:1)
    }
}

struct UnMarkButtonView: View {
    
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            Image(systemName: "bookmark.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(Color.orange)
                .onHover { isHovered in
                    self.isHovered = isHovered
                }
        }
        .frame(width: 20, height: 20)
        .offset(y:1)
    }
}

struct DeleteButtonView: View {
    
    @State private var isHovered = false
    
    var body: some View {
        HStack {
            Image(systemName: "trash.fill")
                .resizable()
                .scaledToFit()
                .foregroundColor(isHovered ? .red : .gray)
                .onHover { isHovered in
                    self.isHovered = isHovered
                }
        }
        .frame(width: 20, height: 20)
    }
}


func pasteToFrontmostApp() {
    // 模拟粘贴操作 alfred运行时会失效
    if let frontApp = NSWorkspace.shared.frontmostApplication {
        frontApp.activate(options: .activateIgnoringOtherApps)
//        let keyEvent = CGEvent(keyboardEventSource: nil, virtualKey: 9, keyDown: true)
//        keyEvent?.flags = [.maskCommand]
//        Log.debug("do copy")
//        keyEvent?.post(tap: .cghidEventTap)
        Log.debug("paste fish to frontmost app")
        AppleScriptRunner.doPaste()
    } else {
        Log.warning("paste fish to frontmost app - failed: got frontApp=nil")
    }
}
