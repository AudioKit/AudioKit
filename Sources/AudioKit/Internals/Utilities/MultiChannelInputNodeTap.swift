// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// A tap to record multiple channels to files
public final class MultiChannelInputNodeTap {
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

    @ThreadLockedAccessor public var files = [WriteableFile]()

    public private(set) var inputNode: AVAudioInputNode?

    public private(set) var isRecording = false {
        didSet {
            if isRecording {
                startedAtTime = AVAudioTime(hostTime: mach_absolute_time())

                Log("⏺", files.count, " to record", startedAtTime)
                _ = files.map {
                    $0.createFile()
                }
            } else {
                stoppedAtTime = AVAudioTime(hostTime: mach_absolute_time())
                Log("⏹", files.count, "recorded", stoppedAtTime)
            }
        }
    }

    /// the incoming format from the audioUnit after the channel mapping.
    /// Any number of channels of audio data
    public private(set) var recordFormat: AVAudioFormat?

    /// the temp format of the buffer during processing, generally mono
    public private(set) var bufferFormat: AVAudioFormat?

    /// the ultimate file format to write to disk
    public private(set) var fileFormat: AVAudioFormat?

    /// sample rate for all formats and files, this will be pulled from the
    /// format of the AVAudioInputNode
    public private(set) var sampleRate: Double = 48000

    /// fileFormat and bufferFormat - currently mono from each channel defined
    public private(set) var channels: UInt32 = 1

    /// 24 bit recording
    public private(set) var bitsPerChannel: UInt32 = 24

    private var _bufferSize: AVAudioFrameCount = 2048

    /// The requested size of the incoming buffers. The implementation may choose another size.
    /// I'm seeing it set to 4800 on macOS in general. Given that I'm unclear why they offer
    /// us a choice
    public var bufferSize: AVAudioFrameCount {
        get { _bufferSize }
        set {
            _bufferSize = newValue
            Log("Attempting to set bufferSize to", newValue, "The implementation may choose another size.")
        }
    }

    private var _recordEnabled: Bool = false

    /// Call to start watching the inputNode's incoming audio data.
    /// Enables prerecording monitoring, but must be enabled before recording as well
    public var recordEnabled: Bool {
        get { _recordEnabled }
        set {
            guard recordFormat != nil, newValue != _recordEnabled else { return }

            _recordEnabled = newValue

            if _recordEnabled {
                Log("🚰 Installing Tap with format", recordFormat, "bufferSize", bufferSize)
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

    private var _recordCounter: Int = 1
    public var recordCounter: Int {
        get { _recordCounter }
        set {
            _recordCounter = max(1, newValue)
        }
    }

    private var filesReady = false

    public private(set) var startedAtTime: AVAudioTime?
    public private(set) var stoppedAtTime: AVAudioTime?

    public var durationRecorded: TimeInterval? {
        guard let startedAtTime = startedAtTime,
              let stoppedAtTime = stoppedAtTime else {
            return nil
        }
        return AVAudioTime.seconds(forHostTime: stoppedAtTime.hostTime) -
            AVAudioTime.seconds(forHostTime: startedAtTime.hostTime)
    }

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

            if noErr != AudioUnitSetProperty(audioUnit,
                                             kAudioOutputUnitProperty_ChannelMap,
                                             kAudioUnitScope_Output,
                                             inputElement,
                                             newValue,
                                             channelMapSize) {
                Log("Failed setting channel map")
                return
            }

            _channelMap = newValue

            Log("Updated channelMap to", _channelMap)
            recordFormat = createRecordFormat(channelMap: newValue)
            recordEnabled = false
        }
    }

    /// Optional latency offset that you can set by determining the correct latency
    /// for your hardware. This amount of samples will be skipped by the first write.
    /// While AVAudioInputNode provides a `presentationLatency` value, I don't see the
    /// value returned being accurate on macOS. For lack of the CoreAudio latency
    /// calculations, you could use that value. Default value is zero.
    public var ioLatency: AVAudioFrameCount = 0

    // MARK: - Init

    /// Currently assuming to write mono files based on the channelMap
    public init(inputNode: AVAudioInputNode) {
        self.inputNode = inputNode

        let outputFormat = inputNode.outputFormat(forBus: 0)
        sampleRate = outputFormat.sampleRate

        Log("inputNode", outputFormat.channelCount, "channels at", sampleRate, "kHz")
    }

    deinit {
        Log("* { MultiChannelInputNodeTap }")
        delegate = nil
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

    // MARK: - Formats

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
        Log("recordFormat", format)
        return format
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

        // remove last batch of files
        files.removeAll()

        for i in 0 ..< fileChannels.count {
            let channel = fileChannels[i].channel
            let name = fileChannels[i].name

            guard let url = getNextURL(directory: directory, name: name, startIndex: recordCounter) else {
                Log("Failed to create URL in", directory, "with name", name)
                continue
            }

            // clobber - TODO: make it an option
            if FileManager.default.fileExists(atPath: url.path) {
                Log("Warning, deleting existing record file at", url)
                try? FileManager.default.removeItem(at: url)
            }

            Log("Creating destination:", url.path)

            let channelObject = WriteableFile(url: url,
                                              fileFormat: fileFormat,
                                              channel: channel,
                                              ioLatency: ioLatency)

            files.append(channelObject)
        }

        Log("Created", files, "latency in frames", ioLatency)

        filesReady = files.count == fileChannels.count

        // record counter to be saved in the project and restored
        recordCounter += 1
    }

    private func getNextURL(directory: URL, name: String, startIndex: Int) -> URL? {
        let url = directory.appendingPathComponent(name).appendingPathExtension("wav")

        let fm = FileManager.default
        // if !fm.fileExists(atPath: url.path) { return url }

        let pathExtension = url.pathExtension
        let baseFilename = url.deletingPathExtension().lastPathComponent

        for i in startIndex ... 10000 {
            let filename = "\(baseFilename) #\(i)"
            let test = directory.appendingPathComponent(filename).appendingPathExtension(pathExtension)
            if !fm.fileExists(atPath: test.path) { return test }
        }
        return nil
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
                try files[channel].process(buffer: channelBuffer,
                                           time: time,
                                           write: isRecording)

            } catch let error as NSError {
                Log("Write failed", error)
            }
        }

        if _recordEnabled {
            // Log(buffer.frameLength, "@", time)
            delegate?.dataProcessed(sender: self,
                                    frameLength: buffer.frameLength,
                                    time: time)
        }
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

    /// Receive updates as data is captured. Useful for updating VU meters or waveforms.
    /// In cases where a DAW has a record enabled track that wants to show input levels
    /// outside of tracking recording, this is how.
    func dataProcessed(sender: MultiChannelInputNodeTap,
                       frameLength: AVAudioFrameCount,
                       time: AVAudioTime)
}
