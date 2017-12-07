//
//  AKConverter.swift
//  AudioKit
//
//  Created by Ryan Francesconi, revision history on Github.
//  Copyright © 2017 Ryan Francesconi. All rights reserved.
//

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
converter.start(completionHandler: { error in
    // check to see if error isn't nil, otherwise you're good
})
```
*/
class AKConverter: NSObject {
    /**
     AKConverterCallback is the callback format for start()
     -Parameter: error This will contain one parameter of type Error which is nil if the conversion was successful.
    */
    public typealias AKConverterCallback = (_ error: Error?) -> Void

    /** Formats that this class can write */
    public static let outputFormats = ["wav", "aif", "caf", "m4a"]

    /** Formats that this class can read */
    public static let inputFormats = AKConverter.outputFormats + ["mp3", "mp4", "snd", "au", "sd2", "aiff", "aifc", "aac"]

    /**
    The conversion options, leave nil to adopt the value of the input file
    */
    public struct Options {
        var format: String?
        var sampleRate: Double?
        /// used only with PCM data
        var bitDepth: UInt32?
        /// used only when outputting compressed from PCM
        var bitRate: UInt32 = 256_000
        var channels: UInt32?
        var isInterleaved: Bool?
        /// overwrite existing files, set false if you want to handle this
        var eraseFile: Bool = true
    }

    // MARK: - public properties

    public var inputURL: URL?
    public var outputURL: URL?
    public var options: Options?

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

        // Format checks are necessary as AVAssetReader has opinions about compressed audio for some illogical reason
        if isCompressed(url: inputURL) && isCompressed(url: outputURL) {
            AKLog("\(inputURL.lastPathComponent) \(outputURL.lastPathComponent) are both compressed so passing to convertCompressed...")
            convertCompressed(completionHandler: completionHandler)
            return

        } else if isCompressed(url: inputURL) && !isCompressed(url: outputURL) {
            AKLog("\(inputURL.lastPathComponent) is compressed so passing to core audio...")
            convertToPCM(completionHandler: completionHandler)
            return
        }

        AKLog("Converting \(inputURL.lastPathComponent) to \(outputURL.path)...")

        let outputFormat = options?.format ?? outputURL.pathExtension.lowercased()

        // verify outputFormat
        guard AKConverter.outputFormats.contains(outputFormat) else {
            completionHandler?(createError(message: "The output file format isn't able to be produced by this class."))
            return
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

        let asset = AVAsset(url: inputURL)
        do {
            reader = try AVAssetReader(asset: asset)

        } catch let err as NSError {
            completionHandler?(err)
            return
        }

        guard reader != nil else {
            completionHandler?(createError(message: "Unable to setup the AVAssetReader."))
            return
        }

        var inputFile: AVAudioFile
        do {
            inputFile = try AVAudioFile(forReading: inputURL)
        } catch let err as NSError {
            completionHandler?(err)
            return
        }

        if options == nil {
            options = Options()
        }

        // nil indicates to use the input file's settings for these
        if options?.sampleRate == nil {
            options?.sampleRate = inputFile.fileFormat.sampleRate
        }

        if options?.bitDepth == nil {
            if let bitDepth = inputFile.fileFormat.settings[AVLinearPCMBitDepthKey] as? UInt32 {
                options?.bitDepth = bitDepth
            }
        }

        if options?.channels == nil {
            options?.channels = inputFile.fileFormat.channelCount
        }

        if options?.isInterleaved == nil {
            options?.isInterleaved = inputFile.fileFormat.isInterleaved
        }

        guard let options = options else {
            completionHandler?(createError(message: "The options are malformed."))
            return
        }

        if FileManager.default.fileExists(atPath: outputURL.path) {
            if options.eraseFile {
                try? FileManager.default.removeItem(at: outputURL)
            } else {
                completionHandler?(createError(message: "The output file exists already. You need to choose a unique URL or delete the file."))
                return
            }
        }

        var writer: AVAssetWriter
        do {
            writer = try AVAssetWriter(outputURL: outputURL, fileType: format)
        } catch let err as NSError {
            completionHandler?(err)
            return
        }

        var outputSettings: [String : Any] = [AVFormatIDKey: formatKey,
                                              AVSampleRateKey: options.sampleRate!,
                                              AVNumberOfChannelsKey: options.channels!,
                                              AVLinearPCMBitDepthKey: options.bitDepth!,
                                              AVLinearPCMIsFloatKey: options.bitDepth == 32,
                                              AVLinearPCMIsBigEndianKey: format != .wav,
                                              AVLinearPCMIsNonInterleaved: !options.isInterleaved!]

        //*** -[AVAssetReaderTrackOutput initWithTrack:outputSettings:] AVAssetReaderOutput does not currently support compressed output
        if formatKey == kAudioFormatMPEG4AAC {
            outputSettings = [AVFormatIDKey: formatKey,
                              AVSampleRateKey: options.sampleRate!,
                              AVNumberOfChannelsKey: options.channels!,
                              AVEncoderBitRateKey: options.bitRate]
        }

        let writerInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: outputSettings)
        writer.add(writerInput)

        let tracks = asset.tracks(withMediaType: .audio)

        guard tracks.count > 0 else {
            completionHandler?(createError(message: "No audio was found in the input file."))
            return
        }

        let readerOutput = AVAssetReaderTrackOutput(track: tracks[0], outputSettings: nil)
        reader!.add(readerOutput)

        if !writer.startWriting() {
            //AKLog("Failed to start writing. Error: \(writer.error)")
            completionHandler?(writer.error)
            return
        }

        writer.startSession(atSourceTime: kCMTimeZero)
        reader!.startReading()

        let queue = DispatchQueue(label: "io.audiokit.AKConverter.start", qos: .utility)

        writerInput.requestMediaDataWhenReady(on: queue, using: {
            while( writerInput.isReadyForMoreMediaData ) {
                //if reader!.status = AVAssetReaderStatus.reading

                if let buffer = readerOutput.copyNextSampleBuffer() {
                    writerInput.append(buffer)

                } else {
                    writerInput.markAsFinished()
                    writer.endSession(atSourceTime: asset.duration)
                    writer.finishWriting {
                        Swift.print("DONE: \(self.reader!.asset)")

                        completionHandler?(nil)
                    }
                }
            }
        }) //requestMediaDataWhenReady
    }

// MARK: - private helper functions

    // Example of the most simplistic AVFoundation conversion. However with this approach you can't really specify any settings other than the limited presets.
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
        session.outputURL = outputURL
        session.outputFileType = .m4a
        session.exportAsynchronously {
            completionHandler?(nil)
        }
    }

    // Currently as of 2017, if you want to convert from a compressed format to a pcm one, you still have to hit CoreAudio
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

        guard sourceFile != nil else {
            completionHandler?(createError(message: "Unable to open the input file."))
            return
        }

        error = ExtAudioFileGetProperty(sourceFile!,
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

        // outputBitRate == 0: in the input file this indicates a compressed format such as mp3
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

        Swift.print("mBytesPerFrame: \(dstFormat.mBytesPerFrame), srcFormat.mBytesPerPacket: \(srcFormat.mBytesPerPacket)")

        // Create destination file
        error = ExtAudioFileCreateWithURL(
            outputURL as CFURL,
            format,
            &dstFormat,
            nil,
            AudioFileFlags.eraseFile.rawValue, //overwrite old file if present
            &destinationFile)

        if error != noErr {
            completionHandler?(createError(message: "Unable to create output file."))
            return
        }

        error = ExtAudioFileSetProperty(sourceFile!,
                                        kExtAudioFileProperty_ClientDataFormat,
                                        thePropertySize,
                                        &dstFormat)
        if error != noErr {
            Swift.print("Error 2")
            completionHandler?(createError(message: "Unable to set data format on output file."))
            return

        }
        error = ExtAudioFileSetProperty(destinationFile!,
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

        while (true) {
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

            error = ExtAudioFileRead(sourceFile!, &numFrames, &fillBufList)
            if error != noErr {
                completionHandler?(createError(message: "Unable to read input file."))
                return
            }
            if (numFrames == 0) {
                error = noErr
                break
            }

            sourceFrameOffset += numFrames

            error = ExtAudioFileWrite(destinationFile!, numFrames, &fillBufList)
            if error != noErr {
                completionHandler?(createError(message: "Unable to write output file."))
                return
            }
        }

        error = ExtAudioFileDispose(destinationFile!)
        if error != noErr {
            completionHandler?(createError(message: "Unable to dispose the output file object."))
            return
        }

        error = ExtAudioFileDispose(sourceFile!)
        if error != noErr {
            completionHandler?(createError(message: "Unable to dispose the input file object."))
            return
        }

        // no errors. yay.
        completionHandler?(nil)
    }

    private func isCompressed(url: URL) -> Bool {
        let ext = url.pathExtension.lowercased()
        return (ext == "m4a" || ext == "mp3" || ext == "mp4")
    }

    private func createError(message: String, code: Int = 1) -> NSError {
        let userInfo: [String: Any] = [NSLocalizedDescriptionKey: message]
        return NSError(domain: "io.audiokit.AKConverter.error", code: code, userInfo: userInfo)
    }

}
