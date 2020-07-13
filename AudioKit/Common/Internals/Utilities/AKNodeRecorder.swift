// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Simple audio recorder class
open class AKNodeRecorder: NSObject {
    // MARK: - Properties

    // The node we record from
    public private(set) var node: AKNode?

    /// True if we are recording.
    @objc public private(set) dynamic var isRecording = false

    /// An optional duration for the recording to auto-stop when reached
    open var durationToRecord: Double = 0

    /// Duration of recording
    open var recordedDuration: Double {
        return internalAudioFile.duration
    }

    /// If non-nil, attempts to apply this as the format of the specified output bus. This should
    /// only be done when attaching to an output bus which is not connected to another node; an
    /// error will result otherwise.
    /// The tap and connection formats (if non-nil) on the specified bus should be identical.
    /// Otherwise, the latter operation will override any previously set format.
    ///
    /// Default is nil.
    open var recordFormat: AVAudioFormat?

    // The file to record to
    private var internalAudioFile: AVAudioFile

    /// The bus to install the recording tap on. Default is 0.
    private var bus: Int = 0

    /// Used for fixing recordings being truncated
    private var recordBufferDuration: Double = 16_384 / AKSettings.sampleRate

    /// return the AVAudioFile for reading
    open var audioFile: AVAudioFile? {
        do {
            return try AVAudioFile(forReading: internalAudioFile.url)

        } catch let error as NSError {
            AKLog("Error, Cannot create internal audio file for reading: \(error.localizedDescription)")
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
    ///   - bus: Integer index of the bus to use
    ///
    @objc public init(node: AKNode? = AKManager.output,
                      file: AVAudioFile? = nil,
                      bus: Int = 0) throws {
        guard let existingFile = file else {
            internalAudioFile = AVAudioFile()
            self.node = node
            return
        }

        do {
            // We initialize AVAudioFile for writing (and check that we can write to)
            internalAudioFile = try AVAudioFile(forWriting: existingFile.url,
                                                settings: existingFile.fileFormat.settings)
        } catch let error as NSError {
            AKLog("Error: cannot write to \(existingFile.url.lastPathComponent)")
            throw error
        }

        self.bus = bus
        self.node = node
    }

    // MARK: - Methods

    /// Start recording
    open func record() throws {
        if isRecording == true {
            AKLog("Warning: already recording")
            return
        }

        guard let node = node else {
            AKLog("Error: input node is nil")
            return
        }

        let bufferLength: AVAudioFrameCount = AKSettings.recordingBufferLength.samplesCount
        isRecording = true

        // Note: if you install a tap on a bus that already has a tap it will crash your application.
        AKLog("Recording using format \(internalAudioFile.processingFormat.debugDescription)")

        // note, format should be nil as per the documentation for installTap:
        // "If non-nil, attempts to apply this as the format of the specified output bus. This should
        // only be done when attaching to an output bus which is not connected to another node"
        // In most cases AudioKit nodes will be attached to something else.
        node.avAudioUnitOrNode.installTap(onBus: bus,
                                          bufferSize: bufferLength,
                                          format: recordFormat,
                                          block: process(buffer:time:))
    }

    private func process(buffer: AVAudioPCMBuffer, time: AVAudioTime) {
        do {
            recordBufferDuration = Double(buffer.frameLength) / AKSettings.sampleRate
            try internalAudioFile.write(from: buffer)

            // allow an optional timed stop
            if durationToRecord != 0 && internalAudioFile.duration >= durationToRecord {
                stop()
            }

        } catch let error as NSError {
            AKLog("Write failed: error -> \(error.localizedDescription)")
        }
    }

    /// Stop recording
    open func stop() {
        if isRecording == false {
            AKLog("Warning: Cannot stop recording, already stopped")
            return
        }

        isRecording = false

        if AKSettings.fixTruncatedRecordings {
            //  delay before stopping so the recording is not truncated.
            let delay = UInt32(recordBufferDuration * 1_000_000)
            usleep(delay)
        }
        node?.avAudioUnitOrNode.removeTap(onBus: bus)
    }

    /// Reset the AVAudioFile to clear previous recordings
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
            AKLog("Error: Can't delete" + (audioFile?.url.lastPathComponent ?? "nil") + error.localizedDescription)
        }

        // Creates a blank new file
        do {
            internalAudioFile = try AVAudioFile(forWriting: url, settings: settings)
            AKLog("File has been cleared")
        } catch let error as NSError {
            AKLog("Error: Can't record to" + url.lastPathComponent)
            throw error
        }
    }
}
