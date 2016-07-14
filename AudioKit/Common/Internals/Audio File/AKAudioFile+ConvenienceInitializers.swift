//
//  AKAudioFile+ConvenienceInitializers.swift
//  AudioKit For iOS
//
//  Created by Aurelius Prochazka and Laurent Veliscek on 7/4/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

extension AKAudioFile {

    /**
     Opens a file for reading.
     
     - Parameters:
     - name: the name of the file without its extension (String).
     - baseDir: where the file is located, can be set to .Resources,  .Documents or .Temp
     
     - Throws: NSError if init failed .
     
     - Returns: An initialized AKAudioFile for reading, or nil if init failed.
     
     */
    public convenience init(readFileName name: String,
                                         baseDir: BaseDirectory = .Resources) throws {
        
        let filePath: String
        let fileNameWithExtension = name
        
        switch baseDir {
        case .Temp:
            filePath =  (NSTemporaryDirectory() as String) + name
        case .Documents:
            filePath =  (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]) + "/" + name
        case .Resources:
            func resourcePath(name: String?) -> String? {
                return NSBundle.mainBundle().pathForResource(name, ofType: "")
            }
            let path =  resourcePath(name)
            if path == nil {
                print( "ERROR: AKAudioFile cannot find \"\(name)\" in resources!...")
                throw NSError(domain: NSURLErrorDomain, code: NSURLErrorFileDoesNotExist, userInfo: nil)
            }
            filePath = path!
            
        }
        let fileUrl = NSURL(fileURLWithPath: filePath)
        do {
            try self.init(forReading: fileUrl)
        } catch let error as NSError {
            print ("Error !!! AKAudioFile: \"\(name)\" doesn't seem to be a valid AudioFile !...")
            print(error.localizedDescription)
            throw error
        }
        
        
    }

    /**
     Creates file for recording / writing purpose
     Default is a .caf AKAudioFile with AudioKit settings
     If file name is an empty String, a unique Name will be set
     If no baseDir is set, baseDir will be the Temp Directory
     
     
     - Parameters:
     - name: the name of the file without its extension (String).
     - ext: the extension of the file without "." (String).
     - baseDir: where the file will be located, can be set to .Resources,  .Documents or .Temp
     - settings: The settings of the file to create.
     - format: The processing commonFormat to use when writing.
     - interleaved: Bool (Whether to use an interleaved processing format.)
     
     
     - Throws: NSError if init failed .
     
     - Returns: An initialized AKAudioFile for writing, or nil if init failed.
     
     From Apple doc: The file type to create is inferred from the file extension of fileURL.
     This method will overwrite a file at the specified URL if a file already exists.
     
     Note: It seems that Apple's AVAudioFile class has a bug with .wav files. They cannot be set
     with a floating Point encoding. As a consequence, such files will fail to record properly.
     So it's better to use .caf (or .aif) files for recording purpose.
     
     Example of use: to create a temp .caf file with a unique name for recording:
     let recordFile = AKAudioFile()
     
     */
    public convenience init(writeIn baseDir: BaseDirectory = .Temp,
                                    name: String = "") throws {
        
        let fileNameWithExtension: String
        // Create a unique file name if fileName == ""
        if name == "" {
            fileNameWithExtension =  NSUUID().UUIDString + ".caf"
        } else {
            fileNameWithExtension = name + ".caf"
        }
        
        var filePath: String
        switch baseDir {
        case .Temp:
            filePath =  (NSTemporaryDirectory() as String) + "/" + fileNameWithExtension
        case .Documents:
            filePath =  (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]) + "/" + fileNameWithExtension
        case .Resources:
            print( "ERROR AKAudioFile: cannot create a file in applications resources!...")
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil)
        }
        
        let nsurl = NSURL(string: filePath)
        guard nsurl != nil else {
            print( "ERROR AKAudioFile: directory \"\(filePath)\" isn't valid!...")
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil)
        }
        
        // Directory exists ?
        let directoryPath = nsurl!.URLByDeletingLastPathComponent
        
        let fileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath((directoryPath?.absoluteString)!) == false {
            print( "ERROR AKAudioFile: directory \"\(directoryPath)\" doesn't exists!...")
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil)
        }
        
        // AVLinearPCMIsNonInterleaved cannot be set to false (ignored but throw a warning)
        var  fixedSettings =  AKSettings.audioFormat.settings
        
        fixedSettings[ AVLinearPCMIsNonInterleaved] =  NSNumber(bool: false)
        
        do {
            try self.init(forWriting: nsurl!, settings: fixedSettings)
        } catch let error as NSError {
            print( "ERROR AKAudioFile: Couldn't create an AKAudioFile...")
            print( "Error: \(error)")
            throw NSError(domain: NSURLErrorDomain, code: NSURLErrorCannotCreateFile, userInfo: nil)
        }
    }
    
    /**
     Convenience init to instantiate a file from Floats Arrays.
     To create a stereo file, you pass [leftChannelFloats, rightChannelFloats]
     where leftChannelFloats and rightChannelFloats are 2 arrays of FLoat values.
     Arrays must both have the same number of Floats.
     
     - Parameters:
     - floatsArrays:[[Float]] An array of Arrays of floats
     - name: the name of the file without its extension (String).
     - baseDir: where the file will be located, can be set to .Resources,  .Documents or .Temp
     
     - Throws: NSError if failed .
     
     Returns a .caf AKAudioFile set to AudioKit settings (32 bits float @ 44100 Hz)
     */
    public convenience init(createFileFromFloats floatsArrays: [[Float]],
                                                 baseDir: BaseDirectory = .Temp,
                                                 name: String = "") throws {
        
        let channelCount = floatsArrays.count
        var fixedSettings = AKSettings.audioFormat.settings
        
        fixedSettings[AVNumberOfChannelsKey] = channelCount
        
        try self.init(writeIn: baseDir, name: name)
        
        
        // create buffer for floats
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: AVAudioChannelCount (channelCount))
        let buffer = AVAudioPCMBuffer(PCMFormat: format, frameCapacity:  AVAudioFrameCount(floatsArrays[0].count))
        
        // Fill the buffers
        
        for channel in 0..<channelCount {
            let channelNData = buffer.floatChannelData[channel]
            for f in 0..<Int(buffer.frameCapacity) {
                channelNData[f] = floatsArrays[channel][f]
            }
        }
        
        // set the buffer frameLength
        buffer.frameLength = buffer.frameCapacity
        
        // Write the buffer in file
        do {
            try self.writeFromBuffer(buffer)
        } catch let error as NSError {
            print( "ERROR AKAudioFile: cannot writeFromBuffer Error: \(error)")
            throw error
        }
        
    }
    
    /**
     Convenience init to instantiate a file from an AVAudioPCMBuffer.
     
     - Parameters:
     - buffer: the :AVAudioPCMBuffer that will be used to fill the AKAudioFile
     - name: the name of the file without its extension (String).
     - baseDir: where the file will be located, can be set to .Resources,  .Documents or .Temp
     
     - Throws: NSError if failed .
     
     Returns a .caf AKAudioFile set to AudioKit settings (32 bits float @ 44100 Hz)
     */
    
    public convenience init(fromAVAudioPCMBuffer buffer: AVAudioPCMBuffer,
                                                 baseDir: BaseDirectory = .Temp,
                                                 name: String = "") throws {
        
        try self.init(writeIn: baseDir,
                      name: name)
        
        // Write the buffer in file
        do {
            try self.writeFromBuffer(buffer)
        } catch let error as NSError {
            print( "ERROR AKAudioFile: cannot writeFromBuffer Error: \(error)")
            throw error
        }
        
    }
}
