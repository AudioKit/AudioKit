//
//  AKAudioFile+Utilities.swift
//  AudioKit
//
//  Created by Laurent Veliscek on 7/4/16.
//  Copyright © 2017 AudioKit. All rights reserved.
//
//
//

import Foundation
import AVFoundation

extension AKAudioFile {

    /// Returns a silent AKAudioFile with a length set in samples.
    ///
    /// For a silent file of one second, set samples value to 44100...
    ///
    /// - Parameters:
    ///   - samples: the number of samples to generate (equals length in seconds multiplied by sample rate)
    ///   - baseDir: where the file will be located, can be set to .resources,  .documents or .temp
    ///   - name: the name of the file without its extension (String).
    ///
    /// - Returns: An AKAudioFile, or nil if init failed.
    ///
    static public func silent(samples: Int64,
                              baseDir: BaseDirectory = .temp,
                              name: String = "") throws -> AKAudioFile {

        if samples < 0 {
            AKLog( "ERROR AKAudioFile: cannot create silent AKAUdioFile with negative samples count !")
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo:nil)
        } else if samples == 0 {
            let emptyFile = try AKAudioFile(writeIn: baseDir, name: name)
            // we return it as a file for reading
            return try AKAudioFile(forReading: emptyFile.url)
        }

        let zeros = [Float](zeros: Int(samples))
        let silentFile = try AKAudioFile(createFileFromFloats: [zeros, zeros], baseDir: baseDir, name: name)

        return try AKAudioFile(forReading: silentFile.url)
    }

}
