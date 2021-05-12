// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import CAudioKit
import Foundation

/// Exception catcher
/// - Parameter operation: Throwin code
/// - Throws: Error if an excpetion occurred
public func ExceptionCatcher(_ operation: @escaping (() throws -> Void)) throws {
    var error: Error?

    let theTry = {
        do {
            try operation()
        } catch let ex {
            error = ex
        }
    }

    let theCatch: (NSException) -> Void = { except in
        var userInfo = [String: Any]()
        userInfo[NSLocalizedDescriptionKey] = except.description
        userInfo[NSLocalizedFailureReasonErrorKey] = except.reason
        userInfo["exception"] = except

        error = NSError(domain: "io.audiokit.AudioKit",
                        code: 0,
                        userInfo: userInfo)
    }

    ExceptionCatcherOperation(theTry, theCatch)

    if let error = error { // Caught an exception
        throw error
    }
}
