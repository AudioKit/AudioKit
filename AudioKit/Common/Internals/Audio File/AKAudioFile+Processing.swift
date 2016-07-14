//
//  AKAudioFile+Processing.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka and Laurent Veliscek on 7/4/16.
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
    /**
     Returns an AKAudioFile with audio data of the current AKAudioFile normalized to have a peak of newMaxLevel dB.
     
     - Parameters:
        - name: the name of the file without its extension (String).
        - baseDir: where the file will be located, can be set to .Resources,  .Documents or .Temp
        - newMaxLevel: max level targeted as a Float value (default if 0 dB)
     
    - Throws: NSError if failed .
     
    - Returns: An AKAudioFile, or nil if init failed.*/
    public func normalize( baseDir: BaseDirectory = .Temp,
                           name: String = "", newMaxLevel: Float = 0.0 ) throws -> AKAudioFile {
        
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
        
        outputFile = try AKAudioFile(createFileFromFloats: newArrays, baseDir: baseDir, name: name)
        return try AKAudioFile(forReading: outputFile.url)
    }

    /**
     Returns an AKAudioFile with audio reversed (will playback in reverse from end to beginning).
     
     - Parameters:
        - name: the name of the file without its extension (String).
        - baseDir: where the file will be located, can be set to .Resources,  .Documents or .Temp
     
     - Throws: NSError if failed .
     
     - Returns: An AKAudioFile, or nil if init failed.*/
    public func reverse( baseDir: BaseDirectory = .Temp,
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
        outputFile = try AKAudioFile(createFileFromFloats: newArrays, baseDir: baseDir, name: name)
        return try AKAudioFile(forReading: outputFile.url)
    }

    /**
     Returns an AKAudioFile with appended audio data from another AKAudioFile.
     
     - Parameters:
        - file: an AKAudioFile that will be used to append audio from.
        - name: the name of the file without its extension (String).
        - baseDir: where the file will be located, can be set to .Resources,  .Documents or .Temp
     
     - Throws: NSError if failed .
     
     - Returns: An AKAudioFile, or nil if init failed.*/
    public func append( file: AKAudioFile,
                        baseDir: BaseDirectory = .Temp,
                        name: String  = "") throws -> AKAudioFile {
        
        if self.fileFormat != file.fileFormat {
            print( "ERROR AKAudioFile: appended file must be of the same format!")
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo:nil)
        }
        
        let outputFile = try AKAudioFile (writeIn: baseDir, name: name)
        
        
        let myBuffer = self.pcmBuffer
        
        // Write the buffer in file
        do {
            try outputFile.writeFromBuffer(myBuffer)
        } catch let error as NSError {
            print( "ERROR AKAudioFile: cannot writeFromBuffer Error: \(error)")
            throw error
        }
        
        let appendedBuffer = file.pcmBuffer
        
        do {
            try outputFile.writeFromBuffer(appendedBuffer)
        } catch let error as NSError {
            print( "ERROR AKAudioFile: cannot writeFromBuffer Error: \(error)")
            throw error
        }
        
        return try AKAudioFile(forReading: outputFile.url)
    }
    
    
    /**
     Returns an AKAudioFile that will contain a range of samples from the current AKAudioFile
     
     - Parameters:
        - from: the starting sampleFrame for extraction.
        - to: the ending sampleFrame for extraction
        - name: the name of the file without its extension (String).
        - baseDir: where the file will be located, can be set to .Resources,  .Documents or .Temp
     
     - Throws: NSError if failed .
     
     - Returns: An AKAudioFile, or nil if init failed.*/
    public func extract(from: Int64 = 0, to: Int64 = 0, baseDir: BaseDirectory = .Temp,
                        name: String = "") throws -> AKAudioFile {

        let fixedFrom = abs(from)
        let fixedTo:Int64 = to == 0 ? Int64(self.samplesCount) : min(to,Int64(self.samplesCount))
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
   
    /**
     Returns a silent AKAudioFile with a length set in samples.
     For a silent file of one second, set samples value to 44100...
     
     - Parameters:
        - samples: the number of samples to generate ( equals length in seconds multiplied by sample rate)
        - name: the name of the file without its extension (String).
        - baseDir: where the file will be located, can be set to .Resources,  .Documents or .Temp
     
     - Throws: NSError if failed .
     
     - Returns: An AKAudioFile, or nil if init failed.*/
    static public func silent(samples: Int64,
                              baseDir: BaseDirectory = .Temp,
                              name: String = "") throws -> AKAudioFile {
        
        if samples < 0 {
            print( "ERROR AKAudioFile: cannot create silent AKAUdioFile with negative samples count !")
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo:nil)
        } else if samples == 0 {
            let emptyFile = try AKAudioFile(writeIn: baseDir, name: name)
            // we return it as a file for reading
            return try AKAudioFile(forReading: emptyFile.url)
        }
        
        let array = [Float](count:Int(samples), repeatedValue: 0.0)
        let silentFile = try AKAudioFile(createFileFromFloats: [array, array], baseDir: baseDir, name: name)
        
        return try AKAudioFile(forReading: silentFile.url)
    }

}