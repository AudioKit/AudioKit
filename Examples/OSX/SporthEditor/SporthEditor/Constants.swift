//
//  Constants.swift
//  SporthEditor
//
//  Created by Kanstantsin Linou on 7/12/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

struct Constants {
    struct Message {
        static let ok = "OK"
        static let save = "Save your code as a .\(FileUtilities.fileExtension) file"
    }
    
    struct Code {
        static let title = "Code Editor is Empty"
        static let message = "Put some code into and try again"
    }
    
    struct Name {
        static let storyboard = "Main"
        static let title = "Name is Empty"
        static let message = "Type any name you want to save it with and try again"
    }
    
    struct Identifier {
        static let cell = "name"
        static let controlsController = "Controls Window Controller"
    }
    
    struct Error {
        static let Creation = "SporthEditor: Error while creating a local storage directory at path:"
        static let Loading = "SporthEditor: Error while loading presaved files: chat.sp or drone.sp"
        static let Saving = "SporthEditor: Saving wasn't completed"
    }
    
    struct Success {
        static let Saving = "SporthEditor: Saving was completed successfully"
    }
}
