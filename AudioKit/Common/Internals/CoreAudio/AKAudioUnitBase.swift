//
//  AKAudioUnit.swift
//  AudioKit
//
//  Created by James Ordner, revision history on GitHub.
//  Copyright © 2020 AudioKit. All rights reserved.
//

import AudioToolbox

open class AKAudioUnitBase: AUAudioUnit {

    public private(set) var dsp: AKDSPRef?

    public private(set) var isStarted: Bool = true

    private var inputBus: AUAudioUnitBus
    private var inputBuffer: AVAudioPCMBuffer?

    private var outputBus: AUAudioUnitBus
    private var outputBuffer: AVAudioPCMBuffer?

    lazy private var inputBusArray: AUAudioUnitBusArray = {
        AUAudioUnitBusArray(audioUnit: self, busType: .input, busses: [inputBus])
    }()

    lazy private var outputBusArray: AUAudioUnitBusArray = {
        AUAudioUnitBusArray(audioUnit: self, busType: .output, busses: [outputBus])
    }()

    /// Paramater ramp duration (seconds)
    public var rampDuration: Double = AKSettings.rampDuration {
        didSet {
            setRampDurationDSP(dsp, Float(rampDuration))
        }
    }

    /// This should be overridden. All the base class does is make sure that the pointer to the
    /// DSP is invalid.
    public func createDSP() -> AKDSPRef? {
        return nil
    }

    public override var internalRenderBlock: AUInternalRenderBlock {
        internalRenderBlockDSP(dsp)
    }

    public override func allocateRenderResources() throws {
        try super.allocateRenderResources()
        let format = AKSettings.audioFormat
        if inputBus.format != format { try inputBus.setFormat(format) }
        if outputBus.format != format { try outputBus.setFormat(format) }
        inputBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: maximumFramesToRender)
        outputBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: maximumFramesToRender)
        allocateRenderResourcesDSP(dsp, format, inputBuffer, outputBuffer)
    }

    public override func deallocateRenderResources() {
        super.deallocateRenderResources()
        deallocateRenderResourcesDSP(dsp)
        inputBuffer = nil
        outputBuffer = nil
    }

    public override func reset() {
        resetDSP(dsp)
    }

    public override var inputBusses: AUAudioUnitBusArray {
        return inputBusArray
    }

    public override var outputBusses: AUAudioUnitBusArray {
        return outputBusArray
    }

    public override var parameterTree: AUParameterTree? {
        didSet {
            parameterTree?.implementorValueObserver = { [unowned self] parameter, value in
                setParameterDSP(self.dsp, parameter.address, value)
            }

            parameterTree?.implementorValueProvider = { [unowned self] parameter in
                return getParameterDSP(self.dsp, parameter.address)
            }

            parameterTree?.implementorStringFromValueCallback = { parameter, value in
                if let value = value {
                    return String(format: "%.f", value)
                } else {
                    return "Invalid"
                }
            }
        }
    }

    public override var canProcessInPlace: Bool {
        return canProcessInPlaceDSP(dsp)
    }

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        inputBus = try AUAudioUnitBus(format: AKSettings.audioFormat)
        outputBus = try AUAudioUnitBus(format: AKSettings.audioFormat)

        try super.init(componentDescription: componentDescription, options: options)

        // Create pointer to the underlying C++ DSP code
        dsp = createDSP()
        if dsp == nil { throw AKError.InvalidDSPObject }

        setRampDurationDSP(dsp, Float(rampDuration))
    }

    deinit {
        deleteDSP(dsp)
    }

    public func start() {
        isStarted = true
        startDSP(dsp)
    }

    public func stop() {
        isStarted = false
        stopDSP(dsp)
    }

    public func trigger() {
        triggerDSP(dsp)
    }

    public func triggerFrequency(_ frequency: Float, amplitude: Float) {
        triggerFrequencyDSP(dsp, frequency, amplitude)
    }

    public func setWavetable(_ wavetable: [Float], index: Int = 0) {
        setWavetableDSP(dsp, wavetable, wavetable.count, Int32(index))
    }

    public func setWavetable(data: UnsafePointer<Float>?, size: Int, index: Int = 0) {
        setWavetableDSP(dsp, data, size, Int32(index))
    }
}
