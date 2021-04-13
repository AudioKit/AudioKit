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
    func convertCompressed(presetName: String, completionHandler: FormatConverterCallback? = nil) {
        guard let inputURL = self.inputURL else {
            completionHandler?(Self.createError(message: "Input file can't be nil."))
            return
        }
        guard let outputURL = self.outputURL else {
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

    func convertCompressed(completionHandler: FormatConverterCallback? = nil) {
        guard let inputURL = self.inputURL else {
            completionHandler?(Self.createError(message: "Input file can't be nil."))
            return
        }
        guard let outputURL = self.outputURL else {
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
        tempOptions.format = "wav"

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

        guard let reader = self.reader else {
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
            Log("Unsupported output format: \(outputFormat)")
            return
        }

        do {
            self.writer = try AVAssetWriter(outputURL: outputURL, fileType: format)
        } catch let err as NSError {
            completionHandler?(err)
            return
        }

        guard let writer = self.writer else {
            completionHandler?(Self.createError(message: "Unable to setup the AVAssetWriter."))
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

        if sampleRate == 0 {
            Log("Sample rate can't be 0 - assigning to default format of 48k. inputFormat is", inputFormat)
            sampleRate = 48000
        }
        var outputSettings: [String: Any] = [
            AVFormatIDKey: formatKey,
            AVSampleRateKey: sampleRate,
            AVNumberOfChannelsKey: channels,
            AVLinearPCMBitDepthKey: bitDepth,
            AVLinearPCMIsFloatKey: isFloat,
            AVLinearPCMIsBigEndianKey: format != .wav,
            AVLinearPCMIsNonInterleaved: !(options.isInterleaved ?? inputFormat.isInterleaved),
        ]

        // Note: AVAssetReaderOutput does not currently support compressed audio?
        if formatKey == kAudioFormatMPEG4AAC {
            if sampleRate > 48000 {
                sampleRate = 48000
            }
            // reset these for m4a:
            outputSettings = [
                AVFormatIDKey: formatKey,
                AVSampleRateKey: sampleRate,
                AVNumberOfChannelsKey: channels,
                AVEncoderBitRateKey: Int(options.bitRate),
                AVEncoderBitRateStrategyKey: AVAudioBitRateStrategy_Constant,
            ]
        }

        let writerInput = AVAssetWriterInput(mediaType: .audio, outputSettings: outputSettings)
        writer.add(writerInput)

        guard let track = asset.tracks(withMediaType: .audio).first else {
            completionHandler?(Self.createError(message: "No audio was found in the input file."))
            return
        }

        let readerOutput = AVAssetReaderTrackOutput(track: track, outputSettings: nil)
        guard reader.canAdd(readerOutput) else {
            completionHandler?(Self.createError(message: "Unable to add reader output."))
            return
        }
        reader.add(readerOutput)

        if !writer.startWriting() {
            Log("Failed to start writing. Error:", writer.error?.localizedDescription)
            completionHandler?(writer.error)
            return
        }

        writer.startSession(atSourceTime: CMTime.zero)

        if !reader.startReading() {
            Log("Failed to start reading. Error:", reader.error?.localizedDescription)
            completionHandler?(reader.error)
            return
        }

        let queue = DispatchQueue(label: "com.audiodesigndesk.ADD.FormatConverter.convertAsset")

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
                        Log("Conversion failed with error", reader.error)
                        writer.cancelWriting()
                        completionHandler?(reader.error)
                    case .cancelled:
                        Log("Conversion cancelled")
                        completionHandler?(nil)
                    case .completed:
                        // writer.endSession(atSourceTime: asset.duration)
                        writer.finishWriting {
                            switch writer.status {
                            case .failed:
                                completionHandler?(writer.error)
                            default:
                                // Log("Conversion complete")
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
}
