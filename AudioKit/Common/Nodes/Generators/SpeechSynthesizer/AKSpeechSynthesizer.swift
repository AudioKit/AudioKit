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

        // Adjust the speech rate/pitch or other property by set property to SpeechChannel
        // https://github.com/apple/swift-3-api-guidelines-review/blob/64e3132a6a383b4a4603605180ded31efd37dcdc/Platforms/OSX/ApplicationServices/SpeechSynthesis.swift#L311
        // and various examples from Apple in
        // https://github.com/ooper-shlab/CocoaSpeechSynthesisExample-Swift/blob/master/SpeakingTextWindow.swift#L910
        let randomSpeechRate: Int32 = Int32(arc4random_uniform(100) + 120)
        SetSpeechRate(speechChannel, randomSpeechRate)

        // change voices randomly
        var numOfVoices: Int16 = 0
        CountVoices(&numOfVoices)
        var theVoiceSpec = VoiceSpec()
        let randomVoiceIndex: Int16 = Int16(arc4random_uniform(UInt32(numOfVoices - 1)) + 1)
        GetIndVoice(randomVoiceIndex, &theVoiceSpec)
        let voiceDict: NSDictionary = [kSpeechVoiceID: theVoiceSpec.id,
        kSpeechVoiceCreator: theVoiceSpec.creator]

        SetSpeechProperty(speechChannel, kSpeechCurrentVoiceProperty, voiceDict)



        SpeakCFString(speechChannel, "Hello World. AK Speech Synthesizer works!" as CFString, nil)
    }

    @objc public override init() {
        super.init(avAudioNode: speechAU, attach: true)
    }
}
