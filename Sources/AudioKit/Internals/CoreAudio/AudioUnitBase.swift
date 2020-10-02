// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioToolbox
import AVFoundation
import CAudioKit

/// Base class for many AudioKit nodes
open class AudioUnitBase: AUAudioUnit {
    // MARK: AUAudioUnit Overrides

    private var inputBusArray: [AUAudioUnitBus] = []
    private var outputBusArray: [AUAudioUnitBus] = []

    private var pcmBufferArray: [AVAudioPCMBuffer?] = []

    /// Allocate the render resources
    override public func allocateRenderResources() throws {
        try super.allocateRenderResources()

        let format = Settings.audioFormat

        try inputBusArray.forEach { if $0.format != format { try $0.setFormat(format) } }
        try outputBusArray.forEach { if $0.format != format { try $0.setFormat(format) } }

        // we don't need to allocate a buffer if we can process in place
        if !canProcessInPlace || inputBusArray.count > 1 {
            for i in inputBusArray.indices {
                let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: maximumFramesToRender)
                pcmBufferArray.append(buffer)
                setBufferDSP(dsp, buffer, i)
            }
        }

        allocateRenderResourcesDSP(dsp, format)
    }

    /// Delllocate Render Resources
    override public func deallocateRenderResources() {
        super.deallocateRenderResources()
        deallocateRenderResourcesDSP(dsp)
        pcmBufferArray.removeAll()
    }

    /// Reset the DSP
    override public func reset() {
        resetDSP(dsp)
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

    /// Internal render block
    override public var internalRenderBlock: AUInternalRenderBlock {
        internalRenderBlockDSP(dsp)
    }

    private var _parameterTree: AUParameterTree?
    
    /// Parameter tree
    override public var parameterTree: AUParameterTree? {
        get { return _parameterTree }
        set {
            _parameterTree = newValue

            _parameterTree?.implementorValueObserver = { [unowned self] parameter, value in
                setParameterValueDSP(self.dsp, parameter.address, value)
            }

            _parameterTree?.implementorValueProvider = { [unowned self] parameter in
                getParameterValueDSP(self.dsp, parameter.address)
            }

            _parameterTree?.implementorStringFromValueCallback = { parameter, value in
                if let value = value {
                    return String(format: "%.f", value)
                } else {
                    return "Invalid"
                }
            }
        }
    }

    /// Whether the unit can process in place
    override public var canProcessInPlace: Bool {
        return canProcessInPlaceDSP(dsp)
    }

    // MARK: Lifecycle

    /// DSP Reference
    public private(set) var dsp: DSPRef?

    /// Initialize with component description and options
    /// - Parameters:
    ///   - componentDescription: Audio Component Description
    ///   - options: Audio Component Instantiation Options
    /// - Throws: <#description#>
    override public init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        // Create pointer to the underlying C++ DSP code
        dsp = createDSP()
        if dsp == nil { throw CommonError.InvalidDSPObject }

        // create audio bus connection points
        let format = Settings.audioFormat
        for _ in 0..<inputBusCountDSP(dsp) {
            inputBusArray.append(try AUAudioUnitBus(format: format))
        }
        for _ in 0..<outputBusCountDSP(dsp) {
            outputBusArray.append(try AUAudioUnitBus(format: format))
        }

        if let paramDefs = getParameterDefs() {
            parameterTree = AUParameterTree.createTree(withChildren:
                paramDefs.map {
                    AUParameter(identifier: $0.identifier,
                                name: $0.name,
                                address: $0.address,
                                min: $0.range.lowerBound,
                                max: $0.range.upperBound,
                                unit: $0.unit,
                                flags: $0.flags)
                }
            )

        } else {
            // Create parameter tree by looking for parameters.
            let mirror = Mirror(reflecting: self)
            let params = mirror.children.compactMap { $0.value as? AUParameter }

            parameterTree = AUParameterTree.createTree(withChildren: params)
        }
    }

    deinit {
        deleteDSP(dsp)
    }

    // MARK: AudioKit

    /// Whether the audio unit is running
    public private(set) var isStarted: Bool = true

    /// This should be overridden. All the base class does is make sure that the pointer to the DSP is invalid.
    open func createDSP() -> DSPRef? {
        return nil
    }

    /// Override this to provide a list of definitions from which the `AUParameterTree` is built.
    open func getParameterDefs() -> [NodeParameterDef]? {
        return nil
    }

    /// Start the audio unit
    public func start() {
        shouldBypassEffect = false
        isStarted = true
        startDSP(dsp)
    }

    /// Stop the audio unit
    public func stop() {
        shouldBypassEffect = true
        isStarted = false
        stopDSP(dsp)
    }

    /// Trigger something within the audio unit
    public func trigger() {
        triggerDSP(dsp)
    }

    /// Common case of triggering something with a frequency and amplitude
    /// - Parameters:
    ///   - frequency: Frequency in Hertz
    ///   - amplitude: Linear amplitude
    public func triggerFrequency(_ frequency: AUValue, amplitude: AUValue) {
        triggerFrequencyDSP(dsp, frequency, amplitude)
    }

    /// Create an array of values to use as waveforms or other things inside an audio unit
    /// - Parameters:
    ///   - wavetable: Array of float values
    ///   - index: Optional index at which to set the table (useful for multiple waveform audio units)
    public func setWavetable(_ wavetable: [AUValue], index: Int = 0) {
        setWavetableDSP(dsp, wavetable, wavetable.count, Int32(index))
    }

    /// Set wave table
    /// - Parameters:
    ///   - data: A pointer to the data
    ///   - size: Size of the table
    ///   - index: Index at which to set the value
    public func setWavetable(data: UnsafePointer<AUValue>?, size: Int, index: Int = 0) {
        setWavetableDSP(dsp, data, size, Int32(index))
    }
}
