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

public func AKTry(_ operation: @escaping (() throws -> Void),
                  finally: (() -> Void)? = nil) throws
{
    var error: NSException?
    
    let theTry = {
        do {
            try operation()
        } catch let ex {
            error = ex as? NSException
        }
    }
    
    let theCatch: (NSException?) -> Void = { ex in
        error = ex
    }
    
    AKTryOperation(theTry, theCatch, finally)
    
    if let ex = error { // Caught an exception
        throw ex as Error
    }
}
