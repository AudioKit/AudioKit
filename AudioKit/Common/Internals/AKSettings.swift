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

    /// Enum of available AVAudioSession Categories
    public enum SessionCategory: String {
        // Audio silenced by silent switch and screen lock - audio is mixable
        case Ambient = "AVAudioSessionCategoryAmbient"
        // Audio is silenced by silent switch and screen lock - audio is non mixable
        case SoloAmbient = "AVAudioSessionCategorySoloAmbient"
        // Audio is not silenced by silent switch and screen lock - audio is non mixable
        case Playback = "AVAudioSessionCategoryPlayback"
        // Silences playback audio
        case Record = "AVAudioSessionCategoryRecord"
        // Audio is not silenced by silent switch and screen lock - audio is non mixable. To allow mixing see AVAudioSessionCategoryOptionMixWithOthers.
        case PlayAndRecord = "AVAudioSessionCategoryPlayAndRecord"
        // Disables playback and recording
        case AudioProcessing = "AVAudioSessionCategoryAudioProcessing"
        // Use to multi-route audio. May be used on input, output, or both.
        case MultiRoute = "AVAudioSessionCategoryMultiRoute"
    }

    /// Enum of available buffer lengths
    /// from Shortest: 2 power 5 samples (32 samples = 0.7 ms @ 44100 kz)
    /// to Longest: 2 power 12 samples (4096 samples = 92.9 ms @ 44100 Hz)
    public enum BufferLength: Int {
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
            return AVAudioFrameCount(pow(2.0, Double(self.rawValue)))
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

    #if !os(OSX)

    /// Shortcut for AVAudioSession.sharedInstance()
    open static let session = AVAudioSession.sharedInstance()

    open static func setSessionCategory(
        _ category: SessionCategory,
        withOptions options: AVAudioSessionCategoryOptions? = nil ) throws {

        if AKSettings.disableAVAudioSessionCategoryManagement == false {

            // print( "ask for category: \(category.rawValue)")
            // Category
            if options != nil {
                do {
                    try session.setCategory(category.rawValue, with: options!)
                } catch let error as NSError {
                    print("AKAsettings Error: Cannot set AVAudioSession Category to \(String(describing: category)) with options: \(String(describing: options!))")
                    print("AKAsettings Error: \(error))")
                    throw error
                }
            }
        } else {

            do {
                try session.setCategory(category.rawValue)
            } catch let error as NSError {
                print("AKAsettings Error: Cannot set AVAudioSession Category to \(String(describing: category))")
                print("AKAsettings Error: \(error))")
                throw error
            }
        }

        // Preferred IO Buffer Duration

        do {
            try session.setPreferredIOBufferDuration(bufferLength.duration)
        } catch let error as NSError {
            print("AKAsettings Error: Cannot set Preferred IOBufferDuration to \(bufferLength.duration) ( = \(bufferLength.samplesCount) samples)")
            print("AKAsettings Error: \(error))")
            throw error
        }

        // Activate session
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("AKAsettings Error: Cannot set AVAudioSession.setActive to true")
            print("AKAsettings Error: \(error))")
            throw error
        }


        // FOR DEBUG !
        // (setting the AVAudioSession can be non effective under certain circonstances even if there's no error thrown.)
        // You may uncomment the next 'print' lines for debugging :
        // print("AKSettings: asked for: \(category.rawValue)")
        // print("AKSettings: Session.category is set to: \(session.category)")

        if options != nil {
            // print("AKSettings: asked for options: \(options!)")
            // print("AKSettings: Session.category is set to: \(session.categoryOptions)")
        }
    }

    /// Checks if headphones are plugged
    /// Returns true if headPhones are plugged, otherwise return false
    static open var headPhonesPlugged: Bool {
        let route = session.currentRoute
        var headPhonesFound = false
        if route.outputs.count > 0 {
            for description in route.outputs {
                if description.portType == AVAudioSessionPortHeadphones {
                    headPhonesFound = true
                    break
                }
            }
        }
        return headPhonesFound
    }
    
    #endif
    
    
    
}
