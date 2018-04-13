//
//  AKError.swift
//  AudioKit
//
//  Created by Jeff Cooper on 4/13/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

// AKError is an enum with descriptions so we can throw generic errors
// and hopefully provide more detail to developers when code fails
// Please feel free to add any errors you need especially if they come up frequently

enum AKError : Error, LocalizedError{
    case AudioKitNotRunning
    case Unexplained
    public var errorDescription: String? {
        switch self {
        case .AudioKitNotRunning:
            return "I'm afraid I can't do that, Dave - AudioKit is not currently running"
        default:
            return "Unexplained error"
        }
    }
}
