//
//  AKAudioNodeRecorder.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Tweaked by Laurent Veliscek
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Simple audio recorder class
@objc open class AKNodeRecorder: NSObject {

    // MARK: - Properties

    // The node we record from
    fileprivate var node: AKNode?

    // The file to record to
    fileprivate var internalAudioFile: AKAudioFile

    /// True if we are recording.
    public private(set) dynamic var isRecording = false

    /// An optional duration for the recording to auto-stop when reached
    open var durationToRecord: Double = 0

    /// Duration of recording
    open var recordedDuration: Double {
        return internalAudioFile.duration
    }

    /// Used for fixing recordings being truncated
    fileprivate var recordBufferDuration: Double = 16_384 / AKSettings.sampleRate

    /// return the AKAudioFile for reading
    open var audioFile: AKAudioFile? {
        do {
            return try AKAudioFile(forReading: internalAudioFile.url)

        } catch let error as NSError {
            AKLog("Cannot create internal audio file for reading")
            AKLog("Error: \(error.localizedDescription)")
            return nil
        }

    }

    // MARK: - Initialization

    /// Initialize the node recorder
    ///
    /// Recording buffer size is defaulted to be AKSettings.bufferLength
    /// You can set a different value by setting an AKSettings.recordingBufferLength
    ///
    /// - Parameters:
    ///   - node: Node to record from
    ///   - file: Audio file to record to
    ///
    public init(node: AKNode? = AudioKit.output,
                file: AKAudioFile? = nil) throws {

        // AVAudioSession buffer setup

        guard let existingFile = file else {
            // We create a record file in temp directory
            do {
                internalAudioFile = try AKAudioFile()
            } catch let error as NSError {
                AKLog("AKNodeRecorder Error: Cannot create an empty audio file")
                throw error
            }
            self.node = node
            return
        }

        do {
            // We initialize AKAudioFile for writing (and check that we can write to)
            internalAudioFile = try AKAudioFile(forWriting: existingFile.url,
                                                settings: existingFile.processingFormat.settings)
        } catch let error as NSError {
            AKLog("AKNodeRecorder Error: cannot write to \(existingFile.fileNamePlusExtension)")
            throw error
        }

        self.node = node
    }

    // MARK: - Methods

    /// Start recording
    open func record() throws {
        if isRecording == true {
            AKLog("AKNodeRecorder Warning: already recording")
            return
        }

        guard let node = node else {
            AKLog("AKNodeRecorder Error: input node is not available")
            return
        }

        let recordingBufferLength: AVAudioFrameCount = AKSettings.recordingBufferLength.samplesCount
        isRecording = true

        AKLog("AKNodeRecorder: recording")
        node.avAudioNode.installTap(
            onBus: 0,
            bufferSize: recordingBufferLength,
            format: internalAudioFile.processingFormat) { (buffer: AVAudioPCMBuffer!, _) -> Void in
                do {
                    self.recordBufferDuration = Double(buffer.frameLength) / AKSettings.sampleRate
                    try self.internalAudioFile.write(from: buffer)
                    AKLog("AKNodeRecorder writing (file duration: \(self.internalAudioFile.duration) seconds)")

                    // allow an optional timed stop
                    if self.durationToRecord != 0 && self.internalAudioFile.duration >= self.durationToRecord {
                        self.stop()
                    }

                } catch let error as NSError {
                    AKLog("Write failed: error -> \(error.localizedDescription)")
                }
        }
    }

    /// Stop recording
    open func stop() {
        if isRecording == false {
            AKLog("AKNodeRecorder Warning: Cannot stop recording, already stopped")
            return
        }

        isRecording = false

        if AKSettings.fixTruncatedRecordings {
            //  delay before stopping so the recording is not truncated.
            let delay = UInt32(recordBufferDuration * 1_000_000)
            usleep(delay)
        }
        node?.avAudioNode.removeTap(onBus: 0)

    }

    /// Reset the AKAudioFile to clear previous recordings
    open func reset() throws {

        // Stop recording
        if isRecording == true {
            stop()
        }

        // Delete the physical recording file
        let fileManager = FileManager.default
        let settings = internalAudioFile.processingFormat.settings
        let url = internalAudioFile.url

        do {
            if let path = audioFile?.url.path {
                try fileManager.removeItem(atPath: path)
            }
        } catch let error as NSError {
            AKLog("AKNodeRecorder Error: cannot delete Recording file: \(audioFile?.fileNamePlusExtension ?? "nil")")
        }

        // Creates a blank new file
        do {
            internalAudioFile = try AKAudioFile(forWriting: url, settings: settings)
            AKLog("AKNodeRecorder: file has been cleared")
        } catch let error as NSError {
            AKLog("AKNodeRecorder Error: cannot record to file: \(internalAudioFile.fileNamePlusExtension)")
            throw error
        }
    }

}
