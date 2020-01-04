//
//  AKLog.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import os

private let subsystem = "io.audiokit"

extension OSLog {
    /// Generic AudioKit log
    public static let audiokit = OSLog(subsystem: subsystem, category: "audiokit")

    /// AudioKit MIDI related log
    public static let midi = OSLog(subsystem: subsystem, category: "midi")

    /// Log revolving around finding, reading, and writing files
    public static let fileHandling = OSLog(subsystem: subsystem, category: "fileHandling")
}

/// Wrapper for  os_log logging system. It currently shows filename,  function, and line number,
/// but that might be removed if it shows any negative performance impact (Apple recommends against it).
///
/// Parameters:
///     - message:  Output message, should be very detailed
///     - log: One of the log types from the Log struct, defaults to .audiokit
///     - type: OSLogType, defaults to .info
///     - file:  Filename from the log message, should  not be set explicitly
///     - function: Function enclosing the log message, should not be set explicitly
///     - line: Line number of the log method, should  not be set explicitly
///
@inline(__always)
public func AKLog(_ message: String,
                  log: OSLog = OSLog.audiokit,
                  type: OSLogType = .info,
                  file: String = #file,
                  function: String = #function,
                  line: Int = #line) {
    guard AKSettings.enableLogging else { return }
    let fileName = (file as NSString).lastPathComponent
    os_log("%s (%s:%s:%d)", log: log, type: type, message, fileName, function, line)
}
