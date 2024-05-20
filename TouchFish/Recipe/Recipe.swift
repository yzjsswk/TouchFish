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
    var arguments: [RecipeArgument] = []
    var order: Int
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
    var arguments: [RecipeArgument]?
    var order: Int?
    
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
        var icon: Image = Image(systemName: "frying.pan")
        if let recipeIcon = recipeScript.icon {
            if recipeIcon.hasPrefix("system:") {
                let systemIconName = String(recipeIcon.dropFirst(7))
                icon = Image(systemName: systemIconName)
            }
            if recipeIcon.hasPrefix("fish:") {
                let fishIdentity = String(recipeIcon.dropFirst(5))
                if let fishImage = Storage.getImagePreviewByIdentity(fishIdentity) {
                    icon = Image(nsImage: fishImage)
                }
            }
        }
        return Recipe(
            bundleId: recipeScript.bundleId,
            author: recipeScript.author,
            version: recipeScript.version,
            name: recipeScript.name,
            commandCellName: recipeScript.commandCellName ?? recipeScript.name,
            description: recipeScript.description,
            icon: icon,
            command: recipeScript.command,
            arguments: recipeScript.arguments ?? [],
            order: recipeScript.order ?? 0
        )
    }
    
}

struct RecipeArgument: Codable {
    var name: String
    var separator: String?
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
    static private var activeRecipeArgumentsOrder: [String] = []
    
    
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
    
    static var activeRecipeOrderedArg: [(String, String)] {
        var ret: [(String, String)] = []
        for k in activeRecipeArgumentsOrder {
            if let v = activeRecipeArguments[k] {
                ret.append((k, v))
            }
        }
        return ret
    }
 
    static func goToRecipe(recipeId: String?) {
        activeRecipeId = recipeId
        activeRecipeArguments.removeAll()
        activeRecipeArgumentsOrder.removeAll()
        NotificationCenter.default.post(name: .RecipeStatusChanged, object: nil)
    }
    
    static func addArg(key: String, value: String) {
        if let validArgs = activeRecipe?.arguments.map({$0.name}),
           validArgs.contains(key),
           !activeRecipeArguments.keys.contains(key) {
            activeRecipeArguments[key] = value
            activeRecipeArgumentsOrder.append(key)
            NotificationCenter.default.post(name: .RecipeStatusChanged, object: nil)
        }
    }
    
    static func delArg(key: String) {
        activeRecipeArguments.removeValue(forKey: key)
        activeRecipeArgumentsOrder.removeAll {$0 == key}
        NotificationCenter.default.post(name: .RecipeStatusChanged, object: nil)
    }
    
    static func delLastArg() {
        if let lastKey = activeRecipeArgumentsOrder.last {
            activeRecipeArguments.removeValue(forKey: lastKey)
            activeRecipeArgumentsOrder.removeLast()
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
                RecipeArgument(name: "type", separator: ","),
                RecipeArgument(name: "tag", separator: ","),
                RecipeArgument(name: "marked"),
                RecipeArgument(name: "locked"),
                RecipeArgument(name: "sort")
            ],
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

