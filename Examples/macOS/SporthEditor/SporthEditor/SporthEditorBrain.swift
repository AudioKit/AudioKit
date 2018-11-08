//
//  SporthEditorBrain.swift
//  SporthEditor
//
//  Created by Kanstantsin Linou, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit

class SporthEditorBrain {
    var generator: AKOperationGenerator?
    fileprivate var knownCodes = [String: String]()
    var lastSavedName: String?

    var rows: Int {
        return knownCodes.count
    }

    var names: [String] {
        return Array(knownCodes.keys)
    }

    func getCode(_ name: String) -> String {
        let returnValue = knownCodes[name]
        return returnValue ?? ""
    }

    func run(_ code: String) {
        generator?.stop()
        do {
            try AudioKit.stop()
        } catch {
            AKLog("AudioKit did not stop!")
        }
        generator = AKOperationGenerator { _ in
            return AKOperation(code)
        }
        AudioKit.output = generator
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        generator?.start()
    }

    func stop() {
        generator?.stop()
    }

    func save(_ name: String, code: String) {
        let fileName = name + FileUtilities.fileExtension
        let filePath = FileUtilities.filePath(fileName)

        do {
            try code.write(toFile: filePath, atomically: true, encoding: String.Encoding.utf8)
            knownCodes[name] = code
            NSLog("Saving was completed successfully")

        } catch {
            NSLog("Error during saving the file")
        }
        lastSavedName = name
    }
}
