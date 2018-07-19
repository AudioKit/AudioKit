//
//  AKSpeechSynthesizer.swift
//  AudioKit
//
//  Created by Wangchou Lu, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
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
    fileprivate var valueAsNSNumber: CFTypeRef?
    // Speech channel
    fileprivate var channel: SpeechChannel?
    fileprivate var propsize: UInt32 = UInt32(MemoryLayout<SpeechChannel>.size)

    var theVoiceSpec = VoiceSpec()

    /// Rate in words per minute
    public var rate: Int {
        get {
            guard let speechChannel = channel else {
                AKLog("Cannot get Speech Channel")
                return 0
            }
            if CopySpeechProperty(speechChannel, kSpeechRateProperty, &valueAsNSNumber) == OSErr(noErr) {
                return Int(valueAsNSNumber!.doubleValue!.rounded())
            } else {
                return 0
            }
        }
        set (newRate) {
            guard let speechChannel = channel else {
                AKLog("Cannot get Speech Channel")
                return
            }
            _ = SetSpeechProperty(speechChannel, kSpeechRateProperty, newRate as NSNumber?)
        }
    }

    /// Base Frequency in Hz
    public var frequency: Int {
        get {
            guard let speechChannel = channel else {
                AKLog("Cannot get Speech Channel")
                return 0
            }
            if CopySpeechProperty(speechChannel, kSpeechPitchBaseProperty, &valueAsNSNumber) == OSErr(noErr) {
                return Int(valueAsNSNumber!.doubleValue!.rounded())
            } else {
                return 0
            }
        }
        set (newFrequency) {
            guard let speechChannel = channel else {
                AKLog("Cannot get Speech Channel")
                return
            }
            _ = SetSpeechProperty(speechChannel, kSpeechPitchBaseProperty, newFrequency as NSNumber?)
        }
    }

    /// Modulation Width in Hz
    public var modulation: Int {
        get {
            guard let speechChannel = channel else {
                AKLog("Cannot get Speech Channel")
                return 0
            }
            if CopySpeechProperty(speechChannel, kSpeechPitchModProperty, &valueAsNSNumber) == OSErr(noErr) {
                return Int(valueAsNSNumber!.doubleValue!.rounded())
            } else {
                return 0
            }
        }
        set (newModulation) {
            guard let speechChannel = channel else {
                AKLog("Cannot get Speech Channel")
                return
            }
            _ = SetSpeechProperty(speechChannel, kSpeechPitchModProperty, newModulation as NSNumber?)
        }
    }

    public func stop() {

        guard let speechChannel = channel else {
            AKLog("Cannot get Speech Channel")
            return
        }
        AKLog("Stopping should work, but its known to be nonfunctional.")
        AKLog("Instead, send the speech synthesizer through AKBooster and mute the output.")
        StopSpeech(speechChannel)
    }

    public func say(text: String,
                    rate: Int? = nil,
                    frequency: Int? = nil,
                    modulation: Int? = nil) {

        self.rate = rate ?? self.rate
        self.frequency = frequency ?? self.frequency
        self.modulation = modulation ?? self.modulation

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
