// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import Utilities
import Audio

/// Simple audio recorder class, requires a minimum buffer length of 128 samples (.short)
final class Recorder {
    // MARK: - Properties

    /// True if we are recording.
    public private(set) var isRecording = false

    /// True if we are paused
    public private(set) var isPaused = false

    /// An optional duration for the recording to auto-stop when reached
    public var durationToRecord: Double = 0

    /// Duration of recording
    public var recordedDuration: Double {
        return internalAudioFile?.duration ?? 0
    }

    /// If non-nil, attempts to apply this as the format of the specified output bus. This should
    /// only be done when attaching to an output bus which is not connected to another node; an
    /// error will result otherwise.
    /// The tap and connection formats (if non-nil) on the specified bus should be identical.
    /// Otherwise, the latter operation will override any previously set format.
    ///
    /// Default is nil.
    public var recordFormat: AVAudioFormat?

    // The file to record to
    private var internalAudioFile: AVAudioFile?

    /// The bus to install the recording tap on. Default is 0.
    private var bus: Int = 0

    /// Used for fixing recordings being truncated
    private var recordBufferDuration: Double = 16384 / Settings.sampleRate

    /// return the AVAudioFile for reading
    public var audioFile: AVAudioFile? {
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

    private static var recordedFiles = [URL]()

    // MARK: - Initialization

    /// Initialize the node recorder
    ///
    /// - Parameters:
    ///   - fileDirectoryPath: Directory to write audio files to
    ///   - shouldCleanupRecordings: Determines if recorded files are deleted upon deinit (default = true)
    ///
    public init(fileDirectoryURL: URL? = nil,
                shouldCleanupRecordings: Bool = true) throws
    {
        self.fileDirectoryURL = fileDirectoryURL ?? URL(fileURLWithPath: NSTemporaryDirectory())
        self.shouldCleanupRecordings = shouldCleanupRecordings
        createNewFile()
    }

    deinit {
        if shouldCleanupRecordings { Recorder.removeRecordedFiles() }
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
        for url in Recorder.recordedFiles {
            try? FileManager.default.removeItem(at: url)
            Log("𝗫 Deleted tmp file at", url)
        }
        Recorder.recordedFiles.removeAll()
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
            if let audioFile = Recorder.createAudioFile(fileDirectoryURL: fileDirectoryURL) {
                internalAudioFile = try AVAudioFile(forWriting: audioFile.url,
                                                    settings: audioFile.fileFormat.settings)
            }
        }

        isRecording = true
        Log("⏺ Recording using format", internalAudioFile?.processingFormat.debugDescription)
    }

    func add(buffer: AVAudioPCMBuffer, time: AVAudioTime) {
        guard let internalAudioFile = internalAudioFile else { return }

        do {
            if !isPaused {
                recordBufferDuration = Double(buffer.frameLength) / Settings.sampleRate
                try internalAudioFile.write(from: buffer)

                // allow an optional timed stop
                if durationToRecord != 0, internalAudioFile.duration >= durationToRecord {
                    stop()
                }
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

        internalAudioFile = Recorder.createAudioFile(fileDirectoryURL: fileDirectoryURL)
    }
}
