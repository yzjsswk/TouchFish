import SwiftyBeaver
import AppKit

let Log = TFLogger.logger

struct TFLogger {
    
    static let logger = SwiftyBeaver.self
    static let consoleDst = ConsoleDestination()
    static let fileDst = FileDestination()
    
    static func prepare() {
        consoleDst.minLevel = .verbose
        fileDst.minLevel = .verbose
        updateLogFile()
        SwiftyBeaver.addDestination(consoleDst)
        SwiftyBeaver.addDestination(fileDst)
    }
    
    static func updateLogFile() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let currentDate = Date()
        let logFileName = dateFormatter.string(from: currentDate) + ".log"
        fileDst.logFileURL = TouchFishApp.logPath.appendingPathComponent(logFileName)
    }
    
}
