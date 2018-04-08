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

    public func say(text: String,
                    wordsPerMinute: Double = 100,
                    frequency: Double = 100,
                    modulation: Double = 0) {
        var channel: SpeechChannel?
        var propsize: UInt32 = UInt32(MemoryLayout<SpeechChannel>.size)

        CheckError(AudioUnitGetProperty(speechAU.audioUnit,
                                        kAudioUnitProperty_SpeechChannel,
                                        kAudioUnitScope_Global,
                                        0,
                                        &channel,
                                        &propsize))

        guard let speechChannel = channel else {
            AKLog("Cannot get Speech Channel")
            return
        }

        let _ = SetSpeechProperty(speechChannel, kSpeechRateProperty, wordsPerMinute as NSNumber)
        let _ = SetSpeechProperty(speechChannel, kSpeechPitchBaseProperty, frequency as NSNumber)
        let _ = SetSpeechProperty(speechChannel, kSpeechPitchModProperty, modulation as NSNumber)

            
        // change voices randomly
//        var numOfVoices: Int16 = 0
//        CountVoices(&numOfVoices)
//        var theVoiceSpec = VoiceSpec()
//        let randomVoiceIndex: Int16 = Int16(arc4random_uniform(UInt32(numOfVoices - 1)) + 1)
//        GetIndVoice(randomVoiceIndex, &theVoiceSpec)
//        let voiceDict: NSDictionary = [kSpeechVoiceID: theVoiceSpec.id, kSpeechVoiceCreator: theVoiceSpec.creator]
//
//        SetSpeechProperty(speechChannel, kSpeechCurrentVoiceProperty, voiceDict)



        SpeakCFString(speechChannel, text as CFString, nil)
    }

    @objc public override init() {
        super.init(avAudioNode: speechAU, attach: true)
    }
}
