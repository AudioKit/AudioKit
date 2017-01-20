//
//  AKAudioFile+ConvenienceInitializers.swift
//  AudioKit
//
//  Created by Laurent Veliscek, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

extension AKAudioFile {
    
    /// Opens a file for reading.
    ///
    /// - parameter name:    Filename, including the extension
    /// - parameter baseDir: Location of file, can be set to .resources, .documents or .temp
    ///
    /// - returns: An initialized AKAudioFile for reading, or nil if init failed
    ///
    public convenience init(readFileName name: String,
                            baseDir: BaseDirectory = .resources) throws {
        
        let filePath: String
        
        switch baseDir {
        case .temp:
            filePath =  (NSTemporaryDirectory() as String) + name
        case .documents:
            filePath =  (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]) + "/" + name
        case .resources:
            func resourcePath(_ name: String?) -> String? {
                return Bundle.main.path(forResource: name, ofType: "")
            }
            let path = resourcePath(name)
            if path == nil {
                AKLog("ERROR: AKAudioFile cannot find \"\(name)\" in resources")
                throw NSError(domain: NSURLErrorDomain, code: NSURLErrorFileDoesNotExist, userInfo: nil)
            }
            filePath = path!
        case .custom:
            AKLog("ERROR AKAudioFile: custom creation directory not implemented yet")
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil)
            
        }
        let fileURL = URL(fileURLWithPath: filePath)
        do {
            try self.init(forReading: fileURL)
        } catch let error as NSError {
            AKLog("Error: AKAudioFile: \"\(name)\" doesn't seem to be a valid AudioFile")
            AKLog(error.localizedDescription)
            throw error
        }
        
        
    }
    
    
    /// Initialize file for recording / writing purpose
    ///
    /// Default is a .caf AKAudioFile with AudioKit settings
    /// If file name is an empty String, a unique Name will be set
    /// If no baseDir is set, baseDir will be the Temp Directory
    ///
    /// From Apple doc: The file type to create is inferred from the file extension of fileURL.
    /// This method will overwrite a file at the specified URL if a file already exists.
    ///
    /// Note: It seems that Apple's AVAudioFile class has a bug with .wav files. They cannot be set
    /// with a floating Point encoding. As a consequence, such files will fail to record properly.
    /// So it's better to use .caf (or .aif) files for recording purpose.
    ///
    /// Example of use: to create a temp .caf file with a unique name for recording:
    /// let recordFile = AKAudioFile()
    ///
    /// - Parameters:
    ///   - name: the name of the file without its extension (String).
    ///   - ext: the extension of the file without "." (String).
    ///   - baseDir: where the file will be located, can be set to .resources, .documents or .temp
    ///   - settings: The settings of the file to create.
    ///   - format: The processing commonFormat to use when writing.
    ///   - interleaved: Bool (Whether to use an interleaved processing format.)
    ///
    public convenience init(writeIn baseDir: BaseDirectory = .temp,
                            name: String = "",
                            settings: [String : Any] = AKSettings.audioFormat.settings)
        throws {
            
            let fileNameWithExtension: String
            // Create a unique file name if fileName == ""
            if name == "" {
                fileNameWithExtension =  UUID().uuidString + ".caf"
            } else {
                fileNameWithExtension = name + ".caf"
            }
            
            var filePath: String
            switch baseDir {
            case .temp:
                filePath =  (NSTemporaryDirectory() as String) + fileNameWithExtension
            case .documents:
                filePath =  (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]) + "/" + fileNameWithExtension
            case .resources:

                AKLog("ERROR AKAudioFile: cannot create a file in applications resources")
                throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil)
            case .custom:
                AKLog("ERROR AKAudioFile: custom creation directory not implemented yet")
                throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil)
            }
            
            let nsurl = URL(string: filePath)
            guard nsurl != nil else {
                AKLog("ERROR AKAudioFile: directory \"\(filePath)\" isn't valid")
                throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil)
            }
            
            // Directory exists ?
            let directoryPath = nsurl!.deletingLastPathComponent()
            
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: (directoryPath.absoluteString)) {
                AKLog("ERROR AKAudioFile: directory \"\(directoryPath)\" doesn't exist")
                throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil)
            }
            
            // AVLinearPCMIsNonInterleaved cannot be set to false (ignored but throw a warning)
            var  fixedSettings =  settings
            
            fixedSettings[AVLinearPCMIsNonInterleaved] = NSNumber(value: false)
            
            do {
                try self.init(forWriting: nsurl!, settings: fixedSettings)
            } catch let error as NSError {
                AKLog("ERROR AKAudioFile: Couldn't create an AKAudioFile...")
                AKLog("Error: \(error)")
                throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil)
            }
    }
    
    
    /// Instantiate a file from Floats Arrays.
    ///
    /// To create a stereo file, you pass [leftChannelFloats, rightChannelFloats]
    /// where leftChannelFloats and rightChannelFloats are 2 arrays of FLoat values.
    /// Arrays must both have the same number of Floats.
    ///
    /// - Parameters:
    ///   - floatsArrays: An array of Arrays of floats
    ///   - name: the name of the file without its extension (String).
    ///   - baseDir: where the file will be located, can be set to .Resources,  .Documents or .Temp
    ///
    /// - Returns: a .caf AKAudioFile set to AudioKit settings (32 bits float @ 44100 Hz)
    ///
    public convenience init(createFileFromFloats floatsArrays: [[Float]],
                            baseDir: BaseDirectory = .temp,
                            name: String = "") throws {
        
        let channelCount = floatsArrays.count
        var fixedSettings = AKSettings.audioFormat.settings
        
        fixedSettings[AVNumberOfChannelsKey] = channelCount
        
        try self.init(writeIn: baseDir, name: name)
        
        
        // create buffer for floats
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100,
                                   channels: AVAudioChannelCount (channelCount))
        let buffer = AVAudioPCMBuffer(pcmFormat: format,
                                      frameCapacity:  AVAudioFrameCount(floatsArrays[0].count))
        
        // Fill the buffers
        
        for channel in 0..<channelCount {
            let channelNData = buffer.floatChannelData?[channel]
            for f in 0..<Int(buffer.frameCapacity) {
                channelNData?[f] = floatsArrays[channel][f]
            }
        }
        
        // set the buffer frameLength
        buffer.frameLength = buffer.frameCapacity
        
        // Write the buffer in file
        do {
            try self.write(from: buffer)
        } catch let error as NSError {
            AKLog("ERROR AKAudioFile: cannot writeFromBuffer Error: \(error)")
            throw error
        }
        
    }
    
    
    /// Convenience init to instantiate a file from an AVAudioPCMBuffer.
    ///
    /// - Parameters:
    ///   - buffer: the :AVAudioPCMBuffer that will be used to fill the AKAudioFile
    ///   - baseDir: where the file will be located, can be set to .resources, .documents or .temp
    ///   - name: the name of the file without its extension (String).
    ///
    /// - Returns: a .caf AKAudioFile set to AudioKit settings (32 bits float @ 44100 Hz)
    ///
    public convenience init(fromAVAudioPCMBuffer buffer: AVAudioPCMBuffer,
                            baseDir: BaseDirectory = .temp,
                            name: String = "") throws {
        
        try self.init(writeIn: baseDir,
                      name: name)
        
        // Write the buffer in file
        do {
            try self.write(from: buffer)
        } catch let error as NSError {
            AKLog("ERROR AKAudioFile: cannot writeFromBuffer Error: \(error)")
            throw error
        }
        
    }
}
