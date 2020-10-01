// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/**
 FormatConverter wraps the more complex AVFoundation and CoreAudio audio conversions in an easy to use format.
 ```
 let options = FormatConverter.Options()
 // any options left nil will assume the value of the input file
 options.format = "wav"
 options.sampleRate == 48000
 options.bitDepth = 24

 let converter = FormatConverter(inputURL: oldURL, outputURL: newURL, options: options)
 converter.start { error in
 // check to see if error isn't nil, otherwise you're good
 })
 ```
 */
open class FormatConverter: NSObject {
    /// FormatConverterCallback is the callback format for start()
    /// - Parameter: error This will contain one parameter of type Error which is nil if the conversion was successful.
    public typealias FormatConverterCallback = (_ error: Error?) -> Void

    /// Formats that this class can write
    public static let outputFormats = ["wav", "aif", "caf", "m4a"]

    /// Formats that this class can read
    public static let inputFormats = FormatConverter.outputFormats + [
        "mp3",
        "snd",
        "au",
        "sd2",
        "aif",
        "aiff",
        "aifc",
        "aac",
        "mp4",
        "m4v",
        "mov",
        "" // allow files with no extension. convertToPCM can still read the type
    ]

    /// The conversion options, leave nil to adopt the value of the input file
    public struct Options {
        /// String format
        public var format: String?
        /// Sample Rate
        public var sampleRate: Double?
        /// Bit depth, used only with PCM data
        public var bitDepth: UInt32?
        /// Bit rate, used only when outputting compressed m4a from PCM - convertAsset()
        public var bitRate: UInt32 = 128_000 {
            didSet {
                if bitRate < 64_000 {
                    bitRate = 64_000
                }
            }
        }

        /// Channel count
        public var channels: UInt32?
        /// Is the format interleaved
        public var isInterleaved: Bool?
        /// overwrite existing files, set false if you want to handle this before you call start()
        public var eraseFile: Bool = true

        /// Empty initializer
        public init() {}

        /// Initialize with URL
        /// - Parameter url: URL for the file ot read
        public init?(url: URL) {
            guard let avFile = try? AVAudioFile(forReading: url) else { return nil }
            self.init(audioFile: avFile)
        }

        /// Initialize with a file
        /// - Parameter audioFile: Audio file to load
        public init?(audioFile: AVAudioFile) {
            let streamDescription = audioFile.fileFormat.streamDescription.pointee

            format = audioFile.url.pathExtension
            // FormatConverter.formatIDToString(streamDescription.mFormatID)
            sampleRate = streamDescription.mSampleRate
            bitDepth = streamDescription.mBitsPerChannel
            channels = streamDescription.mChannelsPerFrame

            Log(streamDescription)
        }
    }

    // MARK: - public properties

    /// URL of the input
    open var inputURL: URL?
    /// URL of the output
    open var outputURL: URL?
    /// Format conversion ptions
    open var options: Options?

    // MARK: - private properties

    // The reader needs to exist outside the start func otherwise the async nature of the
    // AVAssetWriterInput will lose its reference
    internal var reader: AVAssetReader?
    internal var writer: AVAssetWriter?

    // MARK: - initialization

    /// Initialize with input, output and options
    /// - Parameters:
    ///   - inputURL: Input URL
    ///   - outputURL: Output URL
    ///   - options: Format conversion options
    public init(inputURL: URL, outputURL: URL, options: Options? = nil) {
        self.inputURL = inputURL
        self.outputURL = outputURL
        self.options = options
    }

    deinit {
        // Log("* { FormatConverter \(inputURL?.lastPathComponent ?? "?") }")
        reader = nil
        writer = nil
        inputURL = nil
        outputURL = nil
        options = nil
    }

    // MARK: - public functions

    /// The entry point for file conversion
    /// - Parameter completionHandler: the callback that will be triggered when process has completed.
    public func start(completionHandler: FormatConverterCallback? = nil) {
        guard let inputURL = self.inputURL else {
            completionHandler?(createError(message: "Input file can't be nil."))
            return
        }

        guard let outputURL = self.outputURL else {
            completionHandler?(createError(message: "Output file can't be nil."))
            return
        }

        let inputFormat = inputURL.pathExtension.lowercased()
        // verify inputFormat
        guard FormatConverter.inputFormats.contains(inputFormat) else {
            completionHandler?(createError(message: "The input file format isn't able to be processed."))
            return
        }

        // Format checks are necessary as AVAssetReader has opinions about compressed audio for some reason
        if isCompressed(url: inputURL), isCompressed(url: outputURL) {
            // Compressed input and output
            convertCompressed(completionHandler: completionHandler)

        } else if !isCompressed(url: outputURL) {
            // PCM output
            convertToPCM(completionHandler: completionHandler)

        } else {
            // PCM input, compressed output
            convertAsset(completionHandler: completionHandler)
        }
    }
}
