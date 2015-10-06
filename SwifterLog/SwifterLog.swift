// =====================================================================================================================
//
//  File:       SwifterLog.swift
//  Project:    SwifterLog
//
//  Version:    0.9.3
//
//  Author:     Marinus van der Lugt
//  Website:    http://www.balancingrock.nl/swifterlog
//
//  Copyright:  (c) 2014, 2015 Marinus van der Lugt, All rights reserved.
//
//  License:    Use or redistribute this code any way you like with the following two provision:
//
//  1) You ACCEPT this source code AS IS without any guarantees that it will work as intended. Any liability from its
//  use is YOURS.
//
//  2) You WILL NOT seek damages from the author or balancingrock.nl.
//
//  I also ask you to please leave this header with the source code.
//
//  I strongly believe that NAP is the way for societies to function optimally. I thus reject the implicit use of force
//  to extract payment. Since I cannot negotiate with you about the price of this code, I have choosen to leave it up to
//  you to determine its price. You pay me whatever you think this code is worth to you.
//
//   - You can send payment via paypal to: sales@balancingrock.nl
//   - Or wire bitcoins to: 1GacSREBxPy1yskLMc9de2nofNv2SNdwqH
//
//  I prefer the above two, but if these options don't suit you, you might also send me a gift from my amazon.co.uk
//  whishlist: http://www.amazon.co.uk/gp/registry/wishlist/34GNMPZKAQ0OO/ref=cm_sw_em_r_wsl_cE3Tub013CKN6_wb
//
//  If you like to pay in another way, please contact me at rien@balancingrock.nl
//
//  (It is always a good idea to visit the website/google to ensure that you actually pay me and not some imposter)
//
//  For private and non-profit use the suggested price is the price of 1 good cup of coffee, say $4.
//  For commercial use the suggested price is the price of 1 good meal, say $20.
//
//  You are however encouraged to pay more ;-)
//
//  Prices/Quotes for support, modifications or enhancements can be obtained from: rien@balancingrock.nl
//
// =====================================================================================================================
//
// This file needs two assist files:
// 
// asl-bridge.h which should contain:
// ----------------------------------
//
// #import <Foundation/Foundation.h>
//
// #ifndef SwiftFire_asl_bridge_h
// #define SwiftFire_asl_bridge_h
//
// int asl_bridge_log_message(int level, NSString *message);
//
// #endif
//
//
// And the corresponding asl-bridge.m which should contain:
// --------------------------------------------------------
//
// #import <Foundation/Foundation.h>
//
// #import <asl.h>
// #import "asl-bridge.h"
//
// int asl_bridge_log_message(int level, NSString *message) {
//     return asl_log_message(level, "%s", [message cStringUsingEncoding:NSUTF8StringEncoding]);
// }
//
//
// It also needs the following two lines in your <<<app-name>>-Bridging-Header.h:
// ------------------------------------------------------------------------------
//
// #import <asl.h>
// #import "asl-bridge.h"
//
// =====================================================================================================================
//
// Quick start:
//
// 1) Make sure that you have the above described two files (create them if necessary) and the updates for the bridge.
//
// 2) Add all 3 files to your project.
//
// 3) Make sure there is no global variable called "log" in your project, except for the one in this file.
//
// 4) You can now add logging statements, just type "log." and the auto-completion in xcode will start suggesting the
//    operations you need to log and configure this utility.
//    Typicalle you would write something like:
//
//    log.atLevelError(id: anyInt32, source: "MyClass.myOperation", message: "an error occured")
//
// Note: The id is intended to identify an object, the source to identify a class/operation. But these are only
// suggestions.
//
// Configuration for ASL:
//     aslFacilityRecordAtAndAboveLevel - Threshold for recording.
//
// Configuration for STDOUT - i.e. println():
//     stdoutPrintAtAndAboveLevel       - Threshold for printing.
//
// Configuration for a logfile:
//    logfileRecordAtAndAboveLevel      - Threshold for recording.
//    logfileDirectoryPath              - Either nil or the directory in which the logfiles should be written.
//    logfileMaxSizeInBytes             - Approximate maximum size of a single logfile.
//    logfileMaxNumberOfFiles           - The maximum number of logfiles.
//
// For further details on the configuration, check the definitions below, or see the Xcode Quick Help.
//
// A suggestion: while working in Xcode, set aslFacilityRecordAtAndAboveLevel to .NONE, the logfile and stdout
// can be set as you like. In a shipping application set stdoutPrintAtAndAboveLevel to .NONE and the logfile and
// aslFacilityRecordAtAndAboveLevel as you like. Be aware that ASL will by default filter out anything at level DEBUG
// and INFO in the /etc/asl.conf file.
//
// The configuration variables above can be set in code, or in the application's Info.plist. Note that an application
// procured through the App-store will not start if the Info.plist is changed from the values when "Archived" for
// distribution. If end-user must be able to update the log levels, add a settings panel or menu to your code.
// Note: Without code signing a user can change the Info.plist, but then you cannot use the App-store for distribution.
//
// In order to set them in the Info.plist add a dictionary item with the key value "SwifterLog". In this directory add
// as many of the configuration items as you like. Use the full name of the configuration items for the key's and
// numbers for their values except for the logfileDirectoryPath which is a string. SwifterLog will guard against values
// that are invalid or out-of-bounds, in that case the default values as in this code will be used.
//
// Key                              | Type       | Range                  | Default when absent
// -------------------------------------------------------------------------------------------------
// SwifterLog                       | Dictionary | Any of the other items | nvt
// aslFacilityRecordAtAndAboveLevel | Number     | 0...8                  | NONE (8)
// stdoutPrintAtAndAboveLevel       | Number     | 0...8                  | NONE (8)
// logfileRecordAtAndAboveLevel     | Number     | 0...8                  | NONE (8)
// logfileDirectoryPath             | String     | RFC 2396               | "/Library/Application Support/Logfiles"
// logfileMaxSizeInBytes            | Number     | 10K...100M             | 1M
// logfileMaxNumberOfFiles          | Number     | 2...1000               | 20
//
// =====================================================================================================================
//
// And don't forget: Before creating the final release version of your software, make sure to set the correct loglevels!
//
// =====================================================================================================================
//
// Here is how I use the log levels:
//
// DEBUG: Almost all of my log messages are at this level. They are only of interest to me while I am working in Xcode.
// Typically they are of the kind "MyClass.myFunc: started" or "myParameter = 42".
//
// INFO: Once I am done with debugging, I still want to gain confidence that my app works as intended. The information
// at this level should remain visible in xcode, even though I am by now mostly unit-testing or running GUI tests from
// within Xcode. None of this information is usefull for the end-user. Typically they are of the kind "User clicked
// commit" or "Image XYZ loaded in MyClass".
//
// NOTICE: This is the first level of information that might be visible to the end-user. I use it to give information
// about the execution that may help me in helping the end-user with a problem. Typically these are messages like:
// "Connection with server established" or "Loaded configuration file" or "Set image correction to ALWAYS".
//
// WARNING: These messages contain information for the end-user. They usually inform the user about things he did wrong
// but which are fully handled by the application. I.e. they do not lead to termination of the app. While the messages
// will often be accompanied by an alert message, they may also fail silently. Typically they are like: "Option
// HIGHLIGHT no longer supported" or "Data after end-of-data marker ignored"
//
// ERROR: These are messages that are always accompanied by an alert window. They alert the user that something impared
// the functioning of the application. Typically like "Cannot load file format XYZ" or "Data does not contain XYZ". Note
// that it is still possible for the application to continue.
//
// CRITICAL: Messages at this level alert the user that he has to do something, or the application will not be able to
// continue. The application will usually stop until the user has fixed the situation. Examples are "Cannot save file,
// disk is full" or "Transfer interrupted".
//
// ALERT: This level is important to the end-user. It contains information about situations that could lead to security
// issues. Like somebody failing the password more than N times.
//
// EMERGENCY: I use this level when the application cannot continue and will terminate itself. The message itself
// is a last ditch attempt to generate some information that gives a clue to the cause of the problem.
//
// =====================================================================================================================
//
// History:
// v0.9.3   Changed syntax to Swift 2.0
// v0.9.2   Removed the 'ID' parameter from the logging calls
//          Added the "consoleSeparatorLine" function to create separators in the xcode or console output
// v0.9.1   Initial release
//
// =====================================================================================================================

import Foundation


// Note: This could also have been implemented as a set of functions instead of a class.
// However creating the class and subsequent singleton gives us a minor ease of use: code completion.
// Typing "log." where you need logging will instantly reveal all available options.


let log = SwifterLog() // Since SwifterLog.init is private, this is the only instance ever created


func <= (left: SwifterLog.Level, right: SwifterLog.Level) -> Bool {
    return left.rawValue <= right.rawValue
}

func > (left: SwifterLog.Level, right: SwifterLog.Level) -> Bool {
    return left.rawValue > right.rawValue
}

class SwifterLog {
    
    
    /// The available levels to cut-off
    
    enum Level: Int, CustomStringConvertible {
        case DEBUG      = 0
        case INFO       = 1
        case NOTICE     = 2
        case WARNING    = 3
        case ERROR      = 4
        case CRITICAL   = 5
        case ALERT      = 6
        case EMERGENCY  = 7
        case NONE       = 8
        case SEPARATOR  = 9
        var description: String {
            switch self {
            case .DEBUG:     return "DEBUG    "
            case .INFO:      return "INFO     "
            case .NOTICE:    return "NOTICE   "
            case .WARNING:   return "WARNING  "
            case .ERROR:     return "ERROR    "
            case .CRITICAL:  return "CRITICAL "
            case .ALERT:     return "ALERT    "
            case .EMERGENCY: return "EMERGENCY"
            case .NONE:      return "NONE     "
            case .SEPARATOR: return "SEPARATOR"
            }
        }
        func toAslLevel() -> Int32 {
            switch self {
            case .DEBUG:     return 7
            case .INFO:      return 6
            case .NOTICE:    return 5
            case .WARNING:   return 4
            case .ERROR:     return 3
            case .CRITICAL:  return 2
            case .ALERT:     return 1
            case .EMERGENCY: return 0
            case .NONE:      return -1
            case .SEPARATOR: return -2
            }
        }
    }
    
    
    /// Specifies the path for the directory in which the next logfile will be created. Note that the application must have write access to this directory and to create this directory (sandbox!). If this variable is nil, the logfiles will be written to /Library/Application Support/<<<Application Name>>>/Logfiles. Do not use '~' signs in the path, expand them first if there are tildes in the path that must be set.
    ///
    /// Note: When debugging in xcode, the app support directory is in /Library/Containers/<<<bundle identifier>>>/Data/Library/Application Support/<<<app name>>>/Logfiles.
    
    var logfileDirectoryPath: NSString? {
        didSet {
            logdirErrorMessageGenerated = false
            logfileErrorMessageGenerated = false
        }
    }
    
    
    /// As soon as an entry in the current logfile grows the logfile beyond this limit, the logfile will be closed and a new logfile will be started. The default is 1 MB. Also see "logfileMaxNumberOfFiles".
    
    var logfileMaxSizeInBytes: UInt64 = 1 * 1024 * 1024

    
    /// The maximum number of logfiles kept in the logfile directory. As soon as there are more than this number of logfiles, the oldest logfile will be removed. Must be >= 2.
    
    var logfileMaxNumberOfFiles: Int = 20 {
        didSet {
            if logfileMaxNumberOfFiles < 2 { logfileMaxNumberOfFiles = 2 }
        }
    }
    
    
    /// Only messages with a level at or above the level specified in this variable will be written to STDOUT. Set to "SwifterLog.Level.NONE" to suppress all messages to STDOUT.
    
    var stdoutPrintAtAndAboveLevel: Level = .NONE { didSet { self.setOverallThreshold() } }
    
    
    /// Only messages with a level at or above the level specified in this variable will be recorded in the logfile. Set to "SwifterLog.Level.NONE" to suppress all messages to the logfile.

    var logfileRecordAtAndAboveLevel: Level = .NONE  { didSet { self.setOverallThreshold() } }

    
    /// Only messages with a level at or above the level specified in this variable will be recorded by the Apple System Log Facility. Set to "SwifterLog.Level.NONE" to suppress all messages to the ASL(F).
    ///
    /// Note 1: The ASL log entries can be viewed with the "System Information.app" that is available in the "Applications/Utilities" folder. Do note that the configuration file at "/etc/asl.conf" suppresses all messages at levels DEBUG and INFO by default irrespective of the value of this variable.
    ///
    /// Note 2: SwifterLog will write messages to the ASL at level ERROR if necessary. If the threshold is set higher than ERROR SwifterLog will fail silently.

    var aslFacilityRecordAtAndAboveLevel: Level = .NONE  {
        didSet {
            self.setOverallThreshold()
            if (oldValue == .NONE) && (aslFacilityRecordAtAndAboveLevel != .NONE)
            {
                dispatch_once(&aslInitialised, {
                    _ = asl_add_log_file(nil, STDERR_FILENO)
                } )
            }
        }
    }

    
    func atLevel(level: Level, source: String, message: String) {
        putOnLoggingQueue(level, source: source, message: message)
    }

    func atLevelDebug(source source: String, message: String) {
        putOnLoggingQueue(.DEBUG, source: source, message: message)
    }
    
    func atLevelInfo(source source: String, message: String) {
        putOnLoggingQueue(.INFO, source: source, message: message)
    }
    
    func atLevelNotice(source source: String, message: String) {
        putOnLoggingQueue(.NOTICE, source: source, message: message)
    }

    func atLevelWarning(source source: String, message: String) {
        putOnLoggingQueue(.WARNING, source: source, message: message)
    }
    
    func atLevelError(source source: String, message: String) {
        putOnLoggingQueue(.ERROR, source: source, message: message)
    }
    
    func atLevelCritical(source source: String, message: String) {
        putOnLoggingQueue(.CRITICAL, source: source, message: message)
    }
    
    func atLevelAlert(source source: String, message: String) {
        putOnLoggingQueue(.ALERT, source: source, message: message)
    }
    
    func atLevelEmergency(source source: String, message: String) {
        putOnLoggingQueue(.EMERGENCY, source: source, message: message)
    }

    
    /// Prints a line with the specified character for the specified times to the console
    
    func consoleSeperatorLine(char: Character, times: Int) {
        guard times >= 0 else { return }
        var separator = ""
        for _ in 0 ..< times {
            separator.append(char)
        }
        putOnLoggingQueue(.SEPARATOR, source: separator, message: "")
    }

    
    // MARK: All private from here on
    
    private init() { // Gurantee a singleton usage of the logger
        
        // Try to read the settings from the app's Info.plist
        
        if  let infoPlist = NSBundle.mainBundle().infoDictionary,
            let swifterLogOptions = infoPlist["SwifterLog"] as? Dictionary<String, AnyObject> {
            
                if let alsThreshold = swifterLogOptions["aslFacilityRecordAtAndAboveLevel"] as? NSNumber {
                    if alsThreshold.integerValue >= Level.DEBUG.rawValue && alsThreshold.integerValue <= Level.NONE.rawValue {
                        aslFacilityRecordAtAndAboveLevel = Level(rawValue: alsThreshold.integerValue)!
                    } else {
                        logAslErrorOverride("Info.plist value for aslFacilityRecordAtAndAboveLevel in SwifterLog out of bounds (0 .. 8)")
                    }
                }
                    
                if let stdoutThreshold = swifterLogOptions["stdoutPrintAtAndAboveLevel"] as? NSNumber {
                    if stdoutThreshold.integerValue >= Level.DEBUG.rawValue && stdoutThreshold.integerValue <= Level.NONE.rawValue {
                        stdoutPrintAtAndAboveLevel = Level(rawValue: stdoutThreshold.integerValue)!
                    } else {
                        logAslErrorOverride("Info.plist value for stdoutPrintAtAndAboveLevel in SwifterLog out of bounds (0 .. 8)")
                    }
                }
                
                if let logfileThreshold = swifterLogOptions["logfileRecordAtAndAboveLevel"] as? NSNumber {
                    if logfileThreshold.integerValue >= Level.DEBUG.rawValue && logfileThreshold.integerValue <= Level.NONE.rawValue {
                        logfileRecordAtAndAboveLevel = Level(rawValue: logfileThreshold.integerValue)!
                    } else {
                        logAslErrorOverride("Info.plist value for logfileRecordAtAndAboveLevel in SwifterLog out of bounds (0 .. 8)")
                    }
                }
                
                if let logfileMaxSize = swifterLogOptions["logfileMaxSizeInBytes"] as? NSNumber {
                    if logfileMaxSize.integerValue >= 10 * 1024 && logfileMaxSize.integerValue <= 100 * 1024 * 1024 {
                        logfileMaxSizeInBytes = UInt64(logfileMaxSize.integerValue)
                    } else {
                        logAslErrorOverride("Info.plist value for logfileMaxSizeInBytes in SwifterLog out of bounds (10kB .. 100MB)")
                    }
                }
                
                if let logfileNofFiles = swifterLogOptions["logfileMaxNumberOfFiles"] as? NSNumber {
                    if logfileNofFiles.integerValue >= 2 && logfileNofFiles.integerValue <= 1000 {
                        logfileMaxNumberOfFiles = logfileNofFiles.integerValue
                    } else {
                        logAslErrorOverride("Info.plist value for logfileMaxNumberOfFiles in SwifterLog out of bounds (2 .. 1000)")
                    }
                }
                
                if let logfileDirPath = swifterLogOptions["logfileDirectoryPath"] as? String {
                    logfileDirectoryPath = logfileDirPath
                }
        }
    }
    
    
    // This function writes error messages to the ASL irrespective of the level settings. For internal use only.

    private func logAslErrorOverride(message: String) {
        dispatch_async(loggingQueue, { asl_bridge_log_message(Level.ERROR.toAslLevel(), message) } )
    }
    
    // The main purpose of this intermediate is to create a timestamp. The isolation of the rest is just bonus.
    
    private func putOnLoggingQueue(level: Level, source: String, message: String, time: NSDate = NSDate()) {
        if level == .NONE { return }
        if (overallThreshold <= level) || (level == .SEPARATOR) {
            let systemPrintEnabled = (stdoutPrintAtAndAboveLevel <= level) || (level == .SEPARATOR)
            let aslFacilityEnabled = aslFacilityRecordAtAndAboveLevel <= level
            let fileLoggingEnabled = logfileRecordAtAndAboveLevel <= level
            dispatch_async(loggingQueue, {
                self.log(time,
                    source: source,
                    logLevel: level,
                    message: message,
                    destinationSystemPrint: systemPrintEnabled,
                    destinationAslFacility: aslFacilityEnabled,
                    destinationFileLogging: fileLoggingEnabled)
            })
        }
    }
    
    lazy private var logTimeFormatter: NSDateFormatter = {
        let ltf = NSDateFormatter()
        ltf.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return ltf
        }()
    
    private var aslInitialised: dispatch_once_t = 0

    
    // Used to suppress multiple error messages for the failure to create a directory for the logfiles
    
    private var logdirErrorMessageGenerated = false
    private var logfileErrorMessageGenerated = false
    
    
    // For a slight performance gain
    
    private var overallThreshold = SwifterLog.Level.DEBUG

    
    // Should be called on every update to any of the three thresholds.
    
    private func setOverallThreshold() {
        var newThreshold = stdoutPrintAtAndAboveLevel
        if newThreshold > aslFacilityRecordAtAndAboveLevel { newThreshold = aslFacilityRecordAtAndAboveLevel }
        if newThreshold > logfileRecordAtAndAboveLevel { newThreshold = logfileRecordAtAndAboveLevel }
        overallThreshold = newThreshold
    }
    
    
    // Write log messages only from within this queue, that guarantees a non-overlapping behaviour even if multiple threads use the SwifterLog.
    
    private let loggingQueue = dispatch_queue_create("logging-queue", DISPATCH_QUEUE_SERIAL)
    
    
    // This function creates the log message and controls distribution to the enabled destinations, it should be called from within the logginQueue only.
    
    private func log(
        time: NSDate,
        source: String,
        logLevel: Level,
        message: String,
        destinationSystemPrint: Bool,
        destinationAslFacility: Bool,
        destinationFileLogging: Bool) {

            let sourceMessage = message.isEmpty ? source : source + ", " + message
            let logstr = logTimeFormatter.stringFromDate(time) + ", " + logLevel.description + ": " + sourceMessage
            
            if destinationSystemPrint { logSystemPrint(logstr) }
            if destinationFileLogging { logFileLogging(logstr) }
            if destinationAslFacility { logAslFacility(logLevel, message: logstr) }
    }
    
    private func logAslFacility(level: Level, message: String) {
        asl_bridge_log_message(level.toAslLevel(), message)
    }
    
    private func logFileLogging(message: String) {
        
        if let file = logfile {
            
            _ = file.seekToEndOfFile()
            if let data = (message + "\r\n").dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true) {
                file.writeData(data)
                file.synchronizeFile()
            }
            
            
            // Do some additional stuff like creating a new file if the current one gets too large and cleaning up of existing logfiles if there are too many
            
            self.logfileServices()
        }
    }
    
    private func logSystemPrint(message: String) {
        print(message)
    }
    
    
    // MARK: Logfile operations
    
    
    // Handle for the logfile
    
    lazy private var logfile: NSFileHandle? = { self.createLogfile() }()
    

    // We use the /Library/Application Support/<<<application>>>/Logfiles directory if no logfile directory is specified

    lazy private var applicationSupportLogfileDirectory: String? = {


        let fileManager = NSFileManager.defaultManager()
        
        do {
            let applicationSupportDirectory =
                try fileManager.URLForDirectory(
                    NSSearchPathDirectory.ApplicationSupportDirectory,
                    inDomain: NSSearchPathDomainMask.UserDomainMask,
                    appropriateForURL: nil,
                    create: true).path!
                
            let appName = NSProcessInfo.processInfo().processName
            let dirUrl = NSURL(fileURLWithPath: applicationSupportDirectory, isDirectory: true).URLByAppendingPathComponent(appName)
            return dirUrl.URLByAppendingPathComponent("Logfiles").path

        } catch let error as NSError {
        
            let message: String = "Could not get application support directory, error = " + (error.localizedDescription ?? "Unknown reason")
            self.logAslFacility(Level.ERROR, message: message)
            return nil
        }
    }()
    
    
    // Will be set to the URL of the logfile if the directory for the logfiles is available.
    
    private var logfileDirectoryURL: NSURL?
    
    
    // Creates a new logfile.
    
    private func createLogfile() -> NSFileHandle? {
        
        
        // Get the logfile directory
        
        if let logdir = (logfileDirectoryPath ?? applicationSupportLogfileDirectory) as? String {
            
            do {
                
                // Make sure the logfile directory exists

                try NSFileManager.defaultManager().createDirectoryAtPath(logdir, withIntermediateDirectories: true, attributes: nil)
            
                logfileDirectoryURL = NSURL(fileURLWithPath: logdir, isDirectory: true) // For the logfile services
        
                let filename = "Log_" + logTimeFormatter.stringFromDate(NSDate()) + ".txt"
                
                let logfileUrl = NSURL(fileURLWithPath: logdir).URLByAppendingPathComponent(filename)
                
                if NSFileManager.defaultManager().createFileAtPath(logfileUrl.path!, contents: nil, attributes: [NSFilePosixPermissions : NSNumber(int: 0o640)]) {
                    
                    return NSFileHandle(forUpdatingAtPath: logfileUrl.path!)

                } else {
                    
                    if !logfileErrorMessageGenerated {
                        let message = "Could not create logfile \(logfileUrl.path)"
                        logAslFacility(.ERROR, message: message)
                        logfileErrorMessageGenerated = true
                    }
                }
                
            } catch let error as NSError {
                
                if !logdirErrorMessageGenerated {
                    let message = "Could not create logfile directory \(logdir), error = " + (error.localizedDescription ?? "Unknown reason")
                    logAslFacility(.ERROR, message: message)
                    logdirErrorMessageGenerated = true
                }
            }
            
        } else {
            // Only possible if the application support directory could not be retrieved, in that case an ASL entry has already been generated
        }
        
        return nil
    }
    
    
    // Closes the current logfile if it has gotten too large. And limits the number of logfiles to the specified maximum.
    
    private func logfileServices() {
        
        
        // There should be a logfile, if there is'nt, then something is wrong
        
        if let file = logfile {
        
            
            // If the file size is larger than the specified maximum, close the existing logfile and create a new one
            
            if file.seekToEndOfFile() > logfileMaxSizeInBytes {
                
                file.closeFile()
                
                logfile = createLogfile()
            }
        
            
            // Check if there are more than 20 files in the logfile directory, if so, remove the oldest
            
            do {
            
                let files = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(
                    logfileDirectoryURL!,
                    includingPropertiesForKeys: nil,
                    options: NSDirectoryEnumerationOptions.SkipsHiddenFiles)
                
                if files.count > logfileMaxNumberOfFiles {
                    let sortedFiles = files.sort({ $0.lastPathComponent < $1.lastPathComponent })
                    try NSFileManager.defaultManager().removeItemAtURL(sortedFiles.first!)
                }
            } catch {
            }
        }
    }
}