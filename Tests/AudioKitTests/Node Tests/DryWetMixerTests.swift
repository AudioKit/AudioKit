// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit
import XCTest
import AVFoundation

class DryWetMixerTests: XCTestCase {
    let input1 = Oscillator(waveform: Table(.triangle))
    let input2 = Oscillator(waveform: Table(.triangle), frequency: 1280)

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
    
    /* Test produces different results on local machine vs CI
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
 */
    
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
    
    class TestingAU: AUAudioUnit {
        private var inputBusArray: [AUAudioUnitBus] = []
        private var outputBusArray: [AUAudioUnitBus] = []
        private var internalBuffers: [AVAudioPCMBuffer] = []
        
        /// Allocate the render resources
        override public func allocateRenderResources() throws {
            try super.allocateRenderResources()

            let format = Settings.audioFormat

            try inputBusArray.forEach { if $0.format != format { try $0.setFormat(format) } }
            try outputBusArray.forEach { if $0.format != format { try $0.setFormat(format) } }

            // we don't need to allocate a buffer if we can process in place
            if !canProcessInPlace || inputBusArray.count > 1 {
                for i in inputBusArray.indices {
                    if let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: maximumFramesToRender) {
                        internalBuffers.append(buffer)
                    }
                }
            }
        }

        /// Delllocate Render Resources
        override public func deallocateRenderResources() {
            super.deallocateRenderResources()
            internalBuffers = []
        }
        
        private lazy var auInputBusArray: AUAudioUnitBusArray = {
            AUAudioUnitBusArray(audioUnit: self, busType: .input, busses: inputBusArray)
        }()

        /// Input busses
        override public var inputBusses: AUAudioUnitBusArray {
            return auInputBusArray
        }

        private lazy var auOutputBusArray: AUAudioUnitBusArray = {
            AUAudioUnitBusArray(audioUnit: self, busType: .output, busses: outputBusArray)
        }()

        /// Output bus array
        override public var outputBusses: AUAudioUnitBusArray {
            return auOutputBusArray
        }
        
        override var internalRenderBlock: AUInternalRenderBlock {
            return { ( _, _, _, _, _, _, _) in
                return noErr
            }
        }
        
        /// Initialize with component description and options
        /// - Parameters:
        ///   - componentDescription: Audio Component Description
        ///   - options: Audio Component Instantiation Options
        /// - Throws: error
        override public init(componentDescription: AudioComponentDescription,
                             options: AudioComponentInstantiationOptions = []) throws {
            try super.init(componentDescription: componentDescription, options: options)

            // create audio bus connection points
            let format = AVAudioFormat(standardFormatWithSampleRate: 44_100,
                                       channels: 2) ?? AVAudioFormat()
            for _ in 0..<2 {
                inputBusArray.append(try AUAudioUnitBus(format: format))
            }
            for _ in 0..<2 {
                outputBusArray.append(try AUAudioUnitBus(format: format))
            }
        }

    }
    
    func testReattachInputMixerAV() {
        
        let engine = AVAudioEngine()
        
        let player = AVAudioPlayerNode()
        engine.attach(player)
        
        AUAudioUnit.registerSubclass(TestingAU.self,
                                     as: AudioComponentDescription(mixer: "dwm2"),
                                     name: "Local DryWetMixer",
                                     version: .max)
        AVAudioUnit.instantiate(with: AudioComponentDescription(mixer: "dwm2")) { avAudioUnit, _ in
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
