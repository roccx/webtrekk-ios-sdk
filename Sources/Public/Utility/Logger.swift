//The MIT License (MIT)
//
//Copyright (c) 2016 Webtrekk GmbH
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
//"Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish,
//distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject
//to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Created by Widgetlabs
//

import Foundation
import os.log

public final class DefaultTrackingLogger: TrackingLogger {

	/** Enable or disable logging completly */
	public var enabled = true
    
    /** In test mode logging is always done independed on level with .info type to print all in console*/
    public var testMode = false

	/** Filter the amount of log output by setting different `TrackingLogLevel` */
	public var minimumLevel = TrackingLogLevel.warning

	/** Attach a message to the log output with a spezific `TackingLogLevel` */
	public func log(message: @autoclosure () -> String, level: TrackingLogLevel) {
		guard enabled && (level.rawValue >= minimumLevel.rawValue || testMode) else {
			return
		}

        if #available(iOS 10.0, *), #available(watchOSApplicationExtension 3.0, *), #available(tvOS 10.0, *) {
            
            let logType = testMode ? .info : level.type!
            os_log("%@", dso: #dsohandle, log: OSLog.default, type: logType, "[Webtrekk] [\(level.title)] \(message())")
        } else {
            NSLog("%@", "[Webtrekk] [\(level.title)] \(message())")
        }
	}
}


public enum TrackingLogLevel: Int {

    case debug   = 1
	case info    = 2
	case warning = 3
	case error   = 4
    case fault = 5

	fileprivate var title: String {
		switch (self) {
		case .debug:   return "Debug"
		case .info:    return "Info"
		case .warning: return "Warning"
		case .error:   return "ERROR"
        case .fault: return "FAULT"
		}
	}
    fileprivate var type: OSLogType? {
        
        guard #available(iOS 10.0, *), #available(watchOSApplicationExtension 3.0, *), #available(tvOS 10.0, *) else {
            return nil
        }
        
        switch (self) {
        case .debug:   return .debug
        case .info:    return .info
        case .warning: return .info
        case .error:   return .error
        case .fault: return .fault
        }
    }
}


public protocol TrackingLogger: class {

	func log (message: @autoclosure () -> String, level: TrackingLogLevel)
}


public extension TrackingLogger {

	public func logDebug(_ message: @autoclosure () -> String) {
		log(message: message, level: .debug)
	}


	public func logError(_ message: @autoclosure () -> String) {
		log(message: message, level: .error)
	}


	public func logInfo(_ message: @autoclosure () -> String) {
		log(message: message, level: .info)
	}


	public func logWarning(_ message: @autoclosure () -> String) {
		log(message: message, level: .warning)
	}
}
