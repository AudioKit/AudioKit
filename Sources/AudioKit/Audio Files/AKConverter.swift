// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

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
    /// AKConverterCallback is the callback format for start()
    /// - Parameter: error This will contain one parameter of type Error which is nil if the conversion was successful.
    public typealias AKConverterCallback = (_ error: Error?) -> Void

    /// Formats that this class can write
    public static let outputFormats = ["wav", "aif", "caf", "m4a"]

    /// Formats that this class can read
    public static let inputFormats = AKConverter.outputFormats + [
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
        public var format: String?
        public var sampleRate: Double?
        /// used only with PCM data
        public var bitDepth: UInt32?
        /// used only when outputting compressed m4a from PCM - convertAsset()
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

        // Init

        public init() {}

        public init?(url: URL) {
            guard let avFile = try? AVAudioFile(forReading: url) else { return nil }
            self.init(audioFile: avFile)
        }

        public init?(audioFile: AVAudioFile) {
            let streamDescription = audioFile.fileFormat.streamDescription.pointee

            format = audioFile.url.pathExtension
            // AKConverter.formatIDToString(streamDescription.mFormatID)
            sampleRate = streamDescription.mSampleRate
            bitDepth = streamDescription.mBitsPerChannel
            channels = streamDescription.mChannelsPerFrame

            AKLog(streamDescription)
        }
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

    /// The entry point for file conversion
    /// - Parameter completionHandler: the callback that will be triggered when process has completed.
    public func start(completionHandler: AKConverterCallback? = nil) {
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

extension AKConverter {
    /**
     @enum Audio File Types
     @abstract   Constants for the built-in audio file types.
     @discussion These constants are used to indicate the type of file to be written, or as a hint to
                     what type of file to expect from data provided.
     @constant   kAudioFileAIFFType
                     Audio Interchange File Format (AIFF)
     @constant   kAudioFileAIFCType
                     Audio Interchange File Format Compressed (AIFF-C)
     @constant   kAudioFileWAVEType
                     Microsoft WAVE
     @constant   kAudioFileRF64Type
                     File Format specified in EBU Tech 3306
     @constant   kAudioFileSoundDesigner2Type
                     Sound Designer II
     @constant   kAudioFileNextType
                     NeXT / Sun
     @constant   kAudioFileMP3Type
                     MPEG Audio Layer 3 (.mp3)
     @constant   kAudioFileMP2Type
                     MPEG Audio Layer 2 (.mp2)
     @constant   kAudioFileMP1Type
                     MPEG Audio Layer 1 (.mp1)
     @constant   kAudioFileAC3Type
                     AC-3
     @constant   kAudioFileAAC_ADTSType
                     Advanced Audio Coding (AAC) Audio Data Transport Stream (ADTS)
     @constant   kAudioFileMPEG4Type
     @constant   kAudioFileM4AType
     @constant   kAudioFileM4BType
     @constant   kAudioFileCAFType
                     CoreAudio File Format
     @constant   kAudioFile3GPType
     @constant   kAudioFile3GP2Type
     @constant   kAudioFileAMRType
     @constant   kAudioFileFLACType
                     Free Lossless Audio Codec
     @constant   kAudioFileLATMInLOASType
                     Low-overhead audio stream with low-overhead audio transport multiplex, per ISO/IEC 14496-3.
                     Support is limited to AudioSyncStream using AudioMuxElement with mux config present.
     */
    /**
     public var kAudioFormatLinearPCM: AudioFormatID { get }
     public var kAudioFormatAC3: AudioFormatID { get }
     public var kAudioFormat60958AC3: AudioFormatID { get }
     public var kAudioFormatAppleIMA4: AudioFormatID { get }
     public var kAudioFormatMPEG4AAC: AudioFormatID { get }
     public var kAudioFormatMPEG4CELP: AudioFormatID { get }
     public var kAudioFormatMPEG4HVXC: AudioFormatID { get }
     public var kAudioFormatMPEG4TwinVQ: AudioFormatID { get }
     public var kAudioFormatMACE3: AudioFormatID { get }
     public var kAudioFormatMACE6: AudioFormatID { get }
     public var kAudioFormatULaw: AudioFormatID { get }
     public var kAudioFormatALaw: AudioFormatID { get }
     public var kAudioFormatQDesign: AudioFormatID { get }
     public var kAudioFormatQDesign2: AudioFormatID { get }
     public var kAudioFormatQUALCOMM: AudioFormatID { get }
     public var kAudioFormatMPEGLayer1: AudioFormatID { get }
     public var kAudioFormatMPEGLayer2: AudioFormatID { get }
     public var kAudioFormatMPEGLayer3: AudioFormatID { get }
     public var kAudioFormatTimeCode: AudioFormatID { get }
     public var kAudioFormatMIDIStream: AudioFormatID { get }
     public var kAudioFormatParameterValueStream: AudioFormatID { get }
     public var kAudioFormatAppleLossless: AudioFormatID { get }
     public var kAudioFormatMPEG4AAC_HE: AudioFormatID { get }
     public var kAudioFormatMPEG4AAC_LD: AudioFormatID { get }
     public var kAudioFormatMPEG4AAC_ELD: AudioFormatID { get }
     public var kAudioFormatMPEG4AAC_ELD_SBR: AudioFormatID { get }
     public var kAudioFormatMPEG4AAC_ELD_V2: AudioFormatID { get }
     public var kAudioFormatMPEG4AAC_HE_V2: AudioFormatID { get }
     public var kAudioFormatMPEG4AAC_Spatial: AudioFormatID { get }
     public var kAudioFormatMPEGD_USAC: AudioFormatID { get }
     public var kAudioFormatAMR: AudioFormatID { get }
     public var kAudioFormatAMR_WB: AudioFormatID { get }
     public var kAudioFormatAudible: AudioFormatID { get }
     public var kAudioFormatiLBC: AudioFormatID { get }
     public var kAudioFormatDVIIntelIMA: AudioFormatID { get }
     public var kAudioFormatMicrosoftGSM: AudioFormatID { get }
     public var kAudioFormatAES3: AudioFormatID { get }
     public var kAudioFormatEnhancedAC3: AudioFormatID { get }
     public var kAudioFormatFLAC: AudioFormatID { get }
     public var kAudioFormatOpus: AudioFormatID { get }
     */
//    public static func formatIDToString(_ mFormatID: AudioFormatID) -> String? {
//        switch mFormatID {
//        case kAudioFormatLinearPCM:
//            return "wav"
//        default:
//            return nil
//        }
//    }
}
