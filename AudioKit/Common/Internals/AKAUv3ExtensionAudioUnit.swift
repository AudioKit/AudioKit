//
//  AKAUv3ExtensionAudioUnit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka on 5/17/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

open class AKAUv3ExtensionAudioUnit: AUAudioUnit {
    // Parameter tree stuff (for automation + control)
    open var _parameterTree: AUParameterTree!
    override open var parameterTree: AUParameterTree {
        return self._parameterTree
    }

    // Internal Render block stuff
    open var _internalRenderBlock: AUInternalRenderBlock!
    override open var internalRenderBlock: AUInternalRenderBlock {
        return self._internalRenderBlock
    }

    // Default OutputBusArray stuff you will need
    open var _outputBusArray: AUAudioUnitBusArray!
    override open var outputBusses: AUAudioUnitBusArray {
        return self._outputBusArray
    }
    open func setOutputBusArrays() throws {
        let bus = try AUAudioUnitBus(format: AudioKit.format)
        self._outputBusArray = AUAudioUnitBusArray(audioUnit: self, busType: AUAudioUnitBusType.output, busses: [bus])
    }
}
