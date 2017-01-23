//
//  AKAudioFile.swift
//  AudioKit
//
//  Created by Laurent Veliscek, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

extension AVAudioCommonFormat: CustomStringConvertible {
    public var description: String {
        switch self {
        case .otherFormat:
            return "OtherFormat"
        case .pcmFormatFloat32 :
            return "PCMFormatFloat32"
        case .pcmFormatFloat64:
            return "PCMFormatFloat64"
        case .pcmFormatInt16:
            return "PCMFormatInt16"
        case .pcmFormatInt32:
            return "PCMFormatInt32"
        }
    }
}

extension AVAudioFile {

    // MARK: - Public Properties

    /// The number of samples can be accessed by .length property,
    /// but samplesCount has a less ambiguous meaning
    open var samplesCount: Int64 {
        return length
    }

    /// strange that sampleRate is a Double and not an Integer !...
    open var sampleRate: Double {
        return fileFormat.sampleRate
    }
    /// Number of channels, 1 for mono, 2 for stereo...
    open var channelCount: UInt32 {
        return fileFormat.channelCount
    }

    /// Duration in seconds
    open var duration: Double {
        return Double(samplesCount) / (sampleRate)
    }

    /// true if Audio Samples are interleaved
    open var interleaved: Bool {
        return fileFormat.isInterleaved
    }

    /// true only if file format is "deinterleaved native-endian float (AVAudioPCMFormatFloat32)"
    open var standard: Bool {
        return fileFormat.isStandard
    }

    /// Human-readable version of common format
    open var commonFormatString: String {
        return "\(fileFormat.commonFormat)"
    }

    /// the directory path as a URL object
    open var directoryPath: URL {
        return url.deletingLastPathComponent()
    }

    /// the file name with extension as a String
    open var fileNamePlusExtension: String {
        return url.lastPathComponent
    }

    /// the file name without extension as a String
    open var fileName: String {
        return url.deletingPathExtension().lastPathComponent
    }

    /// the file extension as a String (without ".")
    open var fileExt: String {
        return url.pathExtension
    }

    override open var description: String {
        return super.description + "\n" + String(describing: fileFormat)
    }

    /// returns file Mime Type if exists
    /// Otherwise, returns nil
    /// (useful when sending an AKAudioFile by email)
    public var mimeType: String? {
        switch fileExt.lowercased() {
        case "wav":
            return "audio/wav"
        case "caf":
            return "audio/x-caf"
        case "aif", "aiff", "aifc":
            return "audio/aiff"
        case "m4r":
            return "audio/x-m4r"
        case "m4a":
            return "audio/x-m4a"
        case "mp4":
            return "audio/mp4"
        case "m2a", "mp2":
            return "audio/mpeg"
        case "aac":
            return "audio/aac"
        case "mp3":
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

            AKLog("\(deletedFilesCount) files deleted")

        } catch let error as NSError {
            AKLog("Couldn't access Temp Directory")
            AKLog("Error: \(error)")
        }
    }

}

/// Audio file, inherits from AVAudioFile and adds functionality
open class AKAudioFile: AVAudioFile {

    // MARK: - embedded enums
    
    /// Common places for files
    ///
    /// - Temp:      Temp Directory
    /// - Documents: Documents Directory
    /// - Resources: Resources Directory (Shouldn't be used for writing / recording files)
    /// - Custom: The same directory as the input file. This is mainly for OS X projects.
    ///
    public enum BaseDirectory {
        /// Temporary directory
        case temp
        
        /// Documents directory
        case documents
        
        /// Resources directory
        case resources
        
        /// Same directory as the input file
        case custom

        func create(file path: String, write: Bool = false) throws -> String {
          switch (self, write) {
            case (.temp, _):
              return NSTemporaryDirectory() + path
            case (.documents, _):
              return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/" + path
            case (.resources, false):
              return try Bundle.main.path(forResource: path, ofType: "") ??
                         NSError.fileCreateError
            case (.custom, _):
              AKLog("ERROR AKAudioFile: custom creation directory not implemented yet")
              fallthrough
            default:
              throw NSError.fileCreateError
          }
        }
    }
    
    // MARK: - private vars
    
    // Used for exporting, can be accessed with public .avAsset property
    fileprivate lazy var internalAVAsset: AVURLAsset = {
        AVURLAsset(url: URL(fileURLWithPath: self.url.path))
    }()


    /// Returns an AVAsset from the AKAudioFile
    open var avAsset: AVURLAsset {
        return internalAVAsset
    }

    // Make our types Human Friendly™
    public typealias FloatChannelData = [[Float]]

    /// Returns audio data as an `Array` of `Float` Arrays.
    ///
    /// If stereo:
    /// - `floatChannelData?[0]` will contain an Array of left channel samples as `Float`
    /// - `floatChannelData?[1]` will contains an Array of right channel samples as `Float`
    open lazy var floatChannelData: FloatChannelData? = {
        // Do we have PCM channel data?
        guard let pcmFloatChannelData = self.pcmBuffer.floatChannelData else {
            return nil
        }

        let channelCount = Int(self.pcmBuffer.format.channelCount)
        let frameLength = Int(self.pcmBuffer.frameLength)
        let stride  = self.pcmBuffer.stride

        // Preallocate our Array so we're not constantly thrashing while resizing as we append.
        var result = Array(repeating: [Float](zeros: frameLength), count: channelCount)

        // Loop across our channels...
        for channel in 0..<channelCount {
            // Make sure we go through all of the frames...
            for sampleIndex in 0..<frameLength {
                result[channel][sampleIndex] = pcmFloatChannelData[channel][sampleIndex * stride]
            }
        }

        return result
    }()

    /// returns audio data as an AVAudioPCMBuffer
    open lazy var pcmBuffer: AVAudioPCMBuffer = {

        let buffer = AVAudioPCMBuffer(pcmFormat: self.processingFormat,
                                      frameCapacity: AVAudioFrameCount(self.length))

        do {
            try self.read(into: buffer)
        } catch let error as NSError {
            AKLog("error cannot readIntBuffer, Error: \(error)")
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
            return 10 * log10(maxLev)
        }
    }()
    
    /// Initialize the audio file
    ///
    /// - parameter fileURL: URL of the file
    ///
    /// - returns: An initialized AKAudioFile object for reading, or nil if init failed.
    ///
    public override init(forReading fileURL: URL) throws {
        try super.init(forReading: fileURL)
    }

    
    /// Initialize the audio file
    ///
    /// - Parameters:
    ///   - fileURL:     URL of the file
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
    ///   - fileURL:     URL of the file.
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
    ///   - fileURL: URL of the file.
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
