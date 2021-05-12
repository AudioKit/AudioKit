// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioToolbox
import AVFoundation
import CAudioKit

/// AudioUnit which instantiates a DSP kernel based on the componentSubType.
open class AudioKitAU: AUAudioUnit {
    // MARK: AUAudioUnit Overrides

    private var inputBusArray: [AUAudioUnitBus] = []
    private var outputBusArray: [AUAudioUnitBus] = []
    private var internalBuffers: [AVAudioPCMBuffer] = []

    /// Allocate the render resources
    override public func allocateRenderResources() throws {
        try super.allocateRenderResources()

        if let inputFormat = inputBusArray.first?.format {

            // we don't need to allocate a buffer if we can process in place
            if !canProcessInPlace || inputBusArray.count > 1 {
                for i in inputBusArray.indices {
                    if let buffer = AVAudioPCMBuffer(pcmFormat: inputFormat, frameCapacity: maximumFramesToRender) {
                        setBufferDSP(dsp, buffer.mutableAudioBufferList, i)
                        internalBuffers.append(buffer)
                    }
                }
            }
        }

        if let outputFormat = outputBusArray.first?.format {
            allocateRenderResourcesDSP(dsp, outputFormat.channelCount, outputFormat.sampleRate)
        }
    }

    /// Delllocate Render Resources
    override public func deallocateRenderResources() {
        super.deallocateRenderResources()
        deallocateRenderResourcesDSP(dsp)
        internalBuffers = []
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

    /// Set in order to bypass processing
    override public var shouldBypassEffect: Bool {
        get { return getBypassDSP(dsp) }
        set { setBypassDSP(dsp, newValue) }
    }

    // MARK: Lifecycle

    /// DSP Reference
    public private(set) var dsp: DSPRef?

    /// Initialize with component description and options
    /// - Parameters:
    ///   - componentDescription: Audio Component Description
    ///   - options: Audio Component Instantiation Options
    /// - Throws: error
    override public init(componentDescription: AudioComponentDescription,
                         options: AudioComponentInstantiationOptions = []) throws {
        try super.init(componentDescription: componentDescription, options: options)

        // Create pointer to C++ DSP code.
        dsp = akCreateDSP(componentDescription.componentSubType)
        assert(dsp != nil)

        // create audio bus connection points
        let format = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
        for _ in 0..<inputBusCountDSP(dsp) {
            inputBusArray.append(try AUAudioUnitBus(format: format))
        }

        // All AudioKit nodes have one output bus.
        outputBusArray.append(try AUAudioUnitBus(format: format))

        parameterTree = AUParameterTree.createTree(withChildren: [])

    }

    deinit {
        deleteDSP(dsp)
    }

    // MARK: AudioKit

    /// Trigger something within the audio unit
    public func trigger(note: MIDINoteNumber, velocity: MIDIVelocity) {
        #if !os(tvOS)
        guard let midiBlock = scheduleMIDIEventBlock else {
            fatalError("Attempt to trigger audio unit which doesn't respond to MIDI.")
        }
        let event = MIDIEvent(noteOn: note, velocity: velocity, channel: 0)
        event.data.withUnsafeBufferPointer { ptr in
            guard let ptr = ptr.baseAddress else { return }
            midiBlock(AUEventSampleTimeImmediate, 0, event.data.count, ptr)
        }
        #endif
    }

    /// Trigger something within the audio unit
    public func trigger() {
        #if !os(tvOS)
        trigger(note: 64, velocity: 127)
        #endif
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
