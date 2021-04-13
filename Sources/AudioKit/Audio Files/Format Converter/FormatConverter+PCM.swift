// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

// MARK: - internal helper functions

extension FormatConverter {
    func convertToPCM(completionHandler: FormatConverterCallback? = nil) {
        guard let inputURL = self.inputURL else {
            completionHandler?(Self.createError(message: "Input file can't be nil."))
            return
        }
        guard let outputURL = self.outputURL else {
            completionHandler?(Self.createError(message: "Output file can't be nil."))
            return
        }

        guard let options = options, let outputFormat = options.format else {
            completionHandler?(Self.createError(message: "Options can't be nil."))
            return
        }
        // Log("converting to", outputURL)

        var format: AudioFileTypeID

        switch outputFormat {
        case "aif":
            format = kAudioFileAIFFType
        case "wav":
            format = kAudioFileWAVEType
        case "caf":
            format = kAudioFileCAFType
        default:
            completionHandler?(Self.createError(message: "Output file must be caf, wav or aif."))
            return
        }

        var inputFile: ExtAudioFileRef?
        var outputFile: ExtAudioFileRef?

        func closeFiles() {
            if let strongFile = inputFile {
                // Log("🗑 Disposing input", inputURL.path)
                if noErr != ExtAudioFileDispose(strongFile) {
                    Log("Error disposing input file, could have a memory leak")
                }
            }
            inputFile = nil

            if let strongFile = outputFile {
                // Log("🗑 Disposing output", outputURL.path)
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
                                            &inputDescription) {
            completionHandler?(Self.createError(message: "Unable to get the input file data format."))
            return
        }

        var outputDescription = createOutputDescription(options: options,
                                                        outputFormatID: format,
                                                        inputDescription: inputDescription)

        let inputFormat = inputURL.pathExtension.lowercased()

        guard inputFormat != outputFormat ||
            outputDescription.mSampleRate != inputDescription.mSampleRate ||
            outputDescription.mChannelsPerFrame != inputDescription.mChannelsPerFrame ||
            outputDescription.mBitsPerChannel != inputDescription.mBitsPerChannel else {
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
                                              &outputFile) {
            completionHandler?(Self.createError(message: "Unable to create output file at \(outputURL.path). dstFormat \(outputDescription)"))
            return
        }

        guard let strongOutputFile = outputFile else {
            completionHandler?(Self.createError(message: "Output file is nil."))
            return
        }

//        The format must be linear PCM (kAudioFormatLinearPCM).
//        You must set this in order to encode or decode a non-PCM file data format.
//        You may set this on PCM files to specify the data format used in your calls
//        to read/write.
        if noErr != ExtAudioFileSetProperty(strongInputFile,
                                            kExtAudioFileProperty_ClientDataFormat,
                                            inputDescriptionSize,
                                            &outputDescription) {
            completionHandler?(Self.createError(message: "Unable to set data format on input file."))
            return
        }

        if noErr != ExtAudioFileSetProperty(strongOutputFile,
                                            kExtAudioFileProperty_ClientDataFormat,
                                            inputDescriptionSize,
                                            &outputDescription) {
            completionHandler?(Self.createError(message: "Unable to set the output file data format."))
            return
        }
        let bufferByteSize: UInt32 = 32768
        var srcBuffer = [UInt8](repeating: 0, count: Int(bufferByteSize))
        var sourceFrameOffset: UInt32 = 0

        srcBuffer.withUnsafeMutableBytes { body in
            while true {
                let mBuffer = AudioBuffer(mNumberChannels: inputDescription.mChannelsPerFrame,
                                          mDataByteSize: bufferByteSize,
                                          mData: body.baseAddress)

                var fillBufList = AudioBufferList(mNumberBuffers: 1,
                                                  mBuffers: mBuffer)
                var numFrames: UInt32 = 0

                if outputDescription.mBytesPerFrame > 0 {
                    numFrames = bufferByteSize / outputDescription.mBytesPerFrame
                }

                if noErr != ExtAudioFileRead(strongInputFile,
                                             &numFrames,
                                             &fillBufList) {
                    completionHandler?(Self.createError(message: "Unable to read input file."))
                    return
                }
                // EOF
                if numFrames == 0 { break }

                sourceFrameOffset += numFrames

                if noErr != ExtAudioFileWrite(strongOutputFile, numFrames, &fillBufList) {
                    completionHandler?(Self.createError(message: "Unable to write output file."))
                    return
                }
            }
        }

        closeFiles()

        // no errors
        completionHandler?(nil)
    }

    func createOutputDescription(options: Options,
                                 outputFormatID: AudioFormatID,
                                 inputDescription: AudioStreamBasicDescription) -> AudioStreamBasicDescription {
        let mFormatID: AudioFormatID = kAudioFormatLinearPCM

        let mSampleRate = options.sampleRate ?? inputDescription.mSampleRate
        let mChannelsPerFrame = options.channels ?? inputDescription.mChannelsPerFrame
        var mBitsPerChannel = options.bitDepth ?? inputDescription.mBitsPerChannel

        // For example: don't allow upsampling to 24bit if the src is 16
        if options.bitDepthRule == .lessThanOrEqual && mBitsPerChannel > inputDescription.mBitsPerChannel {
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

        if outputFormatID == kAudioFileWAVEType && mBitsPerChannel == 8 {
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
