//
//  AKAudioFile.swift
//  AudioKit
//
//  Created by Laurent Veliscek, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Audio file, inherits from AVAudioFile and adds functionality
open class AKAudioFile: AVAudioFile {

    // MARK: - embedded enums
    
    /// Common places for files
    ///
    /// - Temp:      Temp Directory
    /// - Documents: Documents Directory
    /// - Resources: Resources Directory (Shouldn't be used for writing / recording files)
    ///
    public enum BaseDirectory {
        /// Temporary directory
        case temp
        
        /// Documents directory
        case documents
        
        /// Resources directory
        case resources
    }
    
    // MARK: - private vars
    
    // Used for exporting, can be accessed with public .avAsset property
    fileprivate lazy var internalAVAsset: AVURLAsset = {
        AVURLAsset(url: URL(fileURLWithPath: self.url.path))
    }()


    // MARK: - Public Properties

    /// The number of samples can be accessed by .length property,
    /// but samplesCount has a less ambiguous meaning
    open var samplesCount: Int64 {
        get {
            return self.length
        }
    }

    /// strange that sampleRate is a Double and not an Integer !...
    open var sampleRate: Double {
        get {
            return self.fileFormat.sampleRate
        }
    }
    /// Number of channels, 1 for mono, 2 for stereo...
    open var channelCount: UInt32 {
        get {
            return self.fileFormat.channelCount
        }
    }

    /// Duration in seconds
    open var duration: Double {
        get {
            return Double(samplesCount) / (sampleRate)
        }
    }

    /// true if Audio Samples are interleaved
    open var interleaved: Bool {
        get {
            return self.fileFormat.isInterleaved
        }
    }

    /// true only if file format is "deinterleaved native-endian float (AVAudioPCMFormatFloat32)"
    open var standard: Bool {
        get {
            return self.fileFormat.isStandard
        }
    }

    /*  commonFormatString translates commonFormat in an human readable string.
     enum AVAudioCommonFormat : UInt {
     case OtherFormat
     case PCMFormatFloat32
     case PCMFormatFloat64
     case PCMFormatInt16
     case PCMFormatInt32
     }  */

    /// Human-readable version of common format
    open var commonFormatString: String {
        get {

            switch self.fileFormat.commonFormat.rawValue {
            case 1 :
                return "PCMFormatFloat32"
            case 2:
                return "PCMFormatFloat64"
            case 3 :
                return "PCMFormatInt16"
            case 4:
                return "PCMFormatInt32"
            default :
                return "OtherFormat"
            }
        }
    }

    /// the directory path as a NSURL object
    open var directoryPath: URL {
        get {
            return self.url.deletingLastPathComponent()
        }
    }

    /// the file name with extension as a String
    open var fileNamePlusExtension: String {
        get {
            return self.url.lastPathComponent
        }
    }

    /// the file name without extension as a String
    open var fileName: String {
        get {
            return (self.url.deletingPathExtension().lastPathComponent)
        }
    }

    /// the file extension as a String (without ".")
    open var fileExt: String {
        get {
            return (self.url.pathExtension)
        }
    }

    /// Returns an AVAsset from the AKAudioFile
    open var avAsset: AVURLAsset {
        return internalAVAsset
    }

    /// As The description doesn't provide so much informations, appended the fileFormat.
    override open var description: String {
        get {
            return super.description + "\n" + String(describing: self.fileFormat)
        }
    }

    /// returns audio data as an Array of float Arrays
    /// If stereo:
    ///     - arraysOfFloats[0] will contain an Array of left channel samples as Floats
    ///     - arraysOfFloats[1] will contains an Array of right channel samples as Floats
    open lazy var arraysOfFloats: [[Float]] = {
        var arrays: [[Float]] = []

        if self.samplesCount > 0 {
            let buf = self.pcmBuffer

            for channel in 0..<self.channelCount {
                let floatArray = Array(UnsafeBufferPointer(start: buf.floatChannelData?[Int(channel)], count:Int(buf.frameLength)))
                arrays.append(floatArray)
            }
        } else {
            print("Warning AKAudioFile arraysOfFloats: self.samplesCount = 0")
        }

        return arrays
    }()


    /// returns audio data as an AVAudioPCMBuffer
    open lazy var pcmBuffer: AVAudioPCMBuffer = {

        let buffer =  AVAudioPCMBuffer(pcmFormat: self.processingFormat, frameCapacity: (AVAudioFrameCount( self.length)))

        do {
            try self.read(into: buffer)
        } catch let error as NSError {
            print("error cannot readIntBuffer, Error: \(error)")
        }

        return buffer

    }()

    ///
    /// returns the peak level expressed in dB ( -> Float).
    open lazy var maxLevel: Float = {
        var maxLev: Float = 0

        let buffer = self.pcmBuffer

        if self.samplesCount > 0 {
            for c in 0..<Int(self.channelCount) {
                let floats = UnsafeBufferPointer(start: buffer.floatChannelData?[c], count:Int(buffer.frameLength))
                let cmax = floats.max()
                let cmin = floats.min()

                // positive max
                if cmax != nil {
                    maxLev  = max(cmax!, maxLev)
                }

                // negative max
                if cmin != nil {
                    maxLev  = max(abs(cmin!), maxLev)
                }
            }
        }

        if maxLev == 0 {
            return FLT_MIN
        } else {
            return (10 * log10(maxLev))
        }
    }()
    
    /// Initialize the audio file
    ///
    /// - parameter fileURL: NSURL of the file
    ///
    /// - returns: An initialized AKAudioFile object for reading, or nil if init failed.
    ///
    public override init(forReading fileURL: URL) throws {
        try super.init(forReading: fileURL)
    }

    
    /// Initialize the audio file
    ///
    /// - Parameters:
    ///   - fileURL:     NSURL of the file
    ///   - format:      The processing commonFormat to use when reading from the file.
    ///   - interleaved: Whether to use an interleaved processing format.
    ///
    /// - returns: An initialized AKAudioFile object for reading, or nil if init failed.
    ///
    public override init(forReading fileURL: URL,
                                    commonFormat format: AVAudioCommonFormat,
                                                 interleaved: Bool) throws {
        
        try super.init(forReading: fileURL, commonFormat: format, interleaved: interleaved)
    }
    

    /// Initialize the audio file
    ///
    /// From Apple doc: The file type to create is inferred from the file extension of fileURL.
    /// This method will overwrite a file at the specified URL if a file already exists.
    ///
    /// The file is opened for writing using the standard format, AVAudioPCMFormatFloat32.
    ///
    /// Note: It seems that Apple's AVAudioFile class has a bug with .wav files. They cannot be set
    /// with a floating Point encoding. As a consequence, such files will fail to record properly.
    /// So it's better to use .caf (or .aif) files for recording purpose.
    ///
    /// - Parameters:
    ///   - fileURL:     NSURL of the file.
    ///   - settings:    The format of the file to create.
    ///   - format:      The processing commonFormat to use when writing.
    ///   - interleaved: Whether to use an interleaved processing format.
    /// - throws: NSError if init failed
    /// - returns: An initialized AKAudioFile for writing, or nil if init failed.
    ///
    public override init(forWriting fileURL: URL,
                                    settings: [String : Any],
                                    commonFormat format: AVAudioCommonFormat,
                                                 interleaved: Bool) throws {
        try super.init(forWriting: fileURL,
                       settings: settings,
                       commonFormat: format,
                       interleaved: interleaved)
    }
    
    
    /// Super.init inherited from AVAudioFile superclass
    ///
    /// - Parameters:
    ///   - fileURL: NSURL of the file.
    ///   - settings: The settings of the file to create.
    ///
    /// - Returns: An initialized AKAudioFile for writing, or nil if init failed.
    ///
    /// From Apple doc: The file type to create is inferred from the file extension of fileURL.
    /// This method will overwrite a file at the specified URL if a file already exists.
    ///
    /// The file is opened for writing using the standard format, AVAudioPCMFormatFloat32.
    ///
    /// Note: It seems that Apple's AVAudioFile class has a bug with .wav files. They cannot be set
    /// with a floating Point encoding. As a consequence, such files will fail to record properly.
    /// So it's better to use .caf (or .aif) files for recording purpose.
    ///
    public override init(forWriting fileURL: URL, settings: [String:Any]) throws {
        try super.init(forWriting: fileURL, settings: settings)
    }
}
