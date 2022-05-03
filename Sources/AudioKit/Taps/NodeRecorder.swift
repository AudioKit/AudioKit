// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// Simple audio recorder class, requires a minimum buffer length of 128 samples (.short)
open class NodeRecorder: NSObject {
    // MARK: - Properties

    /// The node we record from
    public private(set) var node: Node

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
    private var recordBufferDuration: Double = 16_384 / Settings.sampleRate

    /// return the AVAudioFile for reading
    open var audioFile: AVAudioFile? {
        do {
            guard let url = internalAudioFile?.url else { return nil }
            return try AVAudioFile(forReading: url)

        } catch let error as NSError {
            Log("Error, Cannot create internal audio file for reading: \(error.localizedDescription)")
            return nil
        }
    }

    private var fileDirectoryURL: URL

    private static var recordedFiles = [URL]()

    // MARK: - Initialization

    /// Initialize the node recorder
    ///
    /// Recording buffer size is Settings.recordingBufferLength
    ///
    /// - Parameters:
    ///   - node: Node to record from
    ///   - file: Audio file to record to
    ///   - fileDirectoryPath: Directory to write audio files to
    ///   - bus: Integer index of the bus to use
    ///
    public init(node: Node,
                file: AVAudioFile? = nil,
                fileDirectoryURL: URL? = nil,
                bus: Int = 0) throws {
        self.node = node
        self.fileDirectoryURL = fileDirectoryURL ?? URL(fileURLWithPath: NSTemporaryDirectory())
        super.init()

        let audioFile = file ?? NodeRecorder.createAudioFile(fileDirectoryURL: self.fileDirectoryURL)

        guard audioFile != nil else {
            Log("Error, no file to write to")
            return
        }

        internalAudioFile = audioFile

        self.bus = bus
    }

    // MARK: - Methods

    /// Use Date and Time as Filename
    private static func createDateFileName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH-mm-ss.SSSS"
        return dateFormatter.string(from: Date())
    }

    /// Returns a CAF file in specified directory suitable for writing to via Settings.audioFormat
    public static func createAudioFile(fileDirectoryURL: URL = URL(fileURLWithPath: NSTemporaryDirectory())) -> AVAudioFile? {
        let filename = createDateFileName() + ".caf"
        let url = fileDirectoryURL.appendingPathComponent(filename)
        var settings = Settings.audioFormat.settings
        settings[AVLinearPCMIsNonInterleaved] = NSNumber(value: false)

        Log("Creating temp file at", url)
        guard let audioFile = try? AVAudioFile(forWriting: url,
                                             settings: settings,
                                             commonFormat: Settings.audioFormat.commonFormat,
                                             interleaved: true) else { return nil }

        recordedFiles.append(url)
        return audioFile
    }

    /// When done with this class, remove any audio files that were created with createAudioFile()
    public static func removeRecordedFiles() {
        for url in NodeRecorder.recordedFiles {
            try? FileManager.default.removeItem(at: url)
            Log("𝗫 Deleted tmp file at", url)
        }
        NodeRecorder.recordedFiles.removeAll()
    }

    /// Start recording
    public func record() throws {
        if isRecording == true {
            Log("Warning: already recording")
            return
        }

        if let path = internalAudioFile?.url.path, !FileManager.default.fileExists(atPath: path) {
            // record to new audio file
            if let audioFile = NodeRecorder.createAudioFile(fileDirectoryURL: fileDirectoryURL) {
                internalAudioFile = try AVAudioFile(forWriting: audioFile.url,
                                                    settings: audioFile.fileFormat.settings)
            }
        }

        let bufferLength: AVAudioFrameCount = Settings.recordingBufferLength.samplesCount
        isRecording = true

        // Note: if you install a tap on a bus that already has a tap it will crash your application.
        Log("⏺ Recording using format", internalAudioFile?.processingFormat.debugDescription)

        // note, format should be nil as per the documentation for installTap:
        // "If non-nil, attempts to apply this as the format of the specified output bus. This should
        // only be done when attaching to an output bus which is not connected to another node"
        // In most cases AudioKit nodes will be attached to something else.

        // Make sure the input node has an engine
        // before recording
        if node.avAudioNode.engine == nil {
            Log("🛑 Error: Error recording. Input node '\(node)' has no engine.")
            isRecording = false
            return
        }

        node.avAudioNode.installTap(onBus: bus,
                                    bufferSize: bufferLength,
                                    format: recordFormat,
                                    block: process(buffer:time:))
    }

    private func process(buffer: AVAudioPCMBuffer, time: AVAudioTime) {
        guard let internalAudioFile = internalAudioFile else { return }

        do {
            recordBufferDuration = Double(buffer.frameLength) / Settings.sampleRate
            try internalAudioFile.write(from: buffer)

            // allow an optional timed stop
            if durationToRecord != 0 && internalAudioFile.duration >= durationToRecord {
                stop()
            }

        } catch let error as NSError {
            Log("Write failed: error -> \(error.localizedDescription)")
        }
    }

    /// Stop recording
    public func stop() {
        if isRecording == false {
            Log("Warning: Cannot stop recording, already stopped")
            return
        }

        isRecording = false

        if Settings.fixTruncatedRecordings {
            //  delay before stopping so the recording is not truncated.
            let delay = UInt32(recordBufferDuration * 1_000_000)
            usleep(delay)
        }
        node.avAudioNode.removeTap(onBus: bus)
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
        let settings = internalAudioFile.fileFormat.settings
        let url = internalAudioFile.url

        do {
            if let path = audioFile?.url.path {
                try fileManager.removeItem(atPath: path)
            }
        } catch let error as NSError {
            Log("Error: Can't delete" + (audioFile?.url.lastPathComponent ?? "nil") + error.localizedDescription)
        }

        // Creates a blank new file
        do {
            self.internalAudioFile = try AVAudioFile(forWriting: url, settings: settings)
            Log("File has been cleared")
        } catch let error as NSError {
            Log("Error: Can't record to" + url.lastPathComponent)
            throw error
        }
    }

    /// Creates a new audio file for recording
    public func createNewFile() {
        if isRecording == true {
            stop()
        }

        self.internalAudioFile = NodeRecorder.createAudioFile(fileDirectoryURL: self.fileDirectoryURL)
    }
}
