// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

extension AKConverter {
    // MARK: - private helper functions

    // The AVFoundation way. This method doesn't handle compressed input - only compressed output.
    internal func convertAsset(completionHandler: AKConverterCallback? = nil) {
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
            self.reader = try AVAssetReader(asset: asset)

        } catch let err as NSError {
            completionHandler?(err)
            return
        }

        guard let reader = self.reader else {
            completionHandler?(createError(message: "Unable to setup the AVAssetReader."))
            return
        }

        var theInputFormat: AVAudioFormat?

        // pull the input format out of the audio file...
        if let source = try? AVAudioFile(forReading: inputURL) {
            theInputFormat = source.fileFormat
        }

        guard let inputFormat = theInputFormat else {
            completionHandler?(createError(message: "Unable to read the input file format."))
            return
        }
        let options = self.options ?? Options()

        if FileManager.default.fileExists(atPath: outputURL.path) {
            if options.eraseFile {
                AKLog("Warning: removing existing file at", outputURL.path)
                try? FileManager.default.removeItem(at: outputURL)
            } else {
                let message = "The output file exists already. You need to choose a unique URL or delete the file."
                completionHandler?(createError(message: message))
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

        do {
            self.writer = try AVAssetWriter(outputURL: outputURL, fileType: format)
        } catch let err as NSError {
            completionHandler?(err)
            return
        }

        guard let writer = self.writer else {
            completionHandler?(createError(message: "Unable to setup the AVAssetWriter."))
            return
        }

        // 1. chosen option. 2. same as input file. 3. 16 bit
        // optional in case of compressed audio. That said, the other conversion methods are actually used in
        // that case
        let bitDepth = (options.bitDepth ?? inputFormat.settings[AVLinearPCMBitDepthKey] ?? 16) as Any
        var isFloat = false
        if let intDepth = bitDepth as? Int {
            // 32 bit means it's floating point
            isFloat = intDepth == 32
        }

        var sampleRate = options.sampleRate ?? inputFormat.sampleRate
        let channels = options.channels ?? inputFormat.channelCount

        var outputSettings: [String: Any] = [
            AVFormatIDKey: formatKey,
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: channels,
            AVLinearPCMBitDepthKey: bitDepth,
            AVLinearPCMIsFloatKey: isFloat,
            AVLinearPCMIsBigEndianKey: format != .wav,
            AVLinearPCMIsNonInterleaved: !(options.isInterleaved ?? inputFormat.isInterleaved)
        ]

        // Note: AVAssetReaderOutput does not currently support compressed audio?
        if formatKey == kAudioFormatMPEG4AAC {
            if sampleRate > 48_000 {
                sampleRate = 48_000
            }
            // reset these for m4a:
            outputSettings = [
                AVFormatIDKey: formatKey,
                AVSampleRateKey: sampleRate,
                AVNumberOfChannelsKey: channels,
                AVEncoderBitRateKey: Int(options.bitRate),
                AVEncoderBitRateStrategyKey: AVAudioBitRateStrategy_Constant
            ]
        }

        let writerInput = AVAssetWriterInput(mediaType: .audio, outputSettings: outputSettings)
        writer.add(writerInput)

        guard let track = asset.tracks(withMediaType: .audio).first else {
            completionHandler?(createError(message: "No audio was found in the input file."))
            return
        }

        let readerOutput = AVAssetReaderTrackOutput(track: track, outputSettings: nil)
        guard reader.canAdd(readerOutput) else {
            completionHandler?(createError(message: "Unable to add reader output."))
            return
        }
        reader.add(readerOutput)

        if !writer.startWriting() {
            AKLog("Failed to start writing. Error:", writer.error?.localizedDescription)
            completionHandler?(writer.error)
            return
        }

        writer.startSession(atSourceTime: CMTime.zero)

        if !reader.startReading() {
            AKLog("Failed to start reading. Error:", reader.error?.localizedDescription)
            completionHandler?(reader.error)
            return
        }

        let queue = DispatchQueue(label: "com.audiodesigndesk.AKConverter.convertAsset")

        // session.progress could be sent out via a delegate for this session
        writerInput.requestMediaDataWhenReady(on: queue, using: {
            var processing = true // safety flag to prevent runaway loops if errors

            while writerInput.isReadyForMoreMediaData, processing {
                if reader.status == .reading,
                    let buffer = readerOutput.copyNextSampleBuffer() {
                    writerInput.append(buffer)

                } else {
                    writerInput.markAsFinished()

                    switch reader.status {
                    case .failed:
                        AKLog("Conversion failed with error", reader.error)
                        writer.cancelWriting()
                        completionHandler?(reader.error)
                    case .cancelled:
                        AKLog("Conversion cancelled")
                        completionHandler?(nil)
                    case .completed:
                        // writer.endSession(atSourceTime: asset.duration)
                        writer.finishWriting {
                            switch writer.status {
                            case .failed:
                                completionHandler?(writer.error)
                            default:
                                // AKLog("Conversion complete")
                                completionHandler?(nil)
                            }
                        }
                    default:
                        break
                    }
                    processing = false
                }
            }
        }) // requestMediaDataWhenReady
    }

    // Example of the most simplistic AVFoundation conversion.
    // With this approach you can't really specify any settings other than the limited presets.
    internal func convertCompressed(completionHandler: AKConverterCallback? = nil) {
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

        AKLog("Converting to AVAssetExportPresetAppleM4A with default settings.")

        // session.progress could be sent out via a delegate for this session
        session.outputURL = outputURL
        session.outputFileType = .m4a
        session.exportAsynchronously {
            completionHandler?(nil)
        }
    }

    // Currently, as of 2017, if you want to convert from a compressed
    // format to a pcm one, you still have to hit CoreAudio
    internal func convertToPCM(completionHandler: AKConverterCallback? = nil) {
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

        let inputFormat = inputURL.pathExtension.lowercased()
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

        error = ExtAudioFileOpenURL(inputURL as CFURL, &sourceFile)
        if error != noErr {
            completionHandler?(createError(message: "Unable to open the input file."))
            return
        }

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

        guard inputFormat != outputFormat ||
            outputSampleRate != srcFormat.mSampleRate ||
            outputChannels != srcFormat.mChannelsPerFrame ||
            outputBitRate != srcFormat.mBitsPerChannel else {
            AKLog("No conversion is needed, formats are the same. Copying to", outputURL)
            // just copy it?
            do {
                try FileManager.default.copyItem(at: inputURL, to: outputURL)
                completionHandler?(nil)
            } catch let err as NSError {
                AKLog(err)
            }
            return
        }

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

        if format == kAudioFileWAVEType && dstFormat.mBitsPerChannel == 8 {
            // if is 8 BIT PER CHANNEL, remove kAudioFormatFlagIsSignedInteger
            dstFormat.mFormatFlags &= ~kAudioFormatFlagIsSignedInteger
        }

        // Create destination file
        error = ExtAudioFileCreateWithURL(outputURL as CFURL,
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
        var srcBuffer = [UInt8](repeating: 0, count: Int(bufferByteSize))
        var sourceFrameOffset: UInt32 = 0

        srcBuffer.withUnsafeMutableBytes { ptr in
            while true {
                let mBuffer = AudioBuffer(mNumberChannels: srcFormat.mChannelsPerFrame,
                                          mDataByteSize: bufferByteSize,
                                          mData: ptr.baseAddress)

                var fillBufList = AudioBufferList(mNumberBuffers: 1, mBuffers: mBuffer)
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

        completionHandler?(nil)
    }

    internal func isCompressed(url: URL) -> Bool {
        // NOTE: account for files that don't have extensions
        let ext = url.pathExtension.lowercased()
        return (ext == "m4a" || ext == "mp3" || ext == "mp4" || ext == "m4v" || ext == "mpg")
    }

    internal func createError(message: String, code: Int = 1) -> NSError {
        let userInfo: [String: Any] = [NSLocalizedDescriptionKey: message]
        return NSError(domain: "io.audiokit.AKConverter.error", code: code, userInfo: userInfo)
    }
}
