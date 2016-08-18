//
//  FileUtilities.swift
//  SporthEditor
//
//  Created by Kanstantsin Linou on 7/11/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

struct FileUtilities {
    static let documentDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory,
                                                                       .UserDomainMask, true).first!
    
    static var storageDirectory: String = {
        let directory = "\(documentDirectory)/SporthEditor"
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(directory,
                                                                     withIntermediateDirectories: true,
                                                                     attributes: nil)
        } catch {
            NSLog("\(Constants.Error.Creation) \(directory)")
        }
        return directory
    }()
    
    static func filePath(name: String) -> String {
        return "\(FileUtilities.storageDirectory)/\(name)"
    }
    
    static let fileExtension = "sp"
}
