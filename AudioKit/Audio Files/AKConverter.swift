// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/**
 AKConverter wraps the more complex AVFoundation and CoreAudio audio conversions in an easy to use format.
 ```
 let options = AKConverter.Options()
 // any options left nil will assume the value of the input file
 options.format = "wav"
 options.sampleRate == 48000
 options.bitDepth = 24

 let converter = AKConverter(inputURL: oldURL, outputURL: newURL, options: options)
 converter.start { error in
 // check to see if error isn't nil, otherwise you're good
 })
 ```
 */

open class AKConverter: NSObject {
    /**
     AKConverterCallback is the callback format for start()
     -Parameter: error This will contain one parameter of type Error which is nil if the conversion was successful.
     */
    public typealias AKConverterCallback = (_ error: Error?) -> Void

    /** Formats that this class can write */
    public static let outputFormats = ["wav", "aif", "caf", "m4a"]

    /** Formats that this class can read */
    public static let inputFormats = AKConverter.outputFormats + [
        "mp3",
        "snd",
        "au",
        "sd2",
        "aiff",
        "aifc",
        "aac",
        "mp4",
        "m4v",
        "mov",
        "" // allow files with no extension. convertToPCM can still read the type
    ]

    /**
     The conversion options, leave nil to adopt the value of the input file
     */
    public struct Options {
        public init() {}
        public var format: String?
        public var sampleRate: Double?
        /// used only with PCM data
        public var bitDepth: UInt32?
        /// used only when outputting compressed from PCM - convertAsset()
        public var bitRate: UInt32 = 128_000 {
            didSet {
                if bitRate < 64_000 {
                    bitRate = 64_000
                }
            }
        }

        public var channels: UInt32?
        public var isInterleaved: Bool?
        /// overwrite existing files, set false if you want to handle this before you call start()
        public var eraseFile: Bool = true
    }

    // MARK: - public properties

    open var inputURL: URL?
    open var outputURL: URL?
    open var options: Options?

    // MARK: - private properties

    // The reader needs to exist outside the start func otherwise the async nature of the
    // AVAssetWriterInput will lose its reference
    internal var reader: AVAssetReader?
    internal var writer: AVAssetWriter?

    // MARK: - initialization

    /// init with input, output and options - then start()
    public init(inputURL: URL, outputURL: URL, options: Options? = nil) {
        self.inputURL = inputURL
        self.outputURL = outputURL
        self.options = options
    }

    deinit {
        // AKLog("* { AKConverter \(inputURL?.lastPathComponent ?? "?") }")
        reader = nil
        writer = nil
        inputURL = nil
        outputURL = nil
        options = nil
    }

    // MARK: - public functions

    /**
     The entry point for file conversion

     - Parameter completionHandler: the callback that will be triggered when process has completed.
     */
    open func start(completionHandler: AKConverterCallback? = nil) {
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
        guard AKConverter.inputFormats.contains(inputFormat) else {
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
