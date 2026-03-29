// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

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

        // When reducing channels (e.g. stereo to mono), ExtAudioFile's default
        // conversion takes only channel 0 instead of mixing all channels.
        // Read in the input's channel count and mix down manually.
        let needsChannelMix = outputDescription.mChannelsPerFrame < inputDescription.mChannelsPerFrame
        let inputChannels = inputDescription.mChannelsPerFrame
        let outputChannels = outputDescription.mChannelsPerFrame
        let bytesPerSample = outputDescription.mBitsPerChannel / 8

        var readDescription = outputDescription
        if needsChannelMix {
            readDescription.mChannelsPerFrame = inputChannels
            readDescription.mBytesPerFrame = bytesPerSample * inputChannels
            readDescription.mBytesPerPacket = readDescription.mBytesPerFrame
        }

        // The format must be linear PCM (kAudioFormatLinearPCM).
        // You must set this in order to encode or decode a non-PCM file data format.
        // You may set this on PCM files to specify the data format used in your calls
        // to read/write.
        if noErr != ExtAudioFileSetProperty(strongInputFile,
                                            kExtAudioFileProperty_ClientDataFormat,
                                            inputDescriptionSize,
                                            &readDescription)
        {
            completionProxy(error: Self.createError(message: "Unable to set data format on input file."),
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

                if needsChannelMix, let data = body.baseAddress {
                    Self.mixdownChannels(data: data,
                                         frameCount: frameCount,
                                         inputChannels: inputChannels,
                                         outputChannels: outputChannels,
                                         bytesPerSample: bytesPerSample)
                    fillBufList.mBuffers.mNumberChannels = outputChannels
                    fillBufList.mBuffers.mDataByteSize = frameCount * outputDescription.mBytesPerFrame
                }

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

        if !didErrorWhileIteratingSRCBuffer {
            // no errors
            completionHandler?(nil)
        }
    }

    /// Average interleaved input channels down to fewer output channels in-place.
    static func mixdownChannels(data: UnsafeMutableRawPointer,
                                frameCount: UInt32,
                                inputChannels: UInt32,
                                outputChannels: UInt32,
                                bytesPerSample: UInt32)
    {
        let frames = Int(frameCount)
        let inCh = Int(inputChannels)
        let outCh = Int(outputChannels)
        let bps = Int(bytesPerSample)

        switch bps {
        case 2:
            let samples = data.assumingMemoryBound(to: Int16.self)
            for f in 0 ..< frames {
                for o in 0 ..< outCh {
                    var sum: Int32 = 0
                    for i in 0 ..< inCh {
                        sum += Int32(samples[f * inCh + i])
                    }
                    samples[f * outCh + o] = Int16(clamping: sum / Int32(inCh))
                }
            }
        case 4:
            let samples = data.assumingMemoryBound(to: Int32.self)
            for f in 0 ..< frames {
                for o in 0 ..< outCh {
                    var sum: Int64 = 0
                    for i in 0 ..< inCh {
                        sum += Int64(samples[f * inCh + i])
                    }
                    samples[f * outCh + o] = Int32(clamping: sum / Int64(inCh))
                }
            }
        default:
            // For 8-bit and 24-bit (packed 3-byte), fall back to byte-level mixing
            for f in 0 ..< frames {
                for o in 0 ..< outCh {
                    var sum: Int32 = 0
                    for i in 0 ..< inCh {
                        let offset = (f * inCh + i) * bps
                        var value: Int32 = 0
                        for b in 0 ..< bps {
                            value |= Int32(data.load(fromByteOffset: offset + b, as: UInt8.self)) << (b * 8)
                        }
                        // Sign-extend
                        let signBit = Int32(1) << (bps * 8 - 1)
                        value = (value ^ signBit) - signBit
                        sum += value
                    }
                    let avg = sum / Int32(inCh)
                    let outOffset = (f * outCh + o) * bps
                    for b in 0 ..< bps {
                        let byte = UInt8(truncatingIfNeeded: avg >> (b * 8))
                        data.storeBytes(of: byte, toByteOffset: outOffset + b, as: UInt8.self)
                    }
                }
            }
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
