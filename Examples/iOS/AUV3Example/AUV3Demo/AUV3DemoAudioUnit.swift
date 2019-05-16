//
//  AUV3DemoAudioUnit.swift
//  AUV3Demo
//
//  Created by Jeff Cooper on 5/16/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation
import AudioKit

class AUV3DemoAudioUnit: AUAudioUnit {

    var engine = AVAudioEngine()    //each unit needs it's own avaudioEngine
    var conductor = Conductor()     //add Conductor.swift to auv3 target

    override init(componentDescription: AudioComponentDescription, options: AudioComponentInstantiationOptions = []) throws {
        AKLog("initing auv3 demo unit")
        AudioKit.engine = engine    // AudioKit.engine needs to be set early on

        conductor.setupRoute()

        do {
            try engine.enableManualRenderingMode(.realtime, format: AudioKit.format, maximumFrameCount: 4096)
            try super.init(componentDescription: componentDescription, options: options)
            try setOutputBusArrays()
        } catch {
            AKLog("Could not init audio unit")
            throw error
        }

        conductor.start()
        setInternalRenderingBlock()
        conductor.osc.playNote(noteNumber: 55)
    }

    private func setInternalRenderingBlock() {
        self._internalRenderBlock = { (actionFlags, timeStamp, frameCount, outputBusNumber, outputData, renderEvent, pullInputBlock) in
            _ = self.engine.manualRenderingBlock(frameCount, outputData, nil)
            return noErr
        }
    }

    private var _internalRenderBlock: AUInternalRenderBlock!
    override var internalRenderBlock: AUInternalRenderBlock {
        return self._internalRenderBlock
    }

    // Default OutputBusArray stuff you will need
    private var _outputBusArray: AUAudioUnitBusArray!

    override var outputBusses: AUAudioUnitBusArray {
        return self._outputBusArray
    }

    private func setOutputBusArrays() throws {
        let bus = try AUAudioUnitBus(format: AudioKit.format)
        self._outputBusArray = AUAudioUnitBusArray(audioUnit: self, busType: AUAudioUnitBusType.output, busses: [bus])
    }
}
