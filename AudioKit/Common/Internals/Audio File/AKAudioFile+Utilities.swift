//
//  AKAudioFile+Utilities.swift
//  AudioKit
//
//  Created by Laurent Veliscek on 7/4/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//
//
//

import Foundation
import AVFoundation

extension AKAudioFile {
    
    /// returns file Mime Type if exists
    /// Otherwise, returns nil
    /// (useful when sending an AKAudioFile by email)
    public var mimeType: String? {
        switch self.fileExt.uppercased() {
        case "WAV":
            return  "audio/wav"
        case "CAF":
            return  "audio/x-caf"
        case "AIF", "AIFF", "AIFC":
            return "audio/aiff"
        case "M4R":
            return  "audio/x-m4r"
        case "M4A":
            return  "audio/x-m4a"
        case "MP4":
            return  "audio/mp4"
        case "M2A", "MP2":
            return  "audio/mpeg"
        case "AAC":
            return  "audio/aac"
        case "MP3":
            return "audio/mpeg3"
        default: return nil
        }
    }
    
    /// Static function to delete all audiofiles from Temp directory
    ///
    /// AKAudioFile.cleanTempDirectory()
    ///
    public static func cleanTempDirectory() {
        var deletedFilesCount = 0
        
        let fileManager = FileManager.default
        let tempPath =  NSTemporaryDirectory()
        
        do {
            let fileNames = try fileManager.contentsOfDirectory(atPath: "\(tempPath)")
            
            // function for deleting files
            func deleteFileWithFileName(_ fileName: String) {
                let filePathName = "\(tempPath)/\(fileName)"
                do {
                    try fileManager.removeItem(atPath: filePathName)
                    AKLog("\"\(fileName)\" deleted.")
                    deletedFilesCount += 1
                } catch let error as NSError {
                    AKLog("Couldn't delete \(fileName) from Temp Directory")
                    AKLog("Error: \(error)")
                }
            }
            
            // Checks file type (only Audio Files)
            fileNames.forEach { fn in
                let lower = fn.lowercased()
                _ = [".wav", ".caf", ".aif", ".mp4", ".m4a"].first {
                    lower.hasSuffix($0)
                }.map { _ in
                    deleteFileWithFileName(fn)
                }
            }

            // print report
            switch deletedFilesCount {
            case 0: AKLog("AKAudioFile.cleanTempDirectory: No file deleted.")
            case 1: AKLog("AKAudioFile.cleanTempDirectory: \(deletedFilesCount) File deleted.")
            default: AKLog("AKAudioFile.cleanTempDirectory: \(deletedFilesCount) Files deleted.")
                
            }
            
            
        } catch let error as NSError {
            AKLog("Couldn't access Temp Directory")
            AKLog("Error: \(error)")
        }
    }
    
    /// Returns a silent AKAudioFile with a length set in samples.
    ///
    /// For a silent file of one second, set samples value to 44100...
    ///
    /// - Parameters:
    ///   - samples: the number of samples to generate (equals length in seconds multiplied by sample rate)
    ///   - baseDir: where the file will be located, can be set to .Resources,  .Documents or .Temp
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
        
        let array = [Float](zeros: Int(samples))
        let silentFile = try AKAudioFile(createFileFromFloats: [array, array], baseDir: baseDir, name: name)
        
        return try AKAudioFile(forReading: silentFile.url)
    }
    
    
    
}
