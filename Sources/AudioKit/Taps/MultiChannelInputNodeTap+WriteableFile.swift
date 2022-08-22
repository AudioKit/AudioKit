// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public extension MultiChannelInputNodeTap {
    /// An inner class to represent one channel of data to record to file
    class WriteableFile: CustomStringConvertible {
        /// Simple description of the file
        public var description: String {
            "url: \(url.path), channel: \(channel), file is open: \(file != nil)"
        }

        /// The url being written to, persists after close
        public private(set) var url: URL

        /// The file format being written
        public private(set) var fileFormat: AVAudioFormat

        /// The channel of the audio device this is reading from
        public private(set) var channel: Int32

        /// This is the internal file which is only valid when open for writing, then nil'd
        /// out to allow its release
        public private(set) var file: AVAudioFile?

        /// Current amplitude being written represented as RMS. Suitable for use with a VU meter
        public private(set) var amplitude: Float = 0

        /// Total current duration of the file, will increment while writing
        public private(set) var duration: TimeInterval = 0

        /// An array of amplitude values used to create a temporary waveform for display
        /// while recording is progressing
        public private(set) var amplitudeArray = [Float]()

        /// Timestamp when the first samples appear in the process block during writing
        public private(set) var timestamp: AVAudioTime?

        /// Create the file, passing in an optional hardware latency
        public init(url: URL,
                    fileFormat: AVAudioFormat,
                    channel: Int32,
                    ioLatency: AVAudioFrameCount = 0)
        {
            self.fileFormat = fileFormat
            self.channel = channel
            self.url = url
            self.ioLatency = ioLatency
        }

        internal func createFile() {
            guard file == nil else { return }

            do {
                timestamp = nil
                file = try AVAudioFile(forWriting: url,
                                       settings: fileFormat.settings)

            } catch let error as NSError {
                Log(error)
            }
        }

        /// Should be set the amount of latency samples in the input device
        public private(set) var ioLatency: AVAudioFrameCount = 0

        /// The total samples read from the input stream
        public private(set) var totalFramesRead: AVAudioFrameCount = 0

        /// The actual amount of samples written to file. In the case of using
        /// calculated hardware latency, this would be less than the samples read
        /// from the tap
        public private(set) var totalFramesWritten: AVAudioFramePosition = 0 {
            didSet {
                duration = Double(totalFramesWritten) / fileFormat.sampleRate
            }
        }

        private var ioLatencyHandled: Bool = false

        /// Handle incoming data from the tap
        public func process(buffer: AVAudioPCMBuffer, time: AVAudioTime, write: Bool) throws {
            if write {
                try writeFile(buffer: buffer, time: time)
            }
            amplitude = buffer.rms
        }

        // The actual buffer length is unpredictable if using a Tap. This isn't ideal.
        // The system will change the buffer size to whatever it wants to, which seems
        // strange that they let you set a buffer size in the first place. macOS is setting to
        // 4800 when at 48k, or sampleRate / 10. That's a big buffer.
        private func writeFile(buffer: AVAudioPCMBuffer, time: AVAudioTime) throws {
            guard let file = file else { return }

            var buffer = buffer
            totalFramesRead += buffer.frameLength

            if timestamp == nil {
                timestamp = time
            }

            if !ioLatencyHandled, ioLatency > 0 {
                Log("Actual buffer size is", buffer.frameLength,
                    "totalFramesRead", totalFramesRead,
                    "Attempting to skip", ioLatency, "frames for latency compensation")

                if totalFramesRead > ioLatency {
                    let latencyOffset: AVAudioFrameCount = totalFramesRead - ioLatency
                    let startSample = buffer.frameLength - latencyOffset

                    // edit the first buffer to remove io latency samples length
                    if buffer.frameLength > latencyOffset,
                       let offsetBuffer = buffer.copyFrom(startSample: startSample)
                    {
                        buffer = offsetBuffer

                        Log("Writing partial buffer", offsetBuffer.frameLength, "frames, ioLatency is", ioLatency, "latencyOffset", latencyOffset)
                    } else {
                        Log("Unexpected buffer size of", buffer.frameLength)
                    }
                    ioLatencyHandled = true

                } else {
                    // Latency is longer than bufferSize so wait till next iterations
                    return
                }
            }

            try file.write(from: buffer)
            amplitudeArray.append(amplitude)
            totalFramesWritten = file.length
        }

        /// Release the file
        public func close() {
            Log("recorded duration is", duration,
                "initial timestamp is", timestamp,
                "totalFramesRead", totalFramesRead,
                "file.length", file?.length)

            file = nil
            amplitudeArray.removeAll()
        }
    }
}
