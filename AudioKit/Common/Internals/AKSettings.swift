//
//  AKSettings.swift
//  AudioKit
//
//  Created by Stéphane Peter, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Global settings for AudioKit
@objc open class AKSettings: NSObject {

    /// Enum of available buffer lengths
    /// from Shortest: 2 power 5 samples (32 samples = 0.7 ms @ 44100 kz)
    /// to Longest: 2 power 12 samples (4096 samples = 92.9 ms @ 44100 Hz)
    @objc public enum BufferLength: Int {

        /// Shortest
        case shortest = 5

        /// Very Short
        case veryShort = 6

        /// Short
        case short = 7

        /// Medium
        case medium = 8

        /// Long
        case long = 9

        /// Very Long
        case veryLong = 10

        /// Huge
        case huge = 11

        /// Longest
        case longest = 12

        /// The buffer Length expressed as number of samples
        var samplesCount: AVAudioFrameCount {
            return AVAudioFrameCount(pow(2.0, Double(rawValue)))
        }

        /// The buffer Length expressed as a duration in seconds
        var duration: Double {
            return Double(samplesCount) / AKSettings.sampleRate
        }
    }

    /// The sample rate in Hertz
    open static var sampleRate: Double = 44_100

    /// Number of audio channels: 2 for stereo, 1 for mono
    open static var numberOfChannels: UInt32 = 2

    /// Whether we should be listening to audio input (microphone)
    open static var audioInputEnabled: Bool = false

    /// Whether to allow audio playback to override the mute setting
    open static var playbackWhileMuted: Bool = false

    /// Global audio format AudioKit will default to
    open static var audioFormat: AVAudioFormat {
        return AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: numberOfChannels)
    }

    /// Whether to DefaultToSpeaker when audio input is enabled
    open static var defaultToSpeaker: Bool = false

    /// Whether to use bluetooth when audio input is enabled
    open static var useBluetooth: Bool = false

#if !os(macOS)
    /// Additional control over the options to use for bluetooth
    open static var bluetoothOptions: AVAudioSessionCategoryOptions = []
#endif

    /// Whether AirPlay is enabled when audio input is enabled
    open static var allowAirPlay: Bool = false

    /// Global default rampTime value
    open static var rampTime: Double = 0.000_2

    /// Allows AudioKit to send Notifications
    open static var notificationsEnabled: Bool = false

    /// AudioKit buffer length is set using AKSettings.BufferLength
    /// default is .VeryLong for a buffer set to 2 power 10 = 1024 samples (232 ms)
    open static var bufferLength: BufferLength = .veryLong

    /// AudioKit recording buffer length is set using AKSettings.BufferLength
    /// default is .VeryLong for a buffer set to 2 power 10 = 1024 samples (232 ms)
    /// in Apple's doc : "The requested size of the incoming buffers. The implementation may choose another size."
    /// So setting this value may have no effect (depending on the hardware device ?)
    open static var recordingBufferLength: BufferLength = .veryLong

    /// If set to true, Recording will stop after some delay to compensate
    /// latency between time recording is stopped and time it is written to file
    /// If set to false (the default value) , stopping record will be immediate,
    /// even if the last audio frames haven't been recorded to file yet.
    open static var fixTruncatedRecordings = false

    /// Enable AudioKit AVAudioSession Category Management
    open static var disableAVAudioSessionCategoryManagement: Bool = false

    /// If set to false, AudioKit will not handle the AVAudioSession route change
    /// notification (AVAudioSessionRouteChange) and will not restart the AVAudioEngine
    /// instance when such notifications are posted. The developer can instead subscribe
    /// to these notifications and restart AudioKit after rebuiling their audio chain.
    open static var enableRouteChangeHandling: Bool = true

    /// If set to false, AudioKit will not handle the AVAudioSession category change
    /// notification (AVAudioEngineConfigurationChange) and will not restart the AVAudioEngine
    /// instance when such notifications are posted. The developer can instead subscribe
    /// to these notifications and restart AudioKit after rebuiling their audio chain.
    open static var enableCategoryChangeHandling: Bool = true

    /// Turn off AudioKit logging
    open static var enableLogging: Bool = true
}

#if !os(macOS)
extension AKSettings {

  /// Shortcut for AVAudioSession.sharedInstance()
    open static let session = AVAudioSession.sharedInstance()

    /// Convenience method accessible from Objective-C
    @objc open static func setSession(category: SessionCategory, options: UInt) throws {
        try setSession(category: category, with: AVAudioSessionCategoryOptions(rawValue: options))
    }

    /// Set the audio session type
    open static func setSession(category: SessionCategory,
                                with options: AVAudioSessionCategoryOptions = [.mixWithOthers]) throws {

        if ❗️AKSettings.disableAVAudioSessionCategoryManagement {
            do {
                try session.setCategory("\(category)", with: options)
            } catch let error as NSError {
                AKLog("Error: \(error) Cannot set AVAudioSession Category to \(category) with options: \(options)")
                    throw error
            }
        }

        // Preferred IO Buffer Duration

        do {
            try session.setPreferredIOBufferDuration(bufferLength.duration)
        } catch let error as NSError {
            AKLog("AKSettings Error: Cannot set Preferred IOBufferDuration to " +
                "\(bufferLength.duration) ( = \(bufferLength.samplesCount) samples)")
            AKLog("AKSettings Error: \(error))")
            throw error
        }

        // Activate session
        do {
            try session.setActive(true)
        } catch let error as NSError {
            AKLog("AKSettings Error: Cannot set AVAudioSession.setActive to true")
            AKLog("AKSettings Error: \(error))")
            throw error
        }
    }

    /// Checks if headphones are plugged
    /// Returns true if headPhones are plugged, otherwise return false
    static open var headPhonesPlugged: Bool {
        return session.currentRoute.outputs.contains {
            $0.portType == AVAudioSessionPortHeadphones
        }
    }

    /// Enum of available AVAudioSession Categories
    @objc public enum SessionCategory: Int, CustomStringConvertible {
        /// Audio silenced by silent switch and screen lock - audio is mixable
        case ambient
        /// Audio is silenced by silent switch and screen lock - audio is non mixable
        case soloAmbient
        /// Audio is not silenced by silent switch and screen lock - audio is non mixable
        case playback
        /// Silences playback audio
        case record
        /// Audio is not silenced by silent switch and screen lock - audio is non mixable. 
        /// To allow mixing see AVAudioSessionCategoryOptionMixWithOthers.
        case playAndRecord
        #if !os(tvOS)
        /// Disables playback and recording
        case audioProcessing
        #endif
        /// Use to multi-route audio. May be used on input, output, or both.
        case multiRoute

        public var description: String {

            if self == .ambient {
                return AVAudioSessionCategoryAmbient
            } else if self == .soloAmbient {
                return AVAudioSessionCategorySoloAmbient
            } else if self == .playback {
                return AVAudioSessionCategoryPlayback
            } else if self == .record {
                return AVAudioSessionCategoryRecord
            } else if self == .playAndRecord {
                return AVAudioSessionCategoryPlayAndRecord
            } else if self == .multiRoute {
                return AVAudioSessionCategoryMultiRoute
            }

            fatalError("unrecognized AVAudioSessionCategory \(self)")

      }
  }
}
#endif
