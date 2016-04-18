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
    public static var turnOnAKNotifications: Bool = false
}
