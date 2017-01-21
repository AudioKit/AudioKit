//
//  AKSettings.swift
//  AudioKit
//
//  Created by Stéphane Peter, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Global settings for AudioKit
@objc open class AKSettings: NSObject {

    /// Enum of available buffer lengths
    /// from Shortest: 2 power 5 samples (32 samples = 0.7 ms @ 44100 kz)
    /// to Longest: 2 power 12 samples (4096 samples = 92.9 ms @ 44100 Hz)
    @objc public enum BufferLength: Int {
        case shortest = 5
        case veryShort = 6
        case short = 7
        case medium = 8
        case long = 9
        case veryLong = 10
        case huge = 11
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
    open static var sampleRate: Double = 44100

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

    /// Global default rampTime value
    open static var rampTime: Double = 0.0002

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
                                with options: AVAudioSessionCategoryOptions? = nil) throws {
        
        if !AKSettings.disableAVAudioSessionCategoryManagement {
            do {
                try session.setCategory("\(category)", with: options!)
            } catch let error as NSError {
                AKLog("Error: \(error) Cannot set AVAudioSession Category to \(category)" + (options.map { " with options:\($0)" } ?? ""))
                throw error
            }
        }

        // Preferred IO Buffer Duration

        do {
            try session.setPreferredIOBufferDuration(bufferLength.duration)
        } catch let error as NSError {
            AKLog("AKSettings Error: Cannot set Preferred IOBufferDuration to \(bufferLength.duration) ( = \(bufferLength.samplesCount) samples)")
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


        // FOR DEBUG !
        // (setting the AVAudioSession can be non effective under certain circonstances even if there's no error thrown.)
        // You may uncomment the next 'print' lines for debugging :
        // AKLog("AKSettings: asked for: \(category.rawValue)")
        // AKLog("AKSettings: Session.category is set to: \(session.category)")

        if options != nil {
            // AKLog("AKSettings: asked for options: \(options!)")
            // AKLog("AKSettings: Session.category is set to: \(session.categoryOptions)")
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
        /// Audio is not silenced by silent switch and screen lock - audio is non mixable. To allow mixing see AVAudioSessionCategoryOptionMixWithOthers.
        case playAndRecord
        /// Disables playback and recording
        #if !os(tvOS)
        case audioProcessing
        #endif
        /// Use to multi-route audio. May be used on input, output, or both.
        case multiRoute

        public var description: String {

            if self == .ambient { return AVAudioSessionCategoryAmbient }
            else if self == .soloAmbient { return AVAudioSessionCategorySoloAmbient }
            else if self == .playback { return AVAudioSessionCategoryPlayback }
            else if self == .record { return AVAudioSessionCategoryPlayback }
            else if self == .playAndRecord { return AVAudioSessionCategoryPlayback }
            else if self == .multiRoute { return AVAudioSessionCategoryMultiRoute }
            #if !os(tvOS)
            if self == .audioProcessing { return AVAudioSessionCategoryPlayback }
            #endif

            fatalError("unrecognized AVAudioSessionCategory \(self)")

      }
  }
}
#endif

