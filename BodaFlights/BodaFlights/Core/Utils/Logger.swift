//
//  Logger.swift
//  BodaFlights
//
//  Created by Scor Doan on 4/20/19.
//  Copyright © 2019 Scor Doan. All rights reserved.
//

import Foundation

enum LoggerLevel {
    case debug
    case none
}

class Logger: NSObject {
    static let `default` = Logger()
    var level = LoggerLevel.none
    
    func error(_ error: Swift.Error, fileName: String = #file, function: String = #function, line: Int = #line) {
        switch level {
        case .debug:
            let f = (fileName as NSString).lastPathComponent
            print("\n\nERROR: \(f) \(function) -- Line \(line): ")
            print("-->\t", terminator: "")
            debugPrint(error)
            print("<--\n")
        case .none:
            break
        }
    }
    
    func error(_ string: String, fileName: String = #file, function: String = #function, line: Int = #line) {
        switch level {
        case .debug:
            let f = (fileName as NSString).lastPathComponent
            print("\n\nERROR: \(f) \(function) -- Line \(line): ")
            print("-->\t", terminator: "")
            debugPrint(string)
            print("<--\n")
        case .none:
            break
        }
    }
    
    func debug(_ items: Any..., separator: String = " ", terminator: String = "\n", fileName: String = #file, function: String = #function, line: Int = #line) {
        switch level {
        case .debug:
            let f = (fileName as NSString).lastPathComponent
            print("\nDebug: \(f) \(function) -- Line \(line): ")
            print("-->\t", terminator: "")
            debugPrint(items, separator: separator, terminator: terminator)
            print("<--\n")
        case .none:
            break
        }
    }
}
