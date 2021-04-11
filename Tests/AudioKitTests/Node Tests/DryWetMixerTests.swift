// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest

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
        let input1Mixer = Mixer()
        input1Mixer.addInput(input1)
        
        let effect = Reverb(input1Mixer)
        let dryWet = DryWetMixer(dry: input1Mixer, wet: effect)
        
        let outputMixer = Mixer()
        outputMixer.addInput(dryWet)
        
        let someOtherMixer = Mixer()
        outputMixer.addInput(someOtherMixer)
        
        engine.output = outputMixer
        
        input1.start()
        
        
        let audio = engine.startTest(totalDuration: 1.0)
        someOtherMixer.addInput(input1Mixer)
        
        audio.append(engine.render(duration: 1.0))
        testMD5(audio)
    }
    */
}
