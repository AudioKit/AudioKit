// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation
import os

private let subsystem = "io.audiokit"

public extension OSLog {
    /// Generic AudioKit log
    static let general = OSLog(subsystem: subsystem, category: "general")

    /// Settings-related log
    static let settings = OSLog(subsystem: subsystem, category: "settings")

    /// MIDI related log
    static let midi = OSLog(subsystem: subsystem, category: "midi")

    /// Log revolving around finding, reading, and writing files
    static let fileHandling = OSLog(subsystem: subsystem, category: "fileHandling")
}

/// Wrapper for  os_log logging system. It currently shows filename,  function, and line number,
/// but that might be removed if it shows any negative performance impact (Apple recommends against it).
///
/// Parameters:
///     - items:  Output message or variable list of objects
///     - log: One of the log types from the Log struct, defaults to .general
///     - type: OSLogType, defaults to .info
///     - file:  Filename from the log message, should  not be set explicitly
///     - function: Function enclosing the log message, should not be set explicitly
///     - line: Line number of the log method, should  not be set explicitly
///
@inline(__always)
public func Log(_ items: Any?...,
                log: OSLog = .general,
                type: OSLogType = .info,
                file: String = #file,
                function: String = #function,
                line: Int = #line)
{
    guard Settings.enableLogging else { return }

    let fileName = (file as NSString).lastPathComponent
    let content = (items.map {
        String(describing: $0 ?? "nil")
    }).joined(separator: " ")

    let message = "\(fileName):\(function):\(line):\(content)"

    os_log("%s (%s:%s:%d)", log: log, type: type, message, fileName, function, line)
}
