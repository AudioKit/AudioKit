// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// Simple audio recorder class
open class AKNodeRecorder: NSObject {
    // MARK: - Properties

    // The node we record from
    public private(set) var node: AKNode

    /// True if we are recording.
    public private(set) var isRecording = false

    /// An optional duration for the recording to auto-stop when reached
    open var durationToRecord: Double = 0

    /// Duration of recording
    open var recordedDuration: Double {
        return internalAudioFile?.duration ?? 0
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
    private var internalAudioFile: AVAudioFile?

    /// The bus to install the recording tap on. Default is 0.
    private var bus: Int = 0

    /// Used for fixing recordings being truncated
    private var recordBufferDuration: Double = 16_384 / AKSettings.sampleRate

    /// return the AVAudioFile for reading
    open var audioFile: AVAudioFile? {
        do {
            guard let url = internalAudioFile?.url else { return nil }
            return try AVAudioFile(forReading: url)

        } catch let error as NSError {
            AKLog("Error, Cannot create internal audio file for reading: \(error.localizedDescription)")
            return nil
        }
    }

    private static var tmpFiles = [URL]()

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
    public init(node: AKNode,
                file: AVAudioFile? = AKNodeRecorder.createTempFile(),
                bus: Int = 0) throws {
        self.node = node
        super.init()

        guard let file = file else {
            AKLog("Error, no file to write to")
            return
        }

        do {
            // We initialize AVAudioFile for writing (and check that we can write to)
            internalAudioFile = try AVAudioFile(forWriting: file.url,
                                                settings: file.fileFormat.settings)
        } catch let error as NSError {
            AKLog("Error: cannot write to", file.url)
            throw error
        }

        self.bus = bus
    }

    // MARK: - Methods

    // Returns a CAF file in the NSTemporaryDirectory suitable for writing to via AKSettings.audioFormat
    public static func createTempFile() -> AVAudioFile? {
        let filename = UUID().uuidString + ".caf"
        let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(filename)
        var settings = AKSettings.audioFormat.settings
        settings[AVLinearPCMIsNonInterleaved] = NSNumber(value: false)

        AKLog("Creating temp file at", url)
        guard let tmpFile = try? AVAudioFile(forWriting: url,
                                             settings: settings,
                                             commonFormat: AKSettings.audioFormat.commonFormat,
                                             interleaved: true) else { return nil }

        tmpFiles.append(url)
        return tmpFile
    }

    // When done with this class, remove any temp files that were created with createTempFile()
    public static func removeTempFiles() {
        for url in AKNodeRecorder.tmpFiles {
            try? FileManager.default.removeItem(at: url)
            AKLog("𝗫 Deleted tmp file at", url)
        }
        AKNodeRecorder.tmpFiles.removeAll()
    }

    /// Start recording
    public func record() throws {
        if isRecording == true {
            AKLog("Warning: already recording")
            return
        }

        if let path = internalAudioFile?.url.path, !FileManager.default.fileExists(atPath: path) {
            // record to new tmp file
            if let tmpFile = AKNodeRecorder.createTempFile() {
                internalAudioFile = try AVAudioFile(forWriting: tmpFile.url,
                                                    settings: tmpFile.fileFormat.settings)
            }
        }

        let bufferLength: AVAudioFrameCount = AKSettings.recordingBufferLength.samplesCount
        isRecording = true

        // Note: if you install a tap on a bus that already has a tap it will crash your application.
        AKLog("⏺ Recording using format", internalAudioFile?.processingFormat.debugDescription)

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
        guard let internalAudioFile = internalAudioFile else { return }

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
    public func stop() {
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
        node.avAudioUnitOrNode.removeTap(onBus: bus)
    }

    /// Reset the AVAudioFile to clear previous recordings
    public func reset() throws {
        // Stop recording
        if isRecording == true {
            stop()
        }

        guard let internalAudioFile = internalAudioFile else { return }

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
            self.internalAudioFile = try AVAudioFile(forWriting: url, settings: settings)
            AKLog("File has been cleared")
        } catch let error as NSError {
            AKLog("Error: Can't record to" + url.lastPathComponent)
            throw error
        }
    }
}
