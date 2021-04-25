// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit
import Foundation

/// Global settings for AudioKit
public class Settings: NSObject {
    /// Enum of available buffer lengths
    /// from Shortest: 2 power 5 samples (32 samples = 0.7 ms @ 44100 kz)
    /// to Longest: 2 power 12 samples (4096 samples = 92.9 ms @ 44100 Hz)
    public enum BufferLength: Int, CaseIterable {
        /// Shortest: 32 samples = 0.7 ms @ 44100 kz
        case shortest = 5

        /// Very Short: 64 samples
        case veryShort = 6

        /// Short: 128 samples
        case short = 7

        /// Medium: 256 samples
        case medium = 8

        /// Long: 512 samples
        case long = 9

        /// Very Long: 1024 samples
        case veryLong = 10

        /// Huge: 2048 samples
        case huge = 11

        /// Longest: 4096 samples = 92.9 ms @ 44100 Hz
        case longest = 12
        
        /// Initialize the buffer length with a specific size in samples
        public init?(bufferSizeInSamples: UInt) {
            guard let size = BufferLength.allCases.first(where: { $0.samplesCount == bufferSizeInSamples })
            else { return nil }
            self = size
        }

        /// The buffer Length expressed as number of samples
        public var samplesCount: AVAudioFrameCount {
            return AVAudioFrameCount(pow(2.0, Double(rawValue)))
        }

        /// The buffer Length expressed as a duration in seconds
        public var duration: Double {
            return Double(samplesCount) / Settings.sampleRate
        }
    }

    /// Defaul t audio format
    public static let defaultAudioFormat = AVAudioFormat(standardFormatWithSampleRate: 44_100,
                                                         channels: 2) ?? AVAudioFormat()

    /// The sample rate in Hertz, default is 44100 kHz. Set a new audioFormat if you want to change this value.
    /// See audioFormat. This is the format that is used for node connections.
    public static var sampleRate: Double {
        get {
            return audioFormat.sampleRate
        }
        set {
            audioFormat = AVAudioFormat(standardFormatWithSampleRate: newValue,
                                        channels: audioFormat.channelCount) ?? AVAudioFormat()
        }
    }

    /// Number of audio channels: 2 for stereo, 1 for mono
    public static var channelCount: UInt32 {
        get {
            return audioFormat.channelCount
        }
        set {
            audioFormat = AVAudioFormat(standardFormatWithSampleRate: audioFormat.sampleRate,
                                        channels: newValue) ?? AVAudioFormat()
        }
    }

    /// AudioKit buffer length is set using Settings.bufferLength
    /// default is .VeryLong for a buffer set to 2 power 10 = 1024 samples (232 ms)
    public static var bufferLength: BufferLength = .veryLong

    /// AudioKit recording buffer length is set using Settings.BufferLength
    /// default is .VeryLong for a buffer set to 2 power 10 = 1024 samples (232 ms)
    /// in Apple's doc : "The requested size of the incoming buffers. The implementation may choose another size."
    /// So setting this value may have no effect (depending on the hardware device ?)
    public static var recordingBufferLength: BufferLength = .veryLong

    /// If set to true, Recording will stop after some delay to compensate
    /// latency between time recording is stopped and time it is written to file
    /// If set to false (the default value) , stopping record will be immediate,
    /// even if the last audio frames haven't been recorded to file yet.
    public static var fixTruncatedRecordings = false

    /// Turn on or off AudioKit logging
    public static var enableLogging: Bool = true
}
