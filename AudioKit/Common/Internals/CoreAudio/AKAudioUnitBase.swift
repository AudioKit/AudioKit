// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/


import AudioToolbox

open class AKAudioUnitBase: AUAudioUnit {
    // MARK: AUAudioUnit Overrides

    private var inputBusArray: [AUAudioUnitBus] = []
    private var outputBusArray: [AUAudioUnitBus] = []

    private var pcmBufferArray: [AVAudioPCMBuffer?] = []

    public override func allocateRenderResources() throws {
        try super.allocateRenderResources()

        let format = AKSettings.audioFormat

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

    public override func deallocateRenderResources() {
        super.deallocateRenderResources()
        deallocateRenderResourcesDSP(dsp)
        pcmBufferArray.removeAll()
    }

    public override func reset() {
        resetDSP(dsp)
    }

    private lazy var auInputBusArray: AUAudioUnitBusArray = {
        AUAudioUnitBusArray(audioUnit: self, busType: .input, busses: inputBusArray)
    }()

    public override var inputBusses: AUAudioUnitBusArray {
        return auInputBusArray
    }

    private lazy var auOutputBusArray: AUAudioUnitBusArray = {
        AUAudioUnitBusArray(audioUnit: self, busType: .output, busses: outputBusArray)
    }()

    public override var outputBusses: AUAudioUnitBusArray {
        return auOutputBusArray
    }

    public override var internalRenderBlock: AUInternalRenderBlock {
        internalRenderBlockDSP(dsp)
    }

    private var _parameterTree: AUParameterTree?
    public override var parameterTree: AUParameterTree? {
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

    public override var canProcessInPlace: Bool {
        return canProcessInPlaceDSP(dsp)
    }

    // MARK: Lifecycle

    public private(set) var dsp: AKDSPRef?

    public override init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        // Create pointer to the underlying C++ DSP code
        dsp = createDSP()
        if dsp == nil { throw AKError.InvalidDSPObject }

        // create audio bus connection points
        let format = AKSettings.audioFormat
        for _ in 0..<inputBusCountDSP(dsp) {
            inputBusArray.append(try AUAudioUnitBus(format: format))
        }
        for _ in 0..<outputBusCountDSP(dsp) {
            outputBusArray.append(try AUAudioUnitBus(format: format))
        }
    }

    deinit {
        deleteDSP(dsp)
    }

    // MARK: AudioKit

    public private(set) var isStarted: Bool = true

    /// Paramater ramp duration (seconds)
    public var rampDuration: Double = AKSettings.rampDuration {
        didSet {
            setParameterRampDurationDSP(dsp, 0, Float(rampDuration))
        }
    }

    /// This should be overridden. All the base class does is make sure that the pointer to the DSP is invalid.
    open func createDSP() -> AKDSPRef? {
        return nil
    }

    public func start() {
        shouldBypassEffect = false
        isStarted = true
        startDSP(dsp)
    }

    public func stop() {
        shouldBypassEffect = true
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
