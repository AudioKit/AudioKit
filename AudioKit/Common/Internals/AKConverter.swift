//
//  AKConverter.swift
//  AudioKit
//
//  Created by Ryan Francesconi, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/**
 AKConverter wraps the more complex AVFoundation and CoreAudio audio conversions in an easy to use format.
 ```
 let options = AKConverter.Options()
 // any options left nil will assume the value of the input file
 options.format = "wav"
 options.sampleRate == 48000
 options.bitDepth = 24

 let converter = AKConverter(inputURL: oldURL, outputURL: newURL, options: options)
 converter.start(completionHandler: { error in
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
        /// used only when outputting compressed from PCM
        public var bitRate: UInt32 = 256_000
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
    private var reader: AVAssetReader?

    // MARK: - initialization

    /// init with input, output and options - then start()
    public init(inputURL: URL, outputURL: URL, options: Options? = nil) {
        self.inputURL = inputURL
        self.outputURL = outputURL
        self.options = options
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

        // Format checks are necessary as AVAssetReader has opinions about compressed audio for some illogical reason
        if isCompressed(url: inputURL) && isCompressed(url: outputURL) {
            convertCompressed(completionHandler: completionHandler)
            return

        } else if isCompressed(url: outputURL) == false {
            convertToPCM(completionHandler: completionHandler)
            return
        }

        convertAsset(completionHandler: completionHandler)
    }

    // MARK: - private helper functions

    // The AVFoundation way
    private func convertAsset(completionHandler: AKConverterCallback? = nil) {
        guard let inputURL = self.inputURL else {
            completionHandler?(createError(message: "Input file can't be nil."))
            return
        }
        guard let outputURL = self.outputURL else {
            completionHandler?(createError(message: "Output file can't be nil."))
            return
        }

        let outputFormat = options?.format ?? outputURL.pathExtension.lowercased()

        // verify outputFormat
        guard AKConverter.outputFormats.contains(outputFormat) else {
            completionHandler?(createError(message: "The output file format isn't able to be produced by this class."))
            return
        }

        let asset = AVAsset(url: inputURL)
        do {
            reader = try AVAssetReader(asset: asset)

        } catch let err as NSError {
            completionHandler?(err)
            return
        }

        guard let reader = reader else {
            completionHandler?(createError(message: "Unable to setup the AVAssetReader."))
            return
        }

        var inputFile: AVAudioFile
        do {
            inputFile = try AVAudioFile(forReading: inputURL)
        } catch let err as NSError {
            // Error creating input audio file
            completionHandler?(err)
            return
        }

        if options == nil {
            options = Options()
        }

        guard let options = options else {
            completionHandler?(createError(message: "The options are malformed."))
            return
        }

        if FileManager.default.fileExists(atPath: outputURL.path) {
            if options.eraseFile {
                try? FileManager.default.removeItem(at: outputURL)
            } else {
                let message = "The output file exists already. You need to choose a unique URL or delete the file."
                let err = createError(message: message)
                completionHandler?(err)
                return
            }
        }

        var format: AVFileType
        var formatKey: AudioFormatID

        switch outputFormat {
        case "m4a", "mp4":
            format = .m4a
            formatKey = kAudioFormatMPEG4AAC
        case "aif":
            format = .aiff
            formatKey = kAudioFormatLinearPCM
        case "caf":
            format = .caf
            formatKey = kAudioFormatLinearPCM
        case "wav":
            format = .wav
            formatKey = kAudioFormatLinearPCM
        default:
            AKLog("Unsupported output format: \(outputFormat)")
            return
        }

        var writer: AVAssetWriter
        do {
            writer = try AVAssetWriter(outputURL: outputURL, fileType: format)
        } catch let err as NSError {
            completionHandler?(err)
            return
        }

        // 1. chosen option. 2. same as input file. 3. 16 bit
        // optional in case of compressed audio. That said, the other conversion methods are actually used in
        // that case
        let bitDepth = (options.bitDepth ?? inputFile.fileFormat.settings[AVLinearPCMBitDepthKey] ?? 16) as Any
        var isFloat = false
        if let intDepth = bitDepth as? Int {
            // 32 bit means it's floating point
            isFloat = intDepth == 32
        }

        var sampleRate = options.sampleRate ?? inputFile.fileFormat.sampleRate
        let channels = options.channels ?? inputFile.fileFormat.channelCount

        var outputSettings: [String: Any] = [
            AVFormatIDKey: formatKey,
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: channels,
            AVLinearPCMBitDepthKey: bitDepth,
            AVLinearPCMIsFloatKey: isFloat,
            AVLinearPCMIsBigEndianKey: format != .wav,
            AVLinearPCMIsNonInterleaved: !(options.isInterleaved ?? inputFile.fileFormat.isInterleaved)
        ]

        // Note: AVAssetReaderOutput does not currently support compressed output
        if formatKey == kAudioFormatMPEG4AAC {
            if sampleRate > 48_000 {
                sampleRate = 44_100
            }

            outputSettings = [
                AVFormatIDKey: formatKey,
                AVSampleRateKey: sampleRate,
                AVNumberOfChannelsKey: channels,
                AVEncoderBitRateKey: options.bitRate
            ]
        }

        let writerInput = AVAssetWriterInput(mediaType: .audio, outputSettings: outputSettings)
        writer.add(writerInput)

        let tracks = asset.tracks(withMediaType: .audio)

        guard !tracks.isEmpty else {
            completionHandler?(createError(message: "No audio was found in the input file."))
            return
        }

        let readerOutput = AVAssetReaderTrackOutput(track: tracks[0], outputSettings: nil)
        reader.add(readerOutput)

        if writer.startWriting() == false {
            let error = String(describing: writer.error)
            AKLog("Failed to start writing. Error: \(error)")
            completionHandler?(writer.error)
            return
        }

        writer.startSession(atSourceTime: CMTime.zero)
        reader.startReading()

        let queue = DispatchQueue(label: "io.audiokit.AKConverter.start", qos: .utility)

        // session.progress could be sent out via a delegate for this session
        writerInput.requestMediaDataWhenReady(on: queue, using: {
            while writerInput.isReadyForMoreMediaData {
                if reader.status == .failed {
                    AKLog("Conversion Failed")
                    break
                }

                if let buffer = readerOutput.copyNextSampleBuffer() {
                    writerInput.append(buffer)

                } else {
                    writerInput.markAsFinished()
                    writer.endSession(atSourceTime: asset.duration)
                    writer.finishWriting {
                        // AKLog("DONE: \(self.reader!.asset)")
                        DispatchQueue.main.async {
                            completionHandler?(nil)
                        }
                    }
                }
            }
        }) // requestMediaDataWhenReady
    }

    // Example of the most simplistic AVFoundation conversion.
    // With this approach you can't really specify any settings other than the limited presets.
    private func convertCompressed(completionHandler: AKConverterCallback? = nil) {
        guard let inputURL = self.inputURL else {
            completionHandler?(createError(message: "Input file can't be nil."))
            return
        }
        guard let outputURL = self.outputURL else {
            completionHandler?(createError(message: "Output file can't be nil."))
            return
        }

        let asset = AVURLAsset(url: inputURL)
        guard let session = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else { return }

        // session.progress could be sent out via a delegate for this session
        session.outputURL = outputURL
        session.outputFileType = .m4a
        session.exportAsynchronously {
            completionHandler?(nil)
        }
    }

    // Currently, as of 2017, if you want to convert from a compressed
    // format to a pcm one, you still have to hit CoreAudio
    private func convertToPCM(completionHandler: AKConverterCallback? = nil) {
        guard let inputURL = self.inputURL else {
            completionHandler?(createError(message: "Input file can't be nil."))
            return
        }
        guard let outputURL = self.outputURL else {
            completionHandler?(createError(message: "Output file can't be nil."))
            return
        }

        if isCompressed(url: outputURL) {
            completionHandler?(createError(message: "Output file must be PCM."))
            return
        }

        let outputFormat = options?.format ?? outputURL.pathExtension.lowercased()

        AKLog("convertToPCM() to \(outputURL)")

        var format: AudioFileTypeID
        let formatKey: AudioFormatID = kAudioFormatLinearPCM

        switch outputFormat {
        case "aif":
            format = kAudioFileAIFFType
        case "wav":
            format = kAudioFileWAVEType
        case "caf":
            format = kAudioFileCAFType
        default:
            completionHandler?(createError(message: "Output file must be caf, wav or aif."))
            return
        }

        var error = noErr
        var destinationFile: ExtAudioFileRef?
        var sourceFile: ExtAudioFileRef?

        var srcFormat = AudioStreamBasicDescription()
        var dstFormat = AudioStreamBasicDescription()

        ExtAudioFileOpenURL(inputURL as CFURL, &sourceFile)
        var thePropertySize = UInt32(MemoryLayout.stride(ofValue: srcFormat))

        guard let inputFile = sourceFile else {
            completionHandler?(createError(message: "Unable to open the input file."))
            return
        }

        error = ExtAudioFileGetProperty(inputFile,
                                        kExtAudioFileProperty_FileDataFormat,
                                        &thePropertySize, &srcFormat)

        if error != noErr {
            completionHandler?(createError(message: "Unable to get the input file data format."))
            return
        }
        let outputSampleRate = options?.sampleRate ?? srcFormat.mSampleRate
        let outputChannels = options?.channels ?? srcFormat.mChannelsPerFrame
        var outputBitRate = options?.bitDepth ?? srcFormat.mBitsPerChannel

        var outputBytesPerFrame = outputBitRate * outputChannels / 8
        var outputBytesPerPacket = options?.bitDepth == nil ? srcFormat.mBytesPerPacket : outputBytesPerFrame

        // outputBitRate == 0 : in the input file this indicates a compressed format such as mp3
        if outputBitRate == 0 {
            outputBitRate = 16
            outputBytesPerPacket = 2 * outputChannels
            outputBytesPerFrame = 2 * outputChannels
        }

        dstFormat.mSampleRate = outputSampleRate
        dstFormat.mFormatID = formatKey
        dstFormat.mChannelsPerFrame = outputChannels
        dstFormat.mBitsPerChannel = outputBitRate
        dstFormat.mBytesPerPacket = outputBytesPerPacket
        dstFormat.mBytesPerFrame = outputBytesPerFrame
        dstFormat.mFramesPerPacket = 1
        dstFormat.mFormatFlags = kLinearPCMFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger

        if format == kAudioFileAIFFType {
            dstFormat.mFormatFlags = dstFormat.mFormatFlags | kLinearPCMFormatFlagIsBigEndian
        }

        // Create destination file
        error = ExtAudioFileCreateWithURL(
            outputURL as CFURL,
            format,
            &dstFormat,
            nil,
            AudioFileFlags.eraseFile.rawValue, // overwrite old file if present
            &destinationFile)

        if error != noErr {
            completionHandler?(createError(message: "Unable to create output file."))
            return
        }

        guard let outputFile = destinationFile else {
            completionHandler?(createError(message: "Unable to create output file (2)."))
            return
        }

        error = ExtAudioFileSetProperty(inputFile,
                                        kExtAudioFileProperty_ClientDataFormat,
                                        thePropertySize,
                                        &dstFormat)
        if error != noErr {
            completionHandler?(createError(message: "Unable to set data format on output file."))
            return
        }

        error = ExtAudioFileSetProperty(outputFile,
                                        kExtAudioFileProperty_ClientDataFormat,
                                        thePropertySize,
                                        &dstFormat)
        if error != noErr {
            completionHandler?(createError(message: "Unable to set the output file data format."))
            return
        }
        let bufferByteSize: UInt32 = 32_768
        var srcBuffer = [UInt8](repeating: 0, count: 32_768)
        var sourceFrameOffset: UInt32 = 0

        while true {
            var fillBufList = AudioBufferList(
                mNumberBuffers: 1,
                mBuffers: AudioBuffer(
                    mNumberChannels: srcFormat.mChannelsPerFrame,
                    mDataByteSize: UInt32(srcBuffer.count),
                    mData: &srcBuffer
                )
            )
            var numFrames: UInt32 = 0

            if dstFormat.mBytesPerFrame > 0 {
                numFrames = bufferByteSize / dstFormat.mBytesPerFrame
            }

            error = ExtAudioFileRead(inputFile, &numFrames, &fillBufList)
            if error != noErr {
                completionHandler?(createError(message: "Unable to read input file."))
                return
            }
            if numFrames == 0 {
                error = noErr
                break
            }

            sourceFrameOffset += numFrames

            error = ExtAudioFileWrite(outputFile, numFrames, &fillBufList)
            if error != noErr {
                completionHandler?(createError(message: "Unable to write output file."))
                return
            }
        }

        error = ExtAudioFileDispose(outputFile)
        if error != noErr {
            completionHandler?(createError(message: "Unable to dispose the output file object."))
            return
        }

        error = ExtAudioFileDispose(inputFile)
        if error != noErr {
            completionHandler?(createError(message: "Unable to dispose the input file object."))
            return
        }

        // no errors. yay.
        completionHandler?(nil)
    }

    private func isCompressed(url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return (ext == "m4a" || ext == "mp3" || ext == "mp4" || ext == "m4v")
    }

    private func createError(message: String, code: Int = 1) -> NSError {
        let userInfo: [String: Any] = [NSLocalizedDescriptionKey: message]
        return NSError(domain: "io.audiokit.AKConverter.error", code: code, userInfo: userInfo)
    }
}
