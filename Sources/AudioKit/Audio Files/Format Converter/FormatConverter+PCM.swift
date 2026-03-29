// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Accelerate
import AVFoundation

// MARK: - internal helper functions

extension FormatConverter {
    func convertToPCM(completionHandler: FormatConverterCallback? = nil) {
        guard let inputURL = inputURL else {
            completionHandler?(Self.createError(message: "Input file can't be nil."))
            return
        }
        guard let outputURL = outputURL else {
            completionHandler?(Self.createError(message: "Output file can't be nil."))
            return
        }

        guard let options = options, let outputFormat = options.format else {
            completionHandler?(Self.createError(message: "Options can't be nil."))
            return
        }
        var format: AudioFileTypeID

        switch outputFormat {
        case .aif:
            format = kAudioFileAIFFType
        case .wav:
            format = kAudioFileWAVEType
        case .caf:
            format = kAudioFileCAFType
        default:
            completionHandler?(Self.createError(message: "Output file must be caf, wav or aif."))
            return
        }

        var inputFile: ExtAudioFileRef?
        var outputFile: ExtAudioFileRef?

        func closeFiles() {
            if let strongFile = inputFile {
                if noErr != ExtAudioFileDispose(strongFile) {
                    Log("Error disposing input file, could have a memory leak")
                }
            }
            inputFile = nil

            if let strongFile = outputFile {
                if noErr != ExtAudioFileDispose(strongFile) {
                    Log("Error disposing output file, could have a memory leak")
                }
            }
            outputFile = nil
        }

        // make sure these are closed on any exit to avoid leaking the file objects
        defer {
            closeFiles()
        }

        if noErr != ExtAudioFileOpenURL(inputURL as CFURL, &inputFile) {
            completionHandler?(Self.createError(message: "Unable to open the input file."))
            return
        }

        guard let strongInputFile = inputFile else {
            completionHandler?(Self.createError(message: "Unable to open the input file."))
            return
        }

        var inputDescription = AudioStreamBasicDescription()
        var inputDescriptionSize = UInt32(MemoryLayout.stride(ofValue: inputDescription))

        if noErr != ExtAudioFileGetProperty(strongInputFile,
                                            kExtAudioFileProperty_FileDataFormat,
                                            &inputDescriptionSize,
                                            &inputDescription)
        {
            completionHandler?(Self.createError(message: "Unable to get the input file data format."))
            return
        }

        var outputDescription = createOutputDescription(options: options,
                                                        outputFormatID: format,
                                                        inputDescription: inputDescription)

        let inputFormat = AudioFileFormat(rawValue: inputURL.pathExtension.lowercased()) ?? .unknown

        guard inputFormat != outputFormat ||
            outputDescription.mSampleRate != inputDescription.mSampleRate ||
            outputDescription.mChannelsPerFrame != inputDescription.mChannelsPerFrame ||
            outputDescription.mBitsPerChannel != inputDescription.mBitsPerChannel
        else {
            Log("No conversion is needed, formats are the same. Copying to", outputURL)
            // just copy it?
            do {
                try FileManager.default.copyItem(at: inputURL, to: outputURL)
                completionHandler?(nil)
            } catch let err as NSError {
                Log(err)
            }
            return
        }

        // Create destination file
        if noErr != ExtAudioFileCreateWithURL(outputURL as CFURL,
                                              format,
                                              &outputDescription,
                                              nil,
                                              AudioFileFlags.eraseFile.rawValue, // overwrite old file if present
                                              &outputFile)
        {
            completionProxy(error: Self.createError(message: "Unable to create output file at \(outputURL.path). " +
                                "dstFormat \(outputDescription)"),
            completionHandler: completionHandler)
            return
        }

        guard let strongOutputFile = outputFile else {
            completionProxy(error: Self.createError(message: "Output file is nil."),
                            completionHandler: completionHandler)
            return
        }

        if noErr != ExtAudioFileSetProperty(strongOutputFile,
                                            kExtAudioFileProperty_ClientDataFormat,
                                            inputDescriptionSize,
                                            &outputDescription)
        {
            completionProxy(error: Self.createError(message: "Unable to set the output file data format."),
                            completionHandler: completionHandler)
            return
        }
        let needsChannelMix = outputDescription.mChannelsPerFrame < inputDescription.mChannelsPerFrame

        // When downmixing channels, read in the input's native channel count and mix manually,
        // because ExtAudioFile just drops extra channels instead of mixing them (GitHub #2900).
        var readDescription = outputDescription
        if needsChannelMix {
            readDescription.mChannelsPerFrame = inputDescription.mChannelsPerFrame
            readDescription.mBytesPerFrame = readDescription.mBitsPerChannel * inputDescription.mChannelsPerFrame / 8
            readDescription.mBytesPerPacket = readDescription.mBytesPerFrame
        }

        var readDescriptionSize = UInt32(MemoryLayout.stride(ofValue: readDescription))

        if noErr != ExtAudioFileSetProperty(strongInputFile,
                                            kExtAudioFileProperty_ClientDataFormat,
                                            readDescriptionSize,
                                            &readDescription)
        {
            completionProxy(error: Self.createError(message: "Unable to set read format on input file."),
                            completionHandler: completionHandler)
            return
        }

        let bufferByteSize: UInt32 = 32768
        var srcBuffer = [UInt8](repeating: 0, count: Int(bufferByteSize))
        var sourceFrameOffset: UInt32 = 0

        var didErrorWhileIteratingSRCBuffer = false
        srcBuffer.withUnsafeMutableBytes { body in
            while true {
                let mBuffer = AudioBuffer(mNumberChannels: readDescription.mChannelsPerFrame,
                                          mDataByteSize: bufferByteSize,
                                          mData: body.baseAddress)

                var fillBufList = AudioBufferList(mNumberBuffers: 1,
                                                  mBuffers: mBuffer)
                var frameCount: UInt32 = 0

                if readDescription.mBytesPerFrame > 0 {
                    frameCount = bufferByteSize / readDescription.mBytesPerFrame
                }

                if noErr != ExtAudioFileRead(strongInputFile,
                                             &frameCount,
                                             &fillBufList)
                {
                    completionProxy(error: Self.createError(message: "Error reading from the input file."),
                                    completionHandler: completionHandler)
                    didErrorWhileIteratingSRCBuffer = true
                    return
                }
                // EOF
                if frameCount == 0 { break }

                sourceFrameOffset += frameCount

                if needsChannelMix {
                    // Mix interleaved multi-channel samples down to mono by summing all channels.
                    // Data is interleaved: [L0, R0, L1, R1, ...] for stereo.
                    let inputChannels = Int(inputDescription.mChannelsPerFrame)
                    let frames = Int(frameCount)
                    let bytesPerSample = Int(readDescription.mBitsPerChannel / 8)

                    if readDescription.mFormatFlags & kAudioFormatFlagIsSignedInteger != 0 {
                        // Integer PCM path: convert sample pairs to Float, sum, convert back
                        switch bytesPerSample {
                        case 2: // 16-bit
                            body.baseAddress!.withMemoryRebound(to: Int16.self, capacity: frames * inputChannels) { src in
                                for f in 0 ..< frames {
                                    var sum: Float = 0
                                    for ch in 0 ..< inputChannels {
                                        sum += Float(src[f * inputChannels + ch])
                                    }
                                    src[f] = Int16(clamping: Int(sum))
                                }
                            }
                        case 3: // 24-bit (packed)
                            for f in 0 ..< frames {
                                var sum: Int32 = 0
                                for ch in 0 ..< inputChannels {
                                    let offset = (f * inputChannels + ch) * 3
                                    let b0 = Int32(body[offset])
                                    let b1 = Int32(body[offset + 1])
                                    let b2 = Int32(body[offset + 2])
                                    // Little-endian signed 24-bit
                                    let sample = b0 | (b1 << 8) | (b2 << 16)
                                    let signed = sample >= 0x800000 ? sample - 0x1000000 : sample
                                    sum += signed
                                }
                                let outOffset = f * 3
                                let clamped = max(-0x800000, min(0x7FFFFF, Int(sum)))
                                let unsigned = clamped < 0 ? clamped + 0x1000000 : clamped
                                body[outOffset] = UInt8(unsigned & 0xFF)
                                body[outOffset + 1] = UInt8((unsigned >> 8) & 0xFF)
                                body[outOffset + 2] = UInt8((unsigned >> 16) & 0xFF)
                            }
                        case 4: // 32-bit
                            body.baseAddress!.withMemoryRebound(to: Int32.self, capacity: frames * inputChannels) { src in
                                for f in 0 ..< frames {
                                    var sum: Int64 = 0
                                    for ch in 0 ..< inputChannels {
                                        sum += Int64(src[f * inputChannels + ch])
                                    }
                                    src[f] = Int32(clamping: sum)
                                }
                            }
                        default:
                            break
                        }
                    }

                    // Rewrite the buffer metadata for mono output
                    let monoDataSize = UInt32(frames * bytesPerSample)
                    let monoBuffer = AudioBuffer(mNumberChannels: outputDescription.mChannelsPerFrame,
                                                 mDataByteSize: monoDataSize,
                                                 mData: body.baseAddress)
                    var monoList = AudioBufferList(mNumberBuffers: 1, mBuffers: monoBuffer)

                    if noErr != ExtAudioFileWrite(strongOutputFile,
                                                  frameCount,
                                                  &monoList)
                    {
                        completionProxy(error: Self.createError(message: "Error writing to the output file."),
                                        completionHandler: completionHandler)
                        didErrorWhileIteratingSRCBuffer = true
                        return
                    }
                } else {
                    if noErr != ExtAudioFileWrite(strongOutputFile,
                                                  frameCount,
                                                  &fillBufList)
                    {
                        completionProxy(error: Self.createError(message: "Error writing to the output file."),
                                        completionHandler: completionHandler)
                        didErrorWhileIteratingSRCBuffer = true
                        return
                    }
                }
            }
        }

        if !didErrorWhileIteratingSRCBuffer {
            // no errors
            completionHandler?(nil)
        }
    }

    func createOutputDescription(options: Options,
                                 outputFormatID: AudioFormatID,
                                 inputDescription: AudioStreamBasicDescription) -> AudioStreamBasicDescription
    {
        let mFormatID: AudioFormatID = kAudioFormatLinearPCM

        let mSampleRate = options.sampleRate ?? inputDescription.mSampleRate
        let mChannelsPerFrame = options.channels ?? inputDescription.mChannelsPerFrame
        var mBitsPerChannel = options.bitDepth ?? inputDescription.mBitsPerChannel

        // For example: don't allow upsampling to 24bit if the src is 16
        if options.bitDepthRule == .lessThanOrEqual, mBitsPerChannel > inputDescription.mBitsPerChannel {
            mBitsPerChannel = inputDescription.mBitsPerChannel
        }

        var mBytesPerFrame = mBitsPerChannel * mChannelsPerFrame / 8
        var mBytesPerPacket = options.bitDepth == nil ? inputDescription.mBytesPerPacket : mBytesPerFrame

        if mBitsPerChannel == 0 {
            mBitsPerChannel = 16
            mBytesPerPacket = 2 * mChannelsPerFrame
            mBytesPerFrame = 2 * mChannelsPerFrame
        }

        var mFormatFlags: AudioFormatFlags = kLinearPCMFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger
        if outputFormatID == kAudioFileAIFFType {
            mFormatFlags = mFormatFlags | kLinearPCMFormatFlagIsBigEndian
        }

        if outputFormatID == kAudioFileWAVEType, mBitsPerChannel == 8 {
            // if is 8 BIT PER CHANNEL, remove kAudioFormatFlagIsSignedInteger
            mFormatFlags &= ~kAudioFormatFlagIsSignedInteger
        }

        return AudioStreamBasicDescription(mSampleRate: mSampleRate,
                                           mFormatID: mFormatID,
                                           mFormatFlags: mFormatFlags,
                                           mBytesPerPacket: mBytesPerPacket,
                                           mFramesPerPacket: 1,
                                           mBytesPerFrame: mBytesPerFrame,
                                           mChannelsPerFrame: mChannelsPerFrame,
                                           mBitsPerChannel: mBitsPerChannel,
                                           mReserved: 0)
    }
}
