import SwiftUI

enum SettingViewTab: CaseIterable {
    
    case basic
    case dataService
    
    var tabName: String {
        switch self {
        case .basic: 
            return "Basic"
        case .dataService: 
            return "Data Service"
        }
    }
    
}

struct SettingView: View {
    
    @State var selectedTab: SettingViewTab = .basic
    
    @State var language: String = Config.language.get().rawValue
    @State var dataServiceConfigs: [String:Configuration.DataServiceConfiguration] = Config.dataServiceConfigs.get()
    @State var enableDataServiceConfigName: String = Config.enableDataServiceConfigName.get()
    
    @State var saveMessage = ""
    
    var body: some View {
        VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                Picker("", selection: $selectedTab) {
                    ForEach(SettingViewTab.allCases, id:\.self) { tab in
                        Text(tab.tabName)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: Config.mainWidth.get()-30)
            }
            ScrollView(showsIndicators: false) {
                switch selectedTab {
                case .basic:
                    VStack(alignment: .leading, spacing: 40) {
                        Picker("Language", selection: $language) {
                            ForEach(Configuration.TFLanguage.allCases, id:\.rawValue) { lan in
                                Text(lan.rawValue)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 200)
                        HStack {
                            Text("Call Application KeyBoard ShortCut")
                            ZStack {
                                Config.commandBarBackgroundColor.get().color
                                HStack(spacing: 2) {
                                    Image(systemName: "option")
                                    Image(systemName: "space")
                                }
                            }
                            .frame(width: 50)
                            .padding(.horizontal, 5)
                        }
                        HStack {
                            Text("Call Fish Respository KeyBoard ShortCut")
                            ZStack {
                                Config.commandBarBackgroundColor.get().color
                                HStack(spacing: 2) {
                                    Image(systemName: "command")
                                    Image(systemName: "option")
                                    Image(systemName: "v.square")
                                }
                            }
                            .frame(width: 50)
                            .padding(.horizontal, 5)
                        }
                    }
                    .padding()
                case .dataService:
                    DataServiceSettingView(dataServiceConfigs: $dataServiceConfigs, enableDataServiceConfigName: $enableDataServiceConfigName)
                }
            }
            HStack {
                Button(action: {
                    // todo
                }) {
                    Text("Save To Fish Repository")
                }
                .frame(width: 200)
                Spacer()
                Button(action: {
                    Config.dataServiceConfigs.set(value: dataServiceConfigs)
                    Config.enableDataServiceConfigName.set(value: enableDataServiceConfigName)
                    let ok = Config.save()
                    if ok {
                        saveMessage = "success"
                    } else {
                        saveMessage = "save failed"
                    }
                }) {
                    Text("Apply")
                }
                .frame(width: 100)
                Text(saveMessage)
            }
            .frame(width: Config.mainWidth.get()*0.6)
            .padding(5)
        }
    }
    
}


