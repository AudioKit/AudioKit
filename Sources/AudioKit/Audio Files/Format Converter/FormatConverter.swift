// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/**
 FormatConverter wraps the more complex AVFoundation and CoreAudio audio conversions in an easy to use format.
 ```swift
 let options = FormatConverter.Options()
 // any options left nil will assume the value of the input file
 options.format = "wav"
 options.sampleRate = 48000
 options.bitDepth = 24

 let converter = FormatConverter(inputURL: oldURL, outputURL: newURL, options: options)
 converter.start { error in
 // check to see if error isn't nil, otherwise you're good
 })
 ```
 */
public class FormatConverter {
    // MARK: - properties

    /// The source audio file
    public var inputURL: URL?


    /// The audio file to be created after conversion
    public var outputURL: URL?


    /// Options for conversion
    public var options: Options?

    // MARK: - private properties

    // The reader needs to exist outside the start func otherwise the async nature of the
    // AVAssetWriterInput will lose its reference
    var reader: AVAssetReader?
    var writer: AVAssetWriter?

    // MARK: - initialization

    /// init with input, output and options - then start()
    public init(inputURL: URL,
                outputURL: URL,
                options: Options? = nil) {
        self.inputURL = inputURL
        self.outputURL = outputURL
        self.options = options ?? Options()
    }

    deinit {
        reader = nil
        writer = nil
        inputURL = nil
        outputURL = nil
        options = nil
    }

    // MARK: - functions

    /// The entry point for file conversion
    /// - Parameter completionHandler: the callback that will be triggered when process has completed.
    public func start(completionHandler: FormatConverterCallback? = nil) {
        guard let inputURL = self.inputURL else {
            completionHandler?(Self.createError(message: "Input file can't be nil."))
            return
        }

        guard let outputURL = self.outputURL else {
            completionHandler?(Self.createError(message: "Output file can't be nil."))
            return
        }

        let inputFormat = inputURL.pathExtension.lowercased()
        // verify inputFormat, only allow files with path extensions for speed?
        guard FormatConverter.inputFormats.contains(inputFormat) else {
            completionHandler?(Self.createError(message: "The input file format is in an incompatible format: \(inputFormat)"))
            return
        }

        if FileManager.default.fileExists(atPath: outputURL.path) {
            if options?.eraseFile == true {
                Log("Warning: removing existing file at", outputURL.path)
                try? FileManager.default.removeItem(at: outputURL)
            } else {
                let message = "The output file exists already. You need to choose a unique URL or delete the file."
                completionHandler?(Self.createError(message: message))
                return
            }
        }

        if options?.format == nil {
            options?.format = outputURL.pathExtension.lowercased()
        }

        // Format checks are necessary as AVAssetReader has opinions about compressed

        // PCM output, any supported input
        if Self.isPCM(url: outputURL) == true {
            // PCM output
            convertToPCM(completionHandler: completionHandler)

            // PCM input, compressed output
        } else if Self.isPCM(url: inputURL) == true,
                  Self.isCompressed(url: outputURL) == true {
            convertPCMToCompressed(completionHandler: completionHandler)

            // Compressed input and output, won't do sample rate
        } else if Self.isCompressed(url: inputURL) == true,
                  Self.isCompressed(url: outputURL) == true {
            convertCompressed(completionHandler: completionHandler)

        } else {
            completionHandler?(Self.createError(message: "Unable to determine formats for conversion"))
        }
    }
}

// MARK: - Definitions

extension FormatConverter {
    /// FormatConverterCallback is the callback format for start()
    /// - Parameter: error This will contain one parameter of type Error which is nil if the conversion was successful.
    public typealias FormatConverterCallback = (_ error: Error?) -> Void

    /// Formats that this class can write
    public static let outputFormats = ["wav", "aif", "caf", "m4a"]

    /// Formats that this class can read
    public static let inputFormats = FormatConverter.outputFormats + [
        "mp3", "snd", "au", "sd2",
        "aif", "aiff", "aifc", "aac",
        "mp4", "m4v", "mov", "ts",
        "", // allow files with no extension. convertToPCM can still read the type
    ]

    /// An option to block upsampling to a higher bit depth than the source.
    /// For example, converting to 24bit from 16 doesn't have much benefit
    public enum BitDepthRule {
        /// For example: don't allow upsampling to 24bit if the src is 16
        case lessThanOrEqual

        /// allow any conversaion
        case any
    }

    /// The conversion options, leave any property nil to adopt the value of the input file
    public struct Options {
        /// Audio Format asw a string
        public var format: String?
        /// Sample Rate in Hertz
        public var sampleRate: Double?
        /// used only with PCM data
        public var bitDepth: UInt32?
        /// used only when outputting compressed audio
        public var bitRate: UInt32 = 128000 {
            didSet {
                // TODO: clamp valid range
                if bitRate < 64000 { bitRate = 64000 }
            }
        }

        /// An option to block upsampling to a higher bit depth than the source.
        /// default value is `.lessThanOrEqual`
        public var bitDepthRule: BitDepthRule = .lessThanOrEqual

        /// How many channels to convert to. Typically 1 or 2
        public var channels: UInt32?

        /// Maps to PCM Convertion format option `AVLinearPCMIsNonInterleaved`
        public var isInterleaved: Bool?

        /// Overwrite existing files, set false if you want to handle this before you call start()
        public var eraseFile: Bool = true

        /// Empty Initializer
        public init() {}

        /// Create options by parsing the contents of the url and using the audio settings
        /// in the file
        /// - Parameter url: The audio file to open and parse
        public init?(url: URL) {
            guard let avFile = try? AVAudioFile(forReading: url) else { return nil }
            self.init(audioFile: avFile)
        }

        /// Create options by parsing the audioFile for its settings
        /// - Parameter audioFile: an AVAudioFile to parse
        public init?(audioFile: AVAudioFile) {
            let streamDescription = audioFile.fileFormat.streamDescription.pointee

            format = audioFile.url.pathExtension
            // FormatConverter.formatIDToString(streamDescription.mFormatID)
            sampleRate = streamDescription.mSampleRate
            bitDepth = streamDescription.mBitsPerChannel
            channels = streamDescription.mChannelsPerFrame
        }

        /// Create PCM Options
        /// - Parameters:
        ///   - pcmFormat: wav, aif, or caf
        ///   - sampleRate: Sample Rate
        ///   - bitDepth: Bit Depth, or bits per channel
        ///   - channels: How many channels
        public init?(pcmFormat: String,
                     sampleRate: Double? = nil,
                     bitDepth: UInt32? = nil,
                     channels: UInt32? = nil) {
            format = pcmFormat
            self.sampleRate = sampleRate
            self.bitDepth = bitDepth
            self.channels = channels
        }
    }
}
