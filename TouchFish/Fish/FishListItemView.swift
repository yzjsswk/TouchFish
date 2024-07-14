import SwiftUI

struct FishListItemView: View {
    
    var fish: Fish
    
    @Binding var isEditing: Bool
    @Binding var selectedFishIdentity: String?
    @Binding var hoveringFishIdentity: String?
    
    var isSelected: Bool {
        selectedFishIdentity == fish.identity
    }
    
    var isHovering: Bool {
        hoveringFishIdentity == fish.identity
    }
    
    var body: some View {
        HStack() {
            HStack {
                fish.fishIcon
                .resizable()
                .scaledToFit()
                .foregroundColor(isSelected ? Color.white: fish.fishIconColor)
            }
            .frame(width: Constant.fishItemIconWidth)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    if fish.isMarked {
                        Text(fish.linePreview)
                            .font(.title2)
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
                                    Functions.copyDataToClipboard(data: data, type: .txt)
                                } else {
                                    Log.warning("copy fish identity to clipboard: fail - fish.identity.data return nil, fish.identity=\(fish.identity), fish.id=\(fish.id)")
                                }
                            }
                        Spacer()
                        // todo: icon move anima when lock
                        if fish.isLocked {
                            UnLockButtonView()
                                .onTapGesture {
                                    Task {
                                        let res = await Storage.unLockFish(fish.identity)
                                        if res == .fail {
                                            Log.error("click button to unlock fish - fail: storage.unLockFish return fail, identity = \(fish.identity)")
                                        }
                                    }
                                }
                        } else {
                            LockButtonView()
                                .onTapGesture {
                                    Task {
                                        let res = await Storage.lockFish(fish.identity)
                                        if res == .fail {
                                            Log.error("click button to mark fish - fail: storage.lockFish return fail, identity = \(fish.identity)")
                                        }
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
                                            let res = await Storage.unMarkFish(fish.identity)
                                            if res == .fail {
                                                Log.error("click button to unmark fish - fail: storage.unMarkFish return fail, identity = \(fish.identity)")
                                            }
                                        }
                                    }
                            } else {
                                MarkButtonView()
                                    .onTapGesture {
                                        Task {
                                            let res = await Storage.markFish(fish.identity)
                                            if res == .fail {
                                                Log.error("click button to mark fish - fail: storage.markFish return fail, identity = \(fish.identity)")
                                            }
                                        }
                                    }
                            }
                            DeleteButtonView()
                                .onTapGesture {
                                    Task {
                                        let res = await Storage.removeFish(fish.identity)
                                        if res == .fail {
                                            Log.error("click button to delete fish - fail: Storage.removeFish return fail, identity=\(fish.identity)")
                                        }
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
        .onTapGesture(count: 1) {
            fish.copyToClipboard()
            TouchFishApp.deactivate()
            pasteToFrontmostApp()
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
        AppleScriptRunner.doPaste()
    } else {
        Log.warning("front app is nil")
    }
}
