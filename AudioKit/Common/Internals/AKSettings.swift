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
@objc public class AKSettings: NSObject {

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
        case Shortest = 5
        case VeryShort = 6
        case Short = 7
        case Medium = 8
        case Long = 9
        case VeryLong = 10
        case Huge = 11
        case Longest = 12

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
    public static var sampleRate: Double = 44100

    /// Number of audio channels: 2 for stereo, 1 for mono
    public static var numberOfChannels: UInt32 = 2

    /// Whether we should be listening to audio input (microphone)
    public static var audioInputEnabled: Bool = false

    /// Whether to allow audio playback to override the mute setting
    public static var playbackWhileMuted: Bool = false

    /// Global audio format AudioKit will default to
    public static var audioFormat: AVAudioFormat {
        return AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: numberOfChannels)
    }

    /// Whether to DefaultToSpeaker when audio input is enabled
    public static var defaultToSpeaker: Bool = false

    /// Global default rampTime value
    public static var rampTime: Double = 0.0002

    /// Allows AudioKit to send Notifications
    public static var notificationsEnabled: Bool = false

    /// AudioKit buffer length is set using AKSettings.BufferLength
    /// default is .VeryLong for a buffer set to 2 power 10 = 1024 samples (232 ms)
    public static var bufferLength: BufferLength = .VeryLong

    /// AudioKit recording buffer length is set using AKSettings.BufferLength
    /// default is .VeryLong for a buffer set to 2 power 10 = 1024 samples (232 ms)
    /// in Apple's doc : "The requested size of the incoming buffers. The implementation may choose another size."
    /// So setting this value may have no effect (depending on the hardware device ?)
    public static var recordingBufferLength: BufferLength = .VeryLong

    /// If set to true, Recording will stop after some delay to compensate
    /// latency between time recording is stopped and time it is written to file
    /// If set to false (the default value) , stopping record will be immediate,
    /// even if the last audio frames haven't been recorded to file yet.
    public static var fixTruncatedRecordings = false

    /// Enable AudioKit AVAudioSession Category Management
    public static var disableAVAudioSessionCategoryManagement: Bool = false

    #if !os(OSX)

    /// Shortcut for AVAudioSession.sharedInstance()
    public static let session = AVAudioSession.sharedInstance()

    public static func setSessionCategory(
        category: SessionCategory,
        withOptions options: AVAudioSessionCategoryOptions? = nil ) throws {

        if AKSettings.disableAVAudioSessionCategoryManagement == false {

            // print( "ask for category: \(category.rawValue)")
            // Category
            if options != nil {
                do {
                    try session.setCategory(category.rawValue, withOptions: options!)
                } catch let error as NSError {
                    print("AKAsettings Error: Cannot set AVAudioSession Category to \(String(category)) with options: \(String(options!))")
                    print("AKAsettings Error: \(error))")
                    throw error
                }
            }
        } else {

            do {
                try session.setCategory(category.rawValue)
            } catch let error as NSError {
                print("AKAsettings Error: Cannot set AVAudioSession Category to \(String(category))")
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
    static public var headPhonesPlugged: Bool {
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
