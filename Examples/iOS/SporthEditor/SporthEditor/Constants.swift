//
//  Constants.swift
//  SporthEditor
//
//  Created by Kanstantsin Linou, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation

struct Constants {
    struct Code {
        static let title = "Code Editor is Empty"
        static let message = "Put some code into and try again"
    }

    struct Name {
        static let title = "Name is Empty"
        static let message = "Type any name you want to save it with and try again"
    }

    struct File {
        static let simpleKeyboard = "Simple Keyboard"
    }

    struct Path {
        static var simpleKeyboard: String {
            return Bundle.main.path(forResource: Constants.File.simpleKeyboard, ofType: FileUtilities.fileExtension)!
        }
    }

    struct Error {
        static let Creation = "SporthEditor: Error while creating a local storage directory at path:"
        static let Loading = "SporthEditor: Error while loading presaved files: chat.sp or drone.sp"
        static let Saving = "SporthEditor: Saving was completed successfully"
    }

    struct Success {
        static let Saving = "SporthEditor: Saving was completed successfully"
    }
}
