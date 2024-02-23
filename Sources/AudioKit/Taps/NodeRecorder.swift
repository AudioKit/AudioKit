// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// Simple audio recorder class, requires a minimum buffer length of 128 samples (.short)
open class NodeRecorder: NSObject {
    // MARK: - Properties

    /// The node we record from
    public private(set) var node: Node

    /// True if we are recording.
    public private(set) var isRecording = false

    /// True if we are paused
    public private(set) var isPaused = false

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
    private var recordBufferDuration: Double = 16384 / Settings.sampleRate

    /// return the AVAudioFile for reading
    open var audioFile: AVAudioFile? {
        do {
            if internalAudioFile != nil {
                closeFile(file: &internalAudioFile)
            }
            guard let url = recordedFileURL else { return nil }
            return try AVAudioFile(forReading: url)

        } catch let error as NSError {
            Log("Error, Cannot create internal audio file for reading: \(error.localizedDescription)")
            return nil
        }
    }

    /// Directory audio files will be written to
    private var fileDirectoryURL: URL

    private var shouldCleanupRecordings: Bool

    private var recordedFileURL: URL?

    public static var recordedFiles = [URL]()

    /// Callback type
    public typealias AudioDataCallback = ([Float], AVAudioTime) -> Void

    /// Callback of incoming audio floating point values and time stamp for monitoring purposes
    public var audioDataCallback: AudioDataCallback?

    // MARK: - Initialization

    /// Initialize the node recorder
    ///
    /// Recording buffer size is Settings.recordingBufferLength
    ///
    /// - Parameters:
    ///   - node: Node to record from
    ///   - fileDirectoryPath: Directory to write audio files to
    ///   - bus: Integer index of the bus to use
    ///   - shouldCleanupRecordings: Determines if recorded files are deleted upon deinit (default = true)
    ///   - audioDataCallback: Callback after each buffer processing with raw audio data and time stamp
    ///
    public init(node: Node,
                fileDirectoryURL: URL? = nil,
                bus: Int = 0,
                shouldCleanupRecordings: Bool = true,
                audioDataCallback: AudioDataCallback? = nil) throws
    {
        self.node = node
        self.fileDirectoryURL = fileDirectoryURL ?? URL(fileURLWithPath: NSTemporaryDirectory())
        self.shouldCleanupRecordings = shouldCleanupRecordings
        self.audioDataCallback = audioDataCallback
        super.init()

        createNewFile()

        self.bus = bus
    }

    deinit {
        if shouldCleanupRecordings { NodeRecorder.removeRecordedFiles() }
    }

    // MARK: - Methods

    /// Use Date and Time as Filename
    private static func createDateFileName() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH-mm-ss.SSSS"
        return dateFormatter.string(from: Date())
    }

    /// Open file a for recording
    /// - Parameter file: Reference to the file you want to record to
    /// Has to be optional because the file will be set to `nil` after recording.
    public func openFile(file: inout AVAudioFile?) {
        internalAudioFile = file
        // Close the file object passed in, try returning another one for reading after
        closeFile(file: &file)
    }

    /// Close file after recording
    /// - Parameter file: Reference to the file you want to close
    public func closeFile(file: inout AVAudioFile?) {
        if let fileURL = file?.url {
            // Keep track of file URL before closing
            recordedFileURL = fileURL
        }
        file = nil
    }

    /// Returns a CAF file in specified directory suitable for writing to via Settings.audioFormat
    public static func createAudioFile(fileDirectoryURL: URL = URL(fileURLWithPath: NSTemporaryDirectory())) -> AVAudioFile? {
        let filename = createDateFileName() + ".caf"
        let url = fileDirectoryURL.appendingPathComponent(filename)
        var settings = Settings.audioFormat.settings
        settings[AVLinearPCMIsNonInterleaved] = NSNumber(value: false)

        Log("Creating temp file at", url)
        guard let audioFile = try? AVAudioFile(forWriting: url,
                                               settings: settings) else { return nil }

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

        if internalAudioFile == nil {
            createNewFile()
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
            if !isPaused {
                recordBufferDuration = Double(buffer.frameLength) / Settings.sampleRate
                try internalAudioFile.write(from: buffer)

                // allow an optional timed stop
                if durationToRecord != 0, internalAudioFile.duration >= durationToRecord {
                    stop()
                }

                if audioDataCallback != nil {
                    doHandleTapBlock(buffer: buffer, time: time)
                }
            }
        } catch let error as NSError {
            Log("Write failed: error -> \(error.localizedDescription)")
        }
    }

    /// When a raw data tap handler is provided, we call it back with the recorded float values
    private func doHandleTapBlock(buffer: AVAudioPCMBuffer, time: AVAudioTime) {
        guard buffer.floatChannelData != nil else { return }

        let offset = Int(buffer.frameCapacity - buffer.frameLength)
        var data = [Float]()
        if let channelData = buffer.floatChannelData?[0] {
            for index in 0 ..< buffer.frameLength {
                data.append(channelData[offset + Int(index)])
            }
        }
        audioDataCallback?(data, time)
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

        // Unpause if paused
        if isPaused {
            isPaused = false
        }
    }

    /// Pause recording
    public func pause() {
        isPaused = true
    }

    /// Resume recording
    public func resume() {
        isPaused = false
    }

    /// Reset the AVAudioFile to clear previous recordings
    public func reset() throws {
        // Stop recording
        if isRecording == true {
            stop()
        }

        guard let audioFile = audioFile else { return }

        // Delete the physical recording file
        do {
            let path = audioFile.url.path
            let fileManager = FileManager.default
            try fileManager.removeItem(atPath: path)
        } catch let error as NSError {
            Log("Error: Can't delete" + (audioFile.url.lastPathComponent) + error.localizedDescription)
        }

        // Creates a blank new file
        let url = audioFile.url
        do {
            let settings = audioFile.fileFormat.settings
            internalAudioFile = try AVAudioFile(forWriting: url, settings: settings)
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

        internalAudioFile = NodeRecorder.createAudioFile(fileDirectoryURL: fileDirectoryURL)
    }
}
