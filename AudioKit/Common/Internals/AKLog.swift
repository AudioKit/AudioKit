//
//  AKLog.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import os

private let subsystem = "io.audiokit"

public struct Log {
    public static let general = OSLog(subsystem: subsystem, category: "general")
    public static let midi = OSLog(subsystem: subsystem, category: "midi")
    public static let fileHandling = OSLog(subsystem: subsystem, category: "fileHandling")
}

/// Wrapper for printing out status messages to the console,
/// eventually it could be expanded with log levels
/// - items: Zero or more items to print.
///
@inline(__always)
public func AKLog(_ message: String,
                  log: OSLog = Log.general,
                  type: OSLogType = .info) {
    guard AKSettings.enableLogging else { return }
    let fileName = (#file as NSString).lastPathComponent
    os_log("%s:%s:%d %s", log: log, type: type, fileName, #function, #line, message)
}
