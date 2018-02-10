//
//  ExceptionCatcher.swift
//  AudioKit
//
//  Created by Stéphane Peter, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

extension NSException: Error
{
    public var domain: String { return "io.audiokit.SwiftExceptionCatcher" }
    public var code: Int { return 0 }
}

public func AKTry(_ operation: @escaping (() throws -> Void)) throws
{
    var error: NSException?
    
    let theTry = {
        do {
            try operation()
        } catch let ex {
            error = ex as? NSException
        }
    }
    
    let theCatch: (NSException?) -> Void = { except in
        error = except
    }
    
    AKTryOperation(theTry, theCatch, finally)
    
    if let except = error { // Caught an exception
        throw except as Error
    }
}
