// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest
import AVFoundation

class DryWetMixerTests: XCTestCase {
    let input1 = Oscillator()
    let input2 = Oscillator(frequency: 1280)

    func testDefault() {
        let engine = AudioEngine()
        let mixer = DryWetMixer(dry: input1, wet: input2)
        engine.output = mixer

        input1.start()
        input2.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
    
    func testDuplicateInput() {
        let engine = AudioEngine()
        let mixer = DryWetMixer(dry: input1, wet: input1)
        engine.output = mixer

        input1.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testBalance0() {
        let engine = AudioEngine()
        let mixer = DryWetMixer(dry: input1, wet: input2, balance: 0)
        engine.output = mixer

        input1.start()
        input2.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }

    func testBalance1() {
        let engine = AudioEngine()
        let mixer = DryWetMixer(dry: input1, wet: input2, balance: 1)
        engine.output = mixer

        input1.start()
        input2.start()
        let audio = engine.startTest(totalDuration: 1.0)
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
    
    func testDetachWhileHavingAnInputMixer() {
        let engine = AudioEngine()
        let input1Mixer = Mixer()
        input1Mixer.addInput(input1)
        
        let effect = Reverb(input1Mixer)
        
        let dryWet = DryWetMixer(dry: input1Mixer, wet: effect)
        
        let outputMixer = Mixer()
        outputMixer.addInput(dryWet)
        
        engine.output = outputMixer
        
        input1.start()
        
        let audio = engine.startTest(totalDuration: 1.0)
        outputMixer.removeInput(dryWet)
        
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
     }
    
    /*
    func testReattachInputMixer() {
        let engine = AudioEngine()
        let dryWet = DryWetMixer(dry: input1, wet: input1)
        
        let outputMixer = Mixer()
        outputMixer.addInput(dryWet)
        
        let someOtherMixer = Mixer()
        outputMixer.addInput(someOtherMixer)
        
        engine.output = outputMixer
        
        input1.start()
        
        let audio = engine.startTest(totalDuration: 1.0)
        someOtherMixer.addInput(input1)
        
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
    */
    
    /*
    var dryWet: AVAudioUnit!
    
    func testReattachInputMixerAV() {
        
        let engine = AVAudioEngine()
        
        let player = AVAudioPlayerNode()
        engine.attach(player)
        
        AUAudioUnit.registerSubclass(DryWetMixer.InternalAU.self,
                                     as: DryWetMixer.ComponentDescription,
                                     name: "Local DryWetMixer",
                                     version: .max)
        AVAudioUnit.instantiate(with: DryWetMixer.ComponentDescription) { avAudioUnit, _ in
            guard let au = avAudioUnit else {
                fatalError("Unable to instantiate AVAudioUnit")
            }
            self.dryWet = au
            print("instantiated")
        }
        
        engine.attach(dryWet)
        
        let outputMixer = AVAudioMixerNode()
        engine.attach(outputMixer)
        engine.connect(dryWet, to: outputMixer, format: nil)
        
        let someOtherMixer = AVAudioMixerNode()
        engine.attach(someOtherMixer)
        engine.connect(someOtherMixer, to: outputMixer, format: nil)
        
        engine.connect(outputMixer, to: engine.mainMixerNode, format: nil)
        
        try! engine.start()
        engine.connect(player, to: [.init(node: dryWet, bus: 0), .init(node: dryWet, bus: 1), .init(node: someOtherMixer, bus: someOtherMixer.nextAvailableInputBus)], fromBus: 0, format: nil)
        
        sleep(2)
        
        engine.stop()
        
    }
    */
}
