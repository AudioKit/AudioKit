// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

extension MultiChannelInputNodeTap {
    public class WriteableFile: CustomStringConvertible {
        public var description: String {
            "url: \(url.path), channel: \(channel), file is open: \(file != nil)"
        }

        /// the url being written to, persists after close
        public private(set) var url: URL

        public private(set) var fileFormat: AVAudioFormat

        /// the channel of the audio device this is reading from
        public private(set) var channel: Int32

        /// only valid when open for writing, then nil
        public private(set) var file: AVAudioFile?

        /// current amplitude being written represented as RMS
        public private(set) var amplitude: Float = 0

        /// total duration of the file, will be updated during writing
        public private(set) var duration: TimeInterval = 0

        /// array of amplitude values used to create temporary waveform
        public private(set) var amplitudeArray = [Float]()

        /// timestamp when the first samples appear in the process block during writing
        public private(set) var timestamp: AVAudioTime?

        public init(url: URL,
                    fileFormat: AVAudioFormat,
                    channel: Int32,
                    ioLatency: AVAudioFrameCount = 0) {
            self.fileFormat = fileFormat
            self.channel = channel
            self.url = url
            self.ioLatency = ioLatency
        }

        public func createFile() {
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

        public private(set) var totalFramesRead: AVAudioFrameCount = 0
        public private(set) var totalFramesWritten: AVAudioFramePosition = 0 {
            didSet {
                duration = Double(totalFramesWritten) / fileFormat.sampleRate
            }
        }

        private var ioLatencyHandled: Bool = false

        public func process(buffer: AVAudioPCMBuffer, time: AVAudioTime, write: Bool) throws {
            if write {
                try writeFile(buffer: buffer, time: time)
            }
            amplitude = buffer.rms
        }

        // The actual buffer length is unpredicatable if using a Tap. This isn't ideal.
        // The system will change the buffer size to whatever it wants to, which seems
        // strange that they let you set a buffer size in the first place. macOS is setting to
        // 4800
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
                       let offsetBuffer = buffer.copyFrom(startSample: startSample) {
                        buffer = offsetBuffer

                        Log("Writing partial buffer", offsetBuffer.frameLength, "frames, ioLatency is", ioLatency, "latencyOffset", latencyOffset)
                    } else {
                        Log("Unexpected buffer size of", buffer.frameLength)
                    }
                    ioLatencyHandled = true

                } else {
                    // Latency is longer than bufferSize so wait till next iterations
//                    Log("Actual buffer size is", buffer.frameLength,
//                              "waiting for", ioLatency, "samples...")
                    return
                }
            }

            try file.write(from: buffer)
            amplitudeArray.append(amplitude)
            totalFramesWritten = file.length
        }

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
