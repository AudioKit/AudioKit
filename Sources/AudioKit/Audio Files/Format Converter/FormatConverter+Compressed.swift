// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

// MARK: - internal helper functions

extension FormatConverter {
    /// Example of the most simplistic AVFoundation conversion.
    /// With this approach you can't really specify any settings other than the limited presets.
    /// No sample rate conversion in this. This isn't used in the public methods but is here
    /// for example.
    ///
    /// see `AVAssetExportSession`:
    /// *Prior to initializing an instance of AVAssetExportSession, you can invoke
    /// +allExportPresets to obtain the complete list of presets available. Use
    /// +exportPresetsCompatibleWithAsset: to obtain a list of presets that are compatible
    /// with a specific AVAsset.*
    ///
    /// This is no longer used in this class as it's not possible to convert sample rate or other
    /// required options. It will use the next function instead
    @available(visionOS, unavailable, message: "This method is not supported on visionOS")
    func convertCompressed(presetName: String, completionHandler: FormatConverterCallback? = nil) {
        guard let inputURL = inputURL else {
            completionHandler?(Self.createError(message: "Input file can't be nil."))
            return
        }
        guard let outputURL = outputURL else {
            completionHandler?(Self.createError(message: "Output file can't be nil."))
            return
        }

        let asset = AVURLAsset(url: inputURL)
        guard let session = AVAssetExportSession(asset: asset,
                                                 presetName: presetName) else { return }

        session.determineCompatibleFileTypes { list in

            guard let outputFileType: AVFileType = list.first else {
                let error = Self.createError(message: "Unable to determine a compatible file type from \(inputURL.path)")
                completionHandler?(error)
                return
            }

            // session.progress could be sent out via a delegate for this session
            session.outputURL = outputURL
            session.outputFileType = outputFileType
            session.exportAsynchronously {
                completionHandler?(session.error)
            }
        }
    }

    /// Example of the most simplistic AVFoundation conversion.
    /// With this approach you can't really specify any settings other than the limited presets.
    /// No sample rate conversion in this. This isn't used in the public methods but is here
    /// for example.
    ///
    /// see `AVAssetExportSession`:
    /// *Prior to initializing an instance of AVAssetExportSession, you can invoke
    /// +allExportPresets to obtain the complete list of presets available. Use
    /// +exportPresetsCompatibleWithAsset: to obtain a list of presets that are compatible
    /// with a specific AVAsset.*
    ///
    /// This is no longer used in this class as it's not possible to convert sample rate or other
    /// required options. It will use the next function instead
    #if swift(>=6.0) // Swift 6.0 corresponds to Xcode 16+
    @available(macOS 15, iOS 18, tvOS 18, visionOS 2.0, *)
    func convertCompressed(presetName: String) async throws {
        guard let inputURL = inputURL else {
            throw Self.createError(message: "Input file can't be nil.")
        }
        guard let outputURL = outputURL else {
            throw Self.createError(message: "Output file can't be nil.")
        }

        let asset = AVURLAsset(url: inputURL)
        guard let session = AVAssetExportSession(asset: asset,
                                                 presetName: presetName) else {
            throw Self.createError(message: "session can't be nil.")
        }

        let list = await session.compatibleFileTypes
        guard let outputFileType: AVFileType = list.first else {
            throw Self.createError(message: "Unable to determine a compatible file type from \(inputURL.path)")
        }

        try await session.export(to: outputURL, as: outputFileType)
    }
    #endif

    /// Convert to compressed first creating a tmp file to PCM to allow more flexible conversion
    /// options to work.
    func convertCompressed(completionHandler: FormatConverterCallback? = nil) {
        guard let inputURL = inputURL else {
            completionHandler?(Self.createError(message: "Input file can't be nil."))
            return
        }
        guard let outputURL = outputURL else {
            completionHandler?(Self.createError(message: "Output file can't be nil."))
            return
        }

        guard let options = options else {
            completionHandler?(Self.createError(message: "Options can't be nil."))
            return
        }

        let tempName = outputURL.deletingPathExtension().lastPathComponent + "_TEMP.wav"
        let tempFile = outputURL.deletingLastPathComponent().appendingPathComponent(tempName)

        var tempOptions = FormatConverter.Options()
        tempOptions.bitDepthRule = .lessThanOrEqual
        tempOptions.bitDepth = 24
        tempOptions.sampleRate = options.sampleRate
        tempOptions.channels = options.channels
        tempOptions.format = .wav

        let tempConverter = FormatConverter(inputURL: inputURL,
                                            outputURL: tempFile,
                                            options: tempOptions)

        tempConverter.start { error in
            if let error = error {
                completionHandler?(Self.createError(message: "Failed to convert input to PCM: \(error.localizedDescription)"))
                return
            }

            self.inputURL = tempFile

            self.convertPCMToCompressed { error in
                try? FileManager.default.removeItem(at: tempFile)
                completionHandler?(error)
            }
        }
    }

    /// The AVFoundation way. *This doesn't currently handle compressed input - only compressed output.*
    func convertPCMToCompressed(completionHandler: FormatConverterCallback? = nil) {
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

        // verify outputFormat
        guard FormatConverter.outputFormats.contains(outputFormat) else {
            completionHandler?(Self.createError(message: "The output file format isn't able to be produced by this class."))
            return
        }

        let asset = AVURLAsset(url: inputURL)
        do {
            self.reader = try AVAssetReader(asset: asset)

        } catch let err as NSError {
            completionHandler?(err)
            return
        }

        guard let reader = reader else {
            completionHandler?(Self.createError(message: "Unable to setup the AVAssetReader."))
            return
        }

        guard let inputFormat = asset.audioFormat else {
            completionHandler?(Self.createError(message: "Unable to read the input file format."))
            return
        }

        var format: AVFileType
        var formatKey: AudioFormatID

        switch outputFormat {
        case .m4a, .mp4:
            format = .m4a
            formatKey = kAudioFormatMPEG4AAC
        case .aif:
            format = .aiff
            formatKey = kAudioFormatLinearPCM
        case .caf:
            format = .caf
            formatKey = kAudioFormatLinearPCM
        case .wav:
            format = .wav
            formatKey = kAudioFormatLinearPCM
        default:
            Log("Unsupported output format: \(outputFormat)")
            return
        }

        do {
            self.writer = try AVAssetWriter(outputURL: outputURL, fileType: format)
        } catch let err as NSError {
            completionHandler?(err)
            return
        }

        guard let writer = writer else {
            completionHandler?(Self.createError(message: "Unable to setup the AVAssetWriter."))
            return
        }

        // 1. chosen option. 2. same as input file. 3. 16 bit
        // optional in case of compressed audio. That said, the other conversion methods are actually used in
        // that case
        let bitDepth = (options.bitDepth ?? inputFormat.settings[AVLinearPCMBitDepthKey] ?? 16) as Any
        var isFloat = false
        if let intDepth = bitDepth as? Int {
            isFloat = intDepth == 32
        }

        var sampleRate = options.sampleRate ?? inputFormat.sampleRate
        let channels = options.channels ?? inputFormat.channelCount

        if sampleRate == 0 {
            Log("Sample rate can't be 0 - assigning to default format of 48k. inputFormat is", inputFormat)
            sampleRate = 48000
        }
        var outputSettings: [String: Any]?

        // Note: AVAssetReaderOutput does not currently support compressed audio
        if formatKey == kAudioFormatMPEG4AAC {
            if sampleRate > 48000 {
                sampleRate = 48000
            }
            // mono should be 1/2 the shown bitrate
            let perChannel = channels == 1 ? 2 : 1

            // reset these for m4a:
            outputSettings = [
                AVFormatIDKey: formatKey,
                AVSampleRateKey: sampleRate,
                AVNumberOfChannelsKey: channels,
                AVEncoderBitRateKey: Int(options.bitRate) / perChannel,
                AVEncoderBitRateStrategyKey: AVAudioBitRateStrategy_Constant,
            ]
        } else {
            outputSettings = [
                AVFormatIDKey: formatKey,
                AVSampleRateKey: sampleRate,
                AVNumberOfChannelsKey: channels,
                AVLinearPCMBitDepthKey: bitDepth,
                AVLinearPCMIsFloatKey: isFloat,
                AVLinearPCMIsBigEndianKey: format != .wav,
                AVLinearPCMIsNonInterleaved: !(options.isInterleaved ?? inputFormat.isInterleaved),
            ]
        }

        let hint = asset.audioFormat?.formatDescription

        let writerInput = AVAssetWriterInput(mediaType: .audio, outputSettings: outputSettings, sourceFormatHint: hint)
        writer.add(writerInput)

        func tracksCompletion(tracks: [AVAssetTrack]?, error: Error?) {
            if let error {
                self.completionProxy(error: error, completionHandler: completionHandler)
                return
            }

            guard let track = tracks?.first else {
                self.completionProxy(error: Self.createError(message: "No audio was found in the input file."),
                                completionHandler: completionHandler)
                return
            }

            let readerOutput = AVAssetReaderTrackOutput(track: track, outputSettings: nil)
            guard reader.canAdd(readerOutput) else {
                self.completionProxy(error: Self.createError(message: "Unable to add reader output."),
                                completionHandler: completionHandler)
                return
            }
            reader.add(readerOutput)

            if !writer.startWriting() {
                Log("Failed to start writing. Error:", writer.error?.localizedDescription)
                self.completionProxy(error: writer.error,
                                completionHandler: completionHandler)
                return
            }

            writer.startSession(atSourceTime: CMTime.zero)

            if !reader.startReading() {
                Log("Failed to start reading. Error:", reader.error?.localizedDescription)
                self.completionProxy(error: reader.error,
                                completionHandler: completionHandler)
                return
            }

            let queue = DispatchQueue(label: "com.audiodesigndesk.ADD.FormatConverter.convertAsset")

            // session.progress could be sent out via a delegate for this session
            writerInput.requestMediaDataWhenReady(on: queue, using: {
                var processing = true // safety flag to prevent runaway loops if errors

                while writerInput.isReadyForMoreMediaData, processing {
                    if reader.status == .reading,
                       let buffer = readerOutput.copyNextSampleBuffer()
                    {
                        writerInput.append(buffer)

                    } else {
                        writerInput.markAsFinished()

                        switch reader.status {
                        case .failed:
                            Log("Conversion failed with error", reader.error)
                            writer.cancelWriting()
                            self.completionProxy(error: reader.error, completionHandler: completionHandler)
                        case .cancelled:
                            Log("Conversion cancelled")
                            self.completionProxy(error: Self.createError(message: "Process canceled"),
                                                 completionHandler: completionHandler)
                        case .completed:
                            writer.finishWriting {
                                switch writer.status {
                                case .failed:
                                    Log("Conversion failed at finishWriting")
                                    self.completionProxy(error: writer.error,
                                                         completionHandler: completionHandler)
                                default:
                                    // no errors
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

#if os(visionOS)
        asset.loadTracks(withMediaType: .audio) { tracks, error in
            tracksCompletion(tracks: tracks, error: error)
        }
#else
        let tracks = asset.tracks(withMediaType: .audio)
        tracksCompletion(tracks: tracks, error: nil)
#endif

    }
}
