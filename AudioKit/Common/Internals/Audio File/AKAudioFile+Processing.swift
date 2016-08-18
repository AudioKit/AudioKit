//
//  AKAudioFile+Processing.swift
//  AudioKit
//
//  Created by Laurent Veliscek, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//
//
//  IMPORTANT: Any AKAudioFile process will output a .caf AKAudioFile
//  set with a PCM Linear Encoding (no compression)
//  But it can be applied to any readable file (.wav, .m4a, .mp3...)
//

import Foundation
import AVFoundation

extension AKAudioFile {
    
    /// Normalize an AKAudioFile to have a peak of newMaxLevel dB.
    ///
    /// - Parameters:
    ///   - baseDir:     where the file will be located, can be set to .Resources,  .Documents or .Temp
    ///   - name:        the name of the file without its extension (String).
    ///   - newMaxLevel: max level targeted as a Float value (default if 0 dB)
    ///
    /// - returns: An AKAudioFile, or nil if init failed.
    ///
    public func normalized(baseDir baseDir: BaseDirectory = .Temp,
                                   name: String = "",
                                   newMaxLevel: Float = 0.0 ) throws -> AKAudioFile {
        
        let level = self.maxLevel
        var outputFile = try AKAudioFile (writeIn: baseDir, name: name)
        
        if self.samplesCount == 0 {
            print( "WARNING AKAudioFile: cannot normalize an empty file")
            return try AKAudioFile(forReading: outputFile.url)
        }
        
        if level == FLT_MIN {
            print( "WARNING AKAudioFile: cannot normalize a silent file")
            return try AKAudioFile(forReading: outputFile.url)
        }
        
        
        
        let gainFactor = Float( pow(10.0, newMaxLevel/10.0) / pow(10.0, level / 10.0))
        
        let arrays = self.arraysOfFloats
        
        var newArrays: [[Float]] = []
        for array in arrays {
            let newArray = array.map {$0 * gainFactor}
            newArrays.append(newArray)
        }
        
        outputFile = try AKAudioFile(createFileFromFloats: newArrays,
                                     baseDir: baseDir,
                                     name: name)
        return try AKAudioFile(forReading: outputFile.url)
    }
    
    
    /// Returns an AKAudioFile with audio reversed (will playback in reverse from end to beginning).
    ///
    /// - Parameters:
    ///   - baseDir: where the file will be located, can be set to .Resources,  .Documents or .Temp
    ///   - name: the name of the file without its extension (String).
    ///
    /// - Returns: An AKAudioFile, or nil if init failed.
    ///
    public func reversed(baseDir baseDir: BaseDirectory = .Temp,
                                 name: String = "" ) throws -> AKAudioFile {
        
        var outputFile = try AKAudioFile (writeIn: baseDir, name: name)
        
        if self.samplesCount == 0 {
            return try AKAudioFile(forReading: outputFile.url)
        }
        
        
        let arrays = self.arraysOfFloats
        
        var newArrays: [[Float]] = []
        for array in arrays {
            newArrays.append(Array(array.reverse()))
        }
        outputFile = try AKAudioFile(createFileFromFloats: newArrays,
                                     baseDir: baseDir,
                                     name: name)
        return try AKAudioFile(forReading: outputFile.url)
    }
    
    
    /// Returns an AKAudioFile with appended audio data from another AKAudioFile.
    ///
    /// Notice that Source file and appended file formats must match.
    ///
    /// - Parameters:
    ///   - file: an AKAudioFile that will be used to append audio from.
    ///   - baseDir: where the file will be located, can be set to .Resources, .Documents or .Temp
    ///   - name: the name of the file without its extension (String).
    ///
    ///  - Returns: An AKAudioFile, or nil if init failed.
    ///
    public func appendedBy(file file: AKAudioFile,
                                baseDir: BaseDirectory = .Temp,
                                name: String  = "") throws -> AKAudioFile {
        
        
        var sourceBuffer = self.pcmBuffer
        var appendedBuffer = file.pcmBuffer
        
        
        if self.fileFormat != file.fileFormat {
            print("WARNING AKAudioFile.append: appended file should be of same format as source file!")
            print("WARNING AKAudioFile.append: trying to fix by converting files...")
            // We use extract method to get a .CAF file with the right format for appending
            // So sourceFile and appended File formats should match
            do {
                // First, we convert the source file to .CAF using extract()
                let convertedFile = try self.extracted()
                sourceBuffer = convertedFile.pcmBuffer
                print("AKAudioFile.append: source file has been successfully converted")
                
                if convertedFile.fileFormat != file.fileFormat {
                    do {
                        // If still don't match we convert the appended file to .CAF using extract()
                        let convertedAppendFile = try file.extracted()
                        appendedBuffer = convertedAppendFile.pcmBuffer
                        print("AKAudioFile.append: appended file has been successfully converted")
                    } catch let error as NSError {
                        print("ERROR AKAudioFile.append: cannot set append file format match source file format!...")
                        throw error
                    }
                }
            } catch let error as NSError {
                print( "ERROR AKAudioFile: Cannot convert sourceFile to .CAF!")
                throw error
            }
        }
        
        // We check that both pcm buffers share the same format
        if appendedBuffer.format != sourceBuffer.format {
            print("ERROR AKAudioFile.append: Couldn't match source file format with appended file format!...")
            let userInfo: [NSObject : AnyObject] = [
                NSLocalizedDescriptionKey : NSLocalizedString(
                    "AKAudioFile append process Error",
                    value: "Couldn't match source file format with appended file format",
                    comment: ""),
                NSLocalizedFailureReasonErrorKey : NSLocalizedString(
                    "AKAudioFile append process Error",
                    value: "Couldn't match source file format with appended file format",
                    comment: "")
            ]
            throw NSError(domain: "AKAudioFile ASync Process Unknown Error", code: 0, userInfo: userInfo)
        }
        
        let outputFile = try AKAudioFile (writeIn: baseDir, name: name)
        
        
        // Write the buffer in file
        do {
            try outputFile.writeFromBuffer(sourceBuffer)
        } catch let error as NSError {
            print( "ERROR AKAudioFile: cannot writeFromBuffer Error: \(error)")
            throw error
        }
        
        
        do {
            try outputFile.writeFromBuffer(appendedBuffer)
        } catch let error as NSError {
            print( "ERROR AKAudioFile: cannot writeFromBuffer Error: \(error)")
            throw error
        }
        
        return try AKAudioFile(forReading: outputFile.url)
    }
    
    /// Returns an AKAudioFile that will contain a range of samples from the current AKAudioFile
    ///
    /// - Parameters:
    ///   - fromSample: the starting sampleFrame for extraction.
    ///   - toSample: the ending sampleFrame for extraction
    ///   - baseDir: where the file will be located, can be set to .Resources, .Documents or .Temp
    ///   - name: the name of the file without its extension (String).
    ///
    /// - Returns: An AKAudioFile, or nil if init failed.
    ///
    public func extracted(fromSample fromSample: Int64 = 0,
                                     toSample: Int64 = 0,
                                     baseDir: BaseDirectory = .Temp,
                                     name: String = "") throws -> AKAudioFile {
        
        let fixedFrom = abs(fromSample)
        let fixedTo:Int64 = toSample == 0 ? Int64(self.samplesCount) : min(toSample,Int64(self.samplesCount))
        if fixedTo <= fixedFrom {
            print( "ERROR AKAudioFile: cannot extract, from must be less than to !")
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo:nil)
        }
        
        
        let arrays = self.arraysOfFloats
        
        var newArrays: [[Float]] = []
        
        for array in arrays {
            let extract = Array(array[Int(fixedFrom)..<Int(fixedTo)])
            newArrays.append(extract)
        }
        
        let newFile = try AKAudioFile(createFileFromFloats: newArrays, baseDir: baseDir, name: name)
        return try AKAudioFile(forReading: newFile.url)
    }
    
    
}