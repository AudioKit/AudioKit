//
//  FileUtilities.swift
//  SporthEditor
//
//  Created by Kanstantsin Linou on 7/11/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

struct FileUtilities {
    static let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                       .userDomainMask, true).first ?? ""

    static var storageDirectory: String = {
        let directory = "\(documentDirectory)/SporthEditor"
        do {
            try FileManager.default.createDirectory(atPath: directory,
                                                                     withIntermediateDirectories: true,
                                                                     attributes: nil)
        } catch {
            NSLog("\(Constants.Error.Creation) \(directory)")
        }
        return directory
    }()

    static func filePath(_ name: String) -> String {
        return "\(FileUtilities.storageDirectory)/\(name)"
    }

    static let fileExtension = "sp"
}
