// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public class MultiChannelInputNodeTap {
    public class WriteableFile: CustomStringConvertible {
        public var description: String {
            "url: \(url), channel: \(channel), file is open: \(file != nil)"
        }

        /// the url being written to, persists after close
        public private(set) var url: URL

        public private(set) var fileFormat: AVAudioFormat

        /// the channel of the audio device this is reading from
        public private(set) var channel: Int32

        /// only valid when open for writing, then closed
        public private(set) var file: AVAudioFile?

        /// current amplitude being written represented as RMS
        public private(set) var amplitude: Float = 0

        public private(set) var duration: TimeInterval = 0

        /// array of amplitude values used to create temporary waveform
        public private(set) var amplitudeArray = [Float]()

        public private(set) var bufferDuration: TimeInterval = 0.1

        public init?(url: URL, fileFormat: AVAudioFormat, channel: Int32) {
            self.fileFormat = fileFormat
            self.channel = channel
            self.url = url
        }

        public func createFile() {
            guard file == nil else { return }

            do {
                file = try AVAudioFile(forWriting: url,
                                       settings: fileFormat.settings)

            } catch let error as NSError {
                Log(error, type: .error)
            }
        }

        public func process(buffer: AVAudioPCMBuffer, write: Bool) throws {
            amplitude = buffer.rms

            // Log(amplitude)

            if write, let file = file {
                // Log(url.lastPathComponent, amplitude)

                try file.write(from: buffer)
                amplitudeArray.append(amplitude)
                duration = Double(file.length) / fileFormat.sampleRate
                // duration of this buffer to write
                bufferDuration = Double(buffer.frameLength) / buffer.format.sampleRate
            }
        }

        public func close() {
            file = nil
            amplitudeArray.removeAll()
        }
    }

    /// a file name and its associated input channel
    public struct FileChannel {
        var name: String
        var channel: Int32
    }

    public weak var delegate: MultiChannelInputNodeTapDelegate?

    public private(set) var fileChannels: [FileChannel]? {
        didSet {
            guard let fileChannels = fileChannels else { return }
            channelMap = fileChannels.map { $0.channel }
        }
    }

    private let filesAccessQueue = DispatchQueue(label:
        "io.audiokit.MultiChannelInputNodeTap.filesAccessQueue")

    // The files to record to
    private var _files = [WriteableFile]()

    public var files: [WriteableFile] {
        get {
            filesAccessQueue.sync { self._files }
        }
        set {
            filesAccessQueue.async(flags: .barrier) {
                self._files = newValue
            }
        }
    }

    public private(set) var inputNode: AVAudioInputNode?

    public private(set) var isRecording = false {
        didSet {
            if isRecording {
                _ = files.map {
                    $0.createFile()
                }
            }
        }
    }

    public var currentAmplitudes: [Float] {
        files.map { $0.amplitude }
    }

    /// the incoming format from the audioUnit after the channel mapping.
    /// Any number of channels of audio data
    public private(set) var recordFormat: AVAudioFormat?

    /// the temp format of the buffer during processing, generally mono
    public private(set) var bufferFormat: AVAudioFormat?

    /// the ultimate file format to write to disk
    public private(set) var fileFormat: AVAudioFormat?

    /// sample rate for all formats and files
    public private(set) var sampleRate: Double = 48000

    /// fileFormat and bufferFormat
    public private(set) var channels: UInt32 = 1

    /// fileFormat only
    public private(set) var bitsPerChannel: UInt32 = 24

    public var bufferSize: AVAudioFrameCount = 2048

    /// Used for fixing recordings being truncated
    public private(set) var recordBufferDuration: Double = 0

    private var _recordEnabled: Bool = false

    /// Call to start watching the inputNode's incoming audio data.
    /// Enables prerecording monitoring, but must be enabled before recording as well
    public var recordEnabled: Bool {
        get { _recordEnabled }
        set {
            guard recordFormat != nil else {
                Log("recordFormat is nil")
                return
            }
            guard newValue != _recordEnabled else {
                Log("_recordEnabled is already set to", newValue)
                return
            }

            _recordEnabled = newValue

            if _recordEnabled {
                Log("🚰 Installing Tap with format", recordFormat)
                inputNode?.installTap(onBus: 0,
                                      bufferSize: bufferSize,
                                      format: recordFormat,
                                      block: process(buffer:time:))
                delegate?.tapInstalled(sender: self)
            } else {
                Log("🚰 Removing Tap")
                inputNode?.removeTap(onBus: 0)
                delegate?.tapRemoved(sender: self)
            }
        }
    }

    /// Base directory where to write files too such as an Audio Files directory.
    /// You must set this prior to recording
    public var directory: URL?

    private var recordCounter: Int = 0
    private var filesReady = false

    /**
     This property is used to map input channels from an input (source) to a destination.
     The number of channels represented in the channel map is the number of channels of the destination. The channel map entries
     contain a channel number of the source that should be mapped to that destination channel. If -1 is specified, then that
     destination channel will not contain any channel from the source (so it will be silent)
      */
    private var _channelMap: [Int32] = []
    private var channelMap: [Int32] {
        get { _channelMap }
        set {
            guard newValue != _channelMap else { return }

            Log("Attempting to update channelMap to", newValue)

            guard let audioUnit = inputNode?.audioUnit else {
                Log("inputNode.audioUnit is nil")
                return
            }
            let channelMapSize = UInt32(MemoryLayout<Int32>.size * newValue.count)

            // 1 is the 'input' element, 0 is output
            let inputElement: AudioUnitElement = 1

            let err = AudioUnitSetProperty(audioUnit,
                                           kAudioOutputUnitProperty_ChannelMap,
                                           kAudioUnitScope_Output,
                                           inputElement,
                                           newValue,
                                           channelMapSize)

            guard err == noErr else {
                Log("Failed setting channel map")
                return
            }

            _channelMap = newValue

            Log("Updated channelMap to", _channelMap)
            recordFormat = createRecordFormat(channelMap: newValue)
            recordEnabled = false
        }
    }

    private func createRecordFormat(channelMap: [Int32]) -> AVAudioFormat? {
        guard !channelMap.isEmpty else {
            Log("You must specify a valid channel map")
            return nil
        }

        let layoutTag = kAudioChannelLayoutTag_DiscreteInOrder | UInt32(channelMap.count)

        guard let channelLayout = AVAudioChannelLayout(layoutTag: layoutTag) else {
            Log("Failed creating AVAudioChannelLayout")
            return nil
        }

        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channelLayout: channelLayout)
        Log(format)
        return format
    }

    /// Currently assuming to write mono files based on the channelMap
    public init(inputNode: AVAudioInputNode) {
        self.inputNode = inputNode

        let outputFormat = inputNode.outputFormat(forBus: 0)
        sampleRate = outputFormat.sampleRate

        Log("inputNode", outputFormat.channelCount, "channels at", sampleRate, "kHz")
    }

    deinit {
        files.removeAll()
        inputNode = nil
    }

    // convenience for testing
    public func prepare(channelMap: [Int32]) {
        let fileChannels = channelMap.map {
            MultiChannelInputNodeTap.FileChannel(
                name: "Audio \($0 + 1)",
                channel: $0)
        }
        prepare(fileChannels: fileChannels)
    }

    /// Called with name and input channel pair.
    /// This allows you to associate a filename with an incoming channel.
    public func prepare(fileChannels: [FileChannel]) {
        self.fileChannels = fileChannels
        initFormats()
        createFiles()
        recordEnabled = true
    }

    private func initFormats() {
        bufferFormat = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: channels)
        Log("bufferFormat", bufferFormat)

        fileFormat = createFileFormat()
        Log("fileFormat", fileFormat)
    }

    private func createFileFormat() -> AVAudioFormat? {
        let outputBytesPerFrame = bitsPerChannel * channels / 8
        let outputBytesPerPacket = outputBytesPerFrame
        let formatFlags = kLinearPCMFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger

        var outDesc = AudioStreamBasicDescription(mSampleRate: sampleRate,
                                                  mFormatID: kAudioFormatLinearPCM,
                                                  mFormatFlags: formatFlags,
                                                  mBytesPerPacket: outputBytesPerPacket,
                                                  mFramesPerPacket: 1,
                                                  mBytesPerFrame: outputBytesPerFrame,
                                                  mChannelsPerFrame: channels,
                                                  mBitsPerChannel: bitsPerChannel,
                                                  mReserved: 0)

        return AVAudioFormat(streamDescription: &outDesc)
    }

    private func createFiles() {
        guard let directory = directory,
              let fileFormat = fileFormat,
              let recordFormat = recordFormat,
              let fileChannels = fileChannels else {
            Log("File Format is nil")
            return
        }

        guard recordFormat.channelCount == channelMap.count else {
            Log("Channel count mismatch", recordFormat.channelCount, "vs", channelMap.count)
            return
        }

        recordCounter += 1

        // remove last batch of files
        files.removeAll()

        // TODO: need file name array for named files per channel
        for i in 0 ..< fileChannels.count {
            let channel = fileChannels[i].channel
            let name = fileChannels[i].name

            var url = directory.appendingPathComponent("\(name) #\(recordCounter)" + ".wav")
            url = getUniqueURL(url)

            // clobber - temp
            if FileManager.default.fileExists(atPath: url.path) {
                try? FileManager.default.removeItem(at: url)
            }

            guard let channelObject = WriteableFile(url: url,
                                                    fileFormat: fileFormat,
                                                    channel: channel) else {
                Log("Failed to create file at", url)
                continue
            }

            files.append(channelObject)
        }

        Log("Created", files)

        filesReady = files.count == fileChannels.count
    }

    private func getUniqueURL(_ url: URL, suffix: String = "") -> URL {
        let fm = FileManager.default
        if !fm.fileExists(atPath: url.path) { return url }

        let pathExtension = url.pathExtension
        let baseFilename = url.deletingPathExtension().lastPathComponent + suffix
        let directory = url.deletingLastPathComponent()

        for i in 1 ... 1000 {
            let filename = "\(baseFilename)_\(i)"
            let test = directory.appendingPathComponent(filename).appendingPathExtension(pathExtension)
            if !fm.fileExists(atPath: test.path) { return test }
        }
        return url
    }

    // AVAudioNodeTapBlock
    private func process(buffer: AVAudioPCMBuffer, time: AVAudioTime) {
        guard let bufferFormat = bufferFormat else {
            Log("bufferFormat is nil")
            return
        }

        // will contain all channels of audio being recorded
        guard let channelData = buffer.floatChannelData else {
            Log("buffer.floatChannelData is nil")
            return
        }
        let channelCount = Int(buffer.format.channelCount)

        for channel in 0 ..< channelCount {
            // a temp buffer used to write this chunk to the file
            guard let channelBuffer = AVAudioPCMBuffer(pcmFormat: bufferFormat,
                                                       frameCapacity: buffer.frameLength) else {
                Log("Failed creating channelBuffer")
                return
            }

            for i in 0 ..< Int(buffer.frameLength) {
                channelBuffer.floatChannelData?[0][i] = channelData[channel][i]
            }
            channelBuffer.frameLength = buffer.frameLength

            guard files.indices.contains(channel) else {
                Log("Count mismatch")
                return
            }

            do {
                try files[channel].process(buffer: channelBuffer, write: isRecording)

            } catch let error as NSError {
                Log("Write failed", error)
            }
        }

        // Log(buffer.frameLength, "@", time)
        delegate?.dataProcessed(sender: self,
                                frameLength: buffer.frameLength,
                                time: time)
    }

    /// the tap is running as long as recordEnable is true. This just sets a flag that says
    /// write to file in the process block
    public func record() {
        guard !isRecording else {
            Log("Already recording")
            return
        }
        isRecording = true

        if !filesReady { createFiles() }

        // could also enforce explicitly calling recordEnable
        if !recordEnabled { recordEnabled = true }

        Log("⏺ Recording \(files.count) files using format", recordFormat.debugDescription)
    }

    /// Stops recording and closes files
    public func stop() {
        guard isRecording else {
            Log("Not Recording")
            return
        }
        isRecording = false
        filesReady = false

        for i in 0 ..< files.count {
            // release reference to the file. will close it and make it readable from url.
            files[i].close()
        }
        Log("⏹", files)
    }
}

public protocol MultiChannelInputNodeTapDelegate: class {
    func tapInstalled(sender: MultiChannelInputNodeTap)
    func tapRemoved(sender: MultiChannelInputNodeTap)

    /// Receive updates as data is captured. Useful for updating VU meters or waveforms
    func dataProcessed(sender: MultiChannelInputNodeTap,
                       frameLength: AVAudioFrameCount,
                       time: AVAudioTime)
}
