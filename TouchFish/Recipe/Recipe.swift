import SwiftUI

struct Recipe {
    var bundleId: String
    var author: String
    var version: Int
    var name: String
    var commandCellName: String
    var description: String?
    var icon: Image
    var command: String?
    var arguments: [RecipeScript.Argument] = []
    var script: RecipeScript.Script?
    var menuListItemColor: Color
    var order: Int
    
    func execute() -> RecipeExecuteResult {
        guard let script = script else {
            return RecipeExecuteResult(errorMessage: "Not Executable")
        }
        // todo: use resource
        let scriptPath = TouchFishApp.previewPath.appendingPathComponent(script.identity)
        if !FileManager.default.fileExists(atPath: scriptPath.path) {
            Log.warning("")
            return RecipeExecuteResult(errorMessage: "Script Resource Not Found")
        }
        var argments: [String] = []
        argments.append(scriptPath.path)
        // todo: host and port
        argments.append(CommandManager.commandText)
        argments.append(contentsOf: RecipeManager.activeRecipeOrderedValue)
        let startTime = Date()
//        let executeResultText = Functions.runCommand(cmd: script.executor, args: argments)
        let executeResultText = AppleScriptRunner.doShellScript(cmd: script.executor, args: argments)
        let endTime = Date()
        let timeCost = Int(endTime.timeIntervalSince(startTime)*1000)
        guard let executeResultText = executeResultText else {
            return RecipeExecuteResult(errorMessage: "Execute Failed", timeCost: timeCost)
        }
        var ret = RecipeExecuteResult.parseResultText(executeResultText: executeResultText)
        ret.timeCost = timeCost
        return ret
    }
    
}

struct RecipeScript: Codable {
    
    var bundleId: String
    var author: String
    var version: Int
    var name: String
    var commandCellName: String?
    var description: String?
    var icon: String? // system:xxx fish:xxx
    var command: String?
    var arguments: [Argument]?
    var script: Script?
    var menuListItemColor: String?
    var order: Int?
    
    struct Argument: Codable {
        var name: String
        var separator: String?
    }

    struct Script: Codable {
        var identity: String
        var executor: String
    }
    
    static func parseRecipe(recipeScriptText: String) -> Recipe? {
        guard let recipeScriptData = recipeScriptText.data(using: .utf8) else {
            Log.error("parse recipt script - fail: get script data error ")
            return nil
        }
        guard let recipeScript = try? JSONDecoder().decode(RecipeScript.self, from: recipeScriptData) else {
            Log.error("parse recipt script - fail: json decode error")
            Log.verbose(recipeScriptText)
            return nil
        }
        return Recipe(
            bundleId: recipeScript.bundleId,
            author: recipeScript.author,
            version: recipeScript.version,
            name: recipeScript.name,
            commandCellName: recipeScript.commandCellName ?? recipeScript.name,
            description: recipeScript.description,
            icon: recipeScript.icon?.icon ?? Image(systemName: "frying.pan"),
            command: recipeScript.command,
            arguments: recipeScript.arguments ?? [],
            script: recipeScript.script,
            menuListItemColor: (recipeScript.menuListItemColor ?? Config.userDefinedRecipeDefaultIemColor).color,
            order: recipeScript.order ?? 0
        )
    }
    
}

struct RecipeExecuteResult: Codable {
    
    var errorMessage: String?
    var timeCost: Int?
    
    enum resultType: String, Codable {
        case none
        case text
        case list
    }
    
    enum actionType: String, Codable {
        case back
        case hide
        case copy
        case open
        case script
    }
    
    struct resultItem: Codable {
        var title: String
        var description: String?
        var icon: String?
        var tags: [String]?
        var parameters: [[String]]?
        var action: [actionType]?
        
        func getParameter(_ actionIndex: Int) -> [String]? {
            guard let parameters = parameters else {
                return nil
            }
            if parameters.count < actionIndex {
                return nil
            }
            return parameters[actionIndex]
        }
        
    }
    
    var type: resultType?
    var items: [resultItem] = []
    
    static func parseResultText(executeResultText: String) -> RecipeExecuteResult {
        if executeResultText.count == 0 {
            return RecipeExecuteResult(type: RecipeExecuteResult.resultType.none)
        }
        guard let executeResultData = executeResultText.data(using: .utf8) else {
            Log.error("parse recipt result - fail: got result text data = nil ")
            return RecipeExecuteResult(errorMessage: "Execute Result Decoded Error")
        }
        guard let result = try? JSONDecoder().decode(RecipeExecuteResult.self, from: executeResultData) else {
            Log.error("parse recipt result - fail: json decoded error")
            Log.verbose(executeResultText)
            return RecipeExecuteResult(errorMessage: "Execute Result Decoded Error")
        }
        return result
    }
}

struct RecipeManager {
    
    static var recipes: [String:Recipe] = [:]
    
    static func refresh() async {
        recipes.removeAll()
        for recipe in internalRecipeList {
            recipes[recipe.bundleId] = recipe
        }
        let res = await Storage.searchFish(tags:[["Recipe"]])
        if let recipeFishList = res {
            for recipeFish in recipeFishList {
                // todo: user resource
                guard let recipeScriptText = Storage.getTextPreviewByIdentity(recipeFish.identity) else {
                    Log.warning("load recipe from fish - skip a recipe: Storage.getTextPreviewByIdentity return nil, fish.identity=\(recipeFish.identity)")
                    continue
                }
                guard let recipe = RecipeScript.parseRecipe(recipeScriptText: recipeScriptText) else {
                    Log.warning("load recipe from fish - skip a recipe: RecipeScript.parseRecipe return nil, fish.identity=\(recipeFish.identity)")
                    continue
                }
                if internalRecipeList.map({$0.bundleId}).contains(recipe.bundleId) {
                    Log.warning("load recipe from fish - skip a recipe: bundledId conflicts with internal recipes, bundleId=\(recipe.bundleId), fish.identity=\(recipeFish.identity)")
                    continue
                }
                if let existsRecipe = recipes[recipe.bundleId] {
                    if existsRecipe.version == recipe.version {
                        Log.warning("load recipe from fish - randomly select version: duplicate version number, bundleId=\(recipe.bundleId), fish.identity=\(recipeFish.identity)")
                    }
                    if existsRecipe.version < recipe.version {
                        recipes[recipe.bundleId] = recipe
                    }
                } else {
                    recipes[recipe.bundleId] = recipe
                }
            }
        } else {
            Log.warning("load recipe from fish - fail: storage.searchFish return nil")
        }
    }
    
    static var orderedRecipeList: [Recipe] {
        return recipes.values.sorted(by: {
            if $0.order == $1.order {
                return $0.bundleId < $1.bundleId
            }
            return $0.order < $1.order
        })
    }
    
    static private var activeRecipeId: String? = nil
    static private var activeRecipeArguments: [String:String] = [:]
    static private var activeRecipeArgumentsAddOrder: [String] = []
    
    static var activeRecipe: Recipe? {
        guard let activeRecipeId = activeRecipeId else {
            return nil
        }
        return recipes[activeRecipeId]
    }
    
    static var activeRecipeArg: [String:[String]] {
        var ret: [String:[String]] = [:]
        guard let args = activeRecipe?.arguments else {
            return ret
        }
        for arg in args {
            if let value = activeRecipeArguments[arg.name] {
                if let separator = arg.separator {
                    ret[arg.name] = value.split(separator: separator).map{ String($0) }
                } else {
                    ret[arg.name] = [value]
                }
            }
        }
        return ret
    }
    
    static var activeRecipeAddOrderArg: [(String, String)] {
        var ret: [(String, String)] = []
        for k in activeRecipeArgumentsAddOrder {
            if let v = activeRecipeArguments[k] {
                ret.append((k, v))
            }
        }
        return ret
    }
    
    static var activeRecipeOrderedValue: [String] {
        if let activeRecipe = activeRecipe {
            return activeRecipe.arguments.map {activeRecipeArguments[$0.name, default: ""] }
        }
        return []
    }
 
    static func goToRecipe(recipeId: String?) {
        activeRecipeId = recipeId
        activeRecipeArguments.removeAll()
        activeRecipeArgumentsAddOrder.removeAll()
        NotificationCenter.default.post(name: .RecipeStatusChanged, object: nil)
    }
    
    static func addArg(key: String, value: String) {
        if let validArgs = activeRecipe?.arguments.map({$0.name}),
           validArgs.contains(key),
           !activeRecipeArguments.keys.contains(key) {
            activeRecipeArguments[key] = value
            activeRecipeArgumentsAddOrder.append(key)
            NotificationCenter.default.post(name: .RecipeStatusChanged, object: nil)
        }
    }
    
    static func delArg(key: String) {
        activeRecipeArguments.removeValue(forKey: key)
        activeRecipeArgumentsAddOrder.removeAll {$0 == key}
        NotificationCenter.default.post(name: .RecipeStatusChanged, object: nil)
    }
    
    static func delLastArg() {
        if let lastKey = activeRecipeArgumentsAddOrder.last {
            activeRecipeArguments.removeValue(forKey: lastKey)
            activeRecipeArgumentsAddOrder.removeLast()
            NotificationCenter.default.post(name: .RecipeStatusChanged, object: nil)
        }
    }
    
    static private var internalRecipeList = [
        Recipe(
            bundleId: "com.touchfish.FishRepository",
            author: "yzjsswk",
            version: 0,
            name: "Fish Repository",
            commandCellName: "Fish Repository",
            description: "master your information",
            icon: Image(systemName: "fish"),
            command: "fish",
            arguments: [
                RecipeScript.Argument(name: "type", separator: ","),
                RecipeScript.Argument(name: "tag", separator: ","),
                RecipeScript.Argument(name: "marked"),
                RecipeScript.Argument(name: "locked"),
                RecipeScript.Argument(name: "sort")
            ],
            menuListItemColor: Config.internalRecipeItemColor.color,
            order: -600
        ),
        Recipe(
            bundleId: "com.touchfish.AddFish",
            author: "yzjsswk",
            version: 0,
            name: "Add Fish",
            commandCellName: "Add Fish",
            icon: Image(systemName: "plus.square"),
            command: "add",
            menuListItemColor: Config.internalRecipeItemColor.color,
            order: -500
        ),
        Recipe(
            bundleId: "com.touchfish.Setting",
            author: "yzjsswk",
            version: 0,
            name: "Setting",
            commandCellName: "Setting",
            icon: Image(systemName: "gearshape"),
            command: "set",
            menuListItemColor: Config.internalRecipeItemColor.color,
            order: -400
        ),
        Recipe(
            bundleId: "com.touchfish.MessageCenter",
            author: "yzjsswk",
            version: 0,
            name: "Message Center",
            commandCellName: "Message Center",
            icon: Image(systemName: "ellipsis.message"),
            command: "msg",
            menuListItemColor: Config.internalRecipeItemColor.color,
            order: -300
        ),
        Recipe(
            bundleId: "com.touchfish.Statistics",
            author: "yzjsswk",
            version: 0,
            name: "Statistics",
            commandCellName: "Statistics",
            icon: Image(systemName: "chart.line.uptrend.xyaxis.circle.fill"),
            command: "stats",
            menuListItemColor: Config.internalRecipeItemColor.color,
            order: -200
        ),
        Recipe(
            bundleId: "com.touchfish.RecipeStore",
            author: "yzjsswk",
            version: 0,
            name: "Recipe Store",
            commandCellName: "Recipe Store",
            icon: Image(systemName: "books.vertical"),
            command: "store",
            menuListItemColor: Config.internalRecipeItemColor.color,
            order: -100
        ),

//        Recipe(
//            id: 5,
//            name: "Web BookMark",
//            commandCellName: "Web BookMark",
//            icon: Image(systemName: "globe"),
//            command: "bm"
//        )
    ]
    
}

