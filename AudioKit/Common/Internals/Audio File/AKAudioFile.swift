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
public class AKAudioFile: AVAudioFile {

    // MARK: - embedded enums
    
    /// Common places for files
    ///
    /// - Temp:      Temp Directory
    /// - Documents: Documents Directory
    /// - Resources: Resources Directory (Shouldn't be used for writing / recording files)
    ///
    public enum BaseDirectory {
        /// Temporary directory
        case Temp
        
        /// Documents directory
        case Documents
        
        /// Resources directory
        case Resources
    }
    
    // MARK: - private vars
    
    // Used for exporting, can be accessed with public .avAsset property
    private lazy var internalAVAsset: AVURLAsset = {
        let avAssetUrl = NSURL(fileURLWithPath: self.url.absoluteString)
        return  AVURLAsset(URL: avAssetUrl)
    }()


    // MARK: - Public Properties

    /// The number of samples can be accessed by .length property,
    /// but samplesCount has a less ambiguous meaning
    public var samplesCount: Int64 {
        get {
            return self.length
        }
    }

    /// strange that sampleRate is a Double and not an Integer !...
    public var sampleRate: Double {
        get {
            return self.fileFormat.sampleRate
        }
    }
    /// Number of channels, 1 for mono, 2 for stereo...
    public var channelCount: UInt32 {
        get {
            return self.fileFormat.channelCount
        }
    }

    /// Duration in seconds
    public var duration: Double {
        get {
            return Double(samplesCount) / (sampleRate)
        }
    }

    /// true if Audio Samples are interleaved
    public var interleaved: Bool {
        get {
            return self.fileFormat.interleaved
        }
    }

    /// true only if file format is "deinterleaved native-endian float (AVAudioPCMFormatFloat32)"
    public var standard: Bool {
        get {
            return self.fileFormat.standard
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
    public var commonFormatString: String {
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
    public var directoryPath: NSURL {
        get {
            return self.url.URLByDeletingLastPathComponent!
        }
    }

    /// the file name with extension as a String
    public var fileNamePlusExtension: String {
        get {
            return self.url.lastPathComponent!
        }
    }

    /// the file name without extension as a String
    public var fileName: String {
        get {
            return (self.url.URLByDeletingPathExtension?.lastPathComponent!)!
        }
    }

    /// the file extension as a String (without ".")
    public var fileExt: String {
        get {
            return (self.url.pathExtension!)
        }
    }

    /// Returns an AVAsset from the AKAudioFile
    public var avAsset: AVURLAsset {
        return internalAVAsset
    }

    /// As The description doesn't provide so much informations, appended the fileFormat.
    override public var description: String {
        get {
            return super.description + "\n" + String(self.fileFormat)
        }
    }

    /// returns audio data as an Array of float Arrays
    /// If stereo:
    ///     - arraysOfFloats[0] will contain an Array of left channel samples as Floats
    ///     - arraysOfFloats[1] will contains an Array of right channel samples as Floats
    public lazy var arraysOfFloats: [[Float]] = {
        var arrays: [[Float]] = []

        if self.samplesCount > 0 {
            let buf = self.pcmBuffer

            for channel in 0..<self.channelCount {
                let floatArray = Array(UnsafeBufferPointer(start: buf.floatChannelData[Int(channel)], count:Int(buf.frameLength)))
                arrays.append(floatArray)
            }
        } else {
            print("Warning AKAudioFile arraysOfFloats: self.samplesCount = 0")
        }

        return arrays
    }()


    /// returns audio data as an AVAudioPCMBuffer
    public lazy var pcmBuffer: AVAudioPCMBuffer = {

        let buffer =  AVAudioPCMBuffer(PCMFormat: self.processingFormat, frameCapacity: (AVAudioFrameCount( self.length)))

        do {
            try self.readIntoBuffer(buffer)
        } catch let error as NSError {
            print("error cannot readIntBuffer, Error: \(error)")
        }

        return buffer

    }()

    ///
    /// returns the peak level expressed in dB ( -> Float).
    public lazy var maxLevel: Float = {
        var maxLev: Float = 0

        let buffer = self.pcmBuffer

        if self.samplesCount > 0 {
            for c in 0..<Int(self.channelCount) {
                let floats = UnsafeBufferPointer(start: buffer.floatChannelData[c], count:Int(buffer.frameLength))
                let cmax = floats.maxElement()
                let cmin = floats.minElement()

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
    public override init(forReading fileURL: NSURL) throws {
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
    public override init(forReading fileURL: NSURL,
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
    public override init(forWriting fileURL: NSURL,
                                    settings: [String : AnyObject],
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
    public override init(forWriting fileURL: NSURL, settings: [String:AnyObject]) throws {
        try super.init(forWriting: fileURL, settings: settings)
    }
}
