import SwiftUI
import Foundation

struct MainView: View {
    
    @State private var commandText = ""
    @State private var commandCell: [String] = []
    @State private var viewState = 0
    @State private var fishList: [Fish] = []
    
    var body: some View {
        ZStack {
            Config.mainBackgroundColor.color
            VStack {
                CommandBarView(commandText: $commandText, commandCell: $commandCell)
                switch viewState {
                case 1:
                    FishRepositoryView(fishList: fishList)
                case 2:
                    WebBrowserView(text: $commandText)
                default:
                    ProcessView(processList: CommandManager.exec(prompt: commandText))
                }
                Spacer()
            }
        }
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black.opacity(0.1), lineWidth: 1))
        .onAppear {
            fishList = Storage.getFishOfSearchCondition()
        }
        .onChange(of: commandText) {
            if viewState == 0 && commandText.starts(with: "bm ") {
                viewState = 2
            }
            if viewState == 2 && !commandText.starts(with: "bm ") {
                viewState = 0
            }
            if viewState == 1 {
                Cache.fuzzys = commandText
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .ShouldSwitchProcess)) { notification in
            guard let userInfo = notification.userInfo else {
                return
            }
            if let target = userInfo["target"] as? String {
                commandCell.append(target)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .ShouldShowFishView)) { _ in
            viewState = 1
        }
        .onReceive(NotificationCenter.default.publisher(for: .EscapeKeyWasPressed)) { _ in
            viewState = 0
        }
        .onReceive(NotificationCenter.default.publisher(for: .ShouldRefreshFishList)) { _ in
            withAnimation {
                fishList = Storage.getFishOfSearchCondition()
            }
        }
    }
    
}
