//
//  AKSpeechSynthesizer.swift
//  AudioKit
//
//  Created by Wangchou Lu on H30/04/06.
//  Copyright © 平成30年 AudioKit. All rights reserved.
//

/// AudioKit version of Apple's SpeechSynthesis Audio Unit
///

open class AKSpeechSynthesizer: AKNode {

    public static let ComponentDescription = AudioComponentDescription(
        componentType: kAudioUnitType_Generator,
        componentSubType: kAudioUnitSubType_SpeechSynthesis,
        componentManufacturer: kAudioUnitManufacturer_Apple,
        componentFlags: 0,
        componentFlagsMask: 0 
    )
    fileprivate let speechAU = AVAudioUnitGenerator(audioComponentDescription: ComponentDescription)

    // Generic value for C-style getting of parameters
    fileprivate var valueAsNSNumber: CFTypeRef? = nil
    // Speech channel
    fileprivate var channel: SpeechChannel? = nil
    fileprivate var propsize: UInt32 = UInt32(MemoryLayout<SpeechChannel>.size)

    var theVoiceSpec = VoiceSpec()

    /// Rate in words per minute
    public var rate: Double {
        get {
            guard let speechChannel = channel else {
                AKLog("Cannot get Speech Channel")
                return 0.0
            }
            if CopySpeechProperty(speechChannel, kSpeechRateProperty, &valueAsNSNumber) == OSErr(noErr) {
                return valueAsNSNumber!.doubleValue!
            } else {
                return 0.0
            }
        }
        set (newRate) {
            guard let speechChannel = channel else {
                AKLog("Cannot get Speech Channel")
                return
            }
            AKLog("Trying to set new rate")
            let _ = SetSpeechProperty(speechChannel, kSpeechRateProperty, newRate as NSNumber?)
        }
    }

    /// Base Frequency in Hz
    public var frequency: Double {
        get {
            guard let speechChannel = channel else {
                AKLog("Cannot get Speech Channel")
                return 0.0
            }
            if CopySpeechProperty(speechChannel, kSpeechPitchBaseProperty, &valueAsNSNumber) == OSErr(noErr) {
                return valueAsNSNumber!.doubleValue!
            } else {
                return 0.0
            }
        }
        set (newFrequency) {
            guard let speechChannel = channel else {
                AKLog("Cannot get Speech Channel")
                return
            }
            AKLog("Trying to set new freq")
            let _ = SetSpeechProperty(speechChannel, kSpeechPitchBaseProperty, newFrequency as NSNumber?)
        }
    }

    /// Modulation Width in Hz
    public var modulation: Double {
        get {
            guard let speechChannel = channel else {
                AKLog("Cannot get Speech Channel")
                return 0.0
            }
            if CopySpeechProperty(speechChannel, kSpeechPitchModProperty, &valueAsNSNumber) == OSErr(noErr) {
                return valueAsNSNumber!.doubleValue!
            } else {
                return 0.0
            }
        }
        set (newModulation) {
            guard let speechChannel = channel else {
                AKLog("Cannot get Speech Channel")
                return
            }
            AKLog("Trying to set new modulation")
            let _ = SetSpeechProperty(speechChannel, kSpeechPitchModProperty, newModulation as NSNumber?)
        }
    }

    public func stop() {

        guard let speechChannel = channel else {
            AKLog("Cannot get Speech Channel")
            return
        }
        AKLog("Stopping")
        StopSpeech(speechChannel)
    }
    
    public func say(text: String,
                    rate: Double = 100,
                    frequency: Double = 100,
                    modulation: Double = 0) {

        self.rate = rate
        self.frequency = frequency
        self.modulation = modulation

        guard let speechChannel = channel else {
            AKLog("Cannot get Speech Channel")
            return
        }
        SpeakCFString(speechChannel, text as CFString, nil)
    }

    @objc public override init() {
        super.init(avAudioNode: speechAU, attach: true)

        // Grab the speech channel
        CheckError(AudioUnitGetProperty(speechAU.audioUnit,
                                        kAudioUnitProperty_SpeechChannel,
                                        kAudioUnitScope_Global,
                                        0,
                                        &channel,
                                        &propsize))


    }
}
