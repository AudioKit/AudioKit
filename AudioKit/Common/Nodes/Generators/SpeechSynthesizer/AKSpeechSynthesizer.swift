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

    public func sayHello() {
        var channel: SpeechChannel?
        var propsize: UInt32 = UInt32(MemoryLayout<SpeechChannel>.size)

        CheckError(AudioUnitGetProperty(speechAU.audioUnit,
                                        kAudioUnitProperty_SpeechChannel,
                                        kAudioUnitScope_Global,
                                        0,
                                        &channel,
                                        &propsize))

        guard let speechChannel = channel else {
            debugPrint("Cannot get Speech Channel")
            exit(1)
        }

        SpeakCFString(speechChannel, "Hello World. AK Speech Synthesizer works!" as CFString, nil)
    }

    @objc public override init() {
        super.init(avAudioNode: speechAU, attach: true)
    }
}
