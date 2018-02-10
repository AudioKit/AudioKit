//
//  ExceptionCatcher.swift
//  AudioKit
//
//  Created by Stéphane Peter, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

public func AKTry(_ operation: @escaping (() throws -> Void)) throws
{
    var error: Error?
    
    let theTry = {
        do {
            try operation()
        } catch let ex {
            error = ex
        }
    }
    
    let theCatch: (NSException) -> Void = { except in
        error = NSError(domain: "io.audiokit.AudioKit",
                        code: 0,
                        userInfo: ["Exception": except.userInfo ?? except.name])
    }
    
    AKTryOperation(theTry, theCatch)
    
    if let error = error { // Caught an exception
        throw error
    }
}
