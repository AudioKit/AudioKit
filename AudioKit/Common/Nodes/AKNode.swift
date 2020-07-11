// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

extension AVAudioConnectionPoint {
    convenience init(_ node: AKNode, to bus: Int) {
        self.init(node: node.avAudioUnitOrNode, bus: bus)
    }
}

/// Parent class for all nodes in AudioKit
open class AKNode: NSObject {

    /// The internal AVAudioEngine AVAudioNode
    open var avAudioNode: AVAudioNode

    /// The internal AVAudioUnit, which is a subclass of AVAudioNode with more capabilities
    open var avAudioUnit: AVAudioUnit? {
        didSet {
            if let akAudioUnit = avAudioUnit?.auAudioUnit as? AKAudioUnitBase {
                let mirror = Mirror(reflecting: self)

                for child in mirror.children {
                    if let param = child.value as? Parameter, let label = child.label {
                        // Property wrappers create a variable with an underscore
                        // prepended. Drop the underscore to look up the parameter.
                        let name = String(label.dropFirst())
                        param.projectedValue.associate(with: akAudioUnit,
                                                       identifier: name)
                    }
                }
            }
        }
    }

    /// Returns either the avAudioUnit or avAudioNode (prefers the avAudioUnit if it exists)
    open var avAudioUnitOrNode: AVAudioNode {
        return self.avAudioUnit ?? self.avAudioNode
    }

    /// Initialize the node from an AVAudioUnit
    public init(avAudioUnit: AVAudioUnit, attach: Bool = false) {
        self.avAudioUnit = avAudioUnit
        self.avAudioNode = avAudioUnit
        if attach {
            AKManager.engine.attach(avAudioUnit)
        }
    }

    /// Initialize the node from an AVAudioNode
    public init(avAudioNode: AVAudioNode, attach: Bool = false) {
        self.avAudioNode = avAudioNode
        if attach {
            AKManager.engine.attach(avAudioNode)
        }
    }

    deinit {
        detach()
    }

    /// Subclasses should override to detach all internal nodes
    open func detach() {
        AKManager.detach(nodes: [avAudioUnitOrNode])
    }
}

/// AKNodeParameter wraps AUParameter in a user-friendly interface and adds some AudioKit-specific functionality.
public class AKNodeParameter {

    private var dsp: AKDSPRef?

    private var parameter: AUParameter?

    // MARK: Parameter properties

    public private(set) var identifier: String

    public var value: AUValue = 0 {
        didSet {
            guard let min = parameter?.minValue, let max = parameter?.maxValue else { return }
            value = (min...max).clamp(value)
            if value == oldValue { return }
            parameter?.value = value
        }
    }

    public var boolValue: Bool {
        get { value > 0.5 }
        set { value = newValue ? 1.0 : 0.0 }
    }

    public var minValue: AUValue {
        parameter?.minValue ?? 0
    }

    public var maxValue: AUValue {
        parameter?.maxValue ?? 1
    }

    public var range: ClosedRange<AUValue> {
        (parameter?.minValue ?? 0) ... (parameter?.maxValue ?? 1)
    }

    public var rampDuration: Float = Float(AKSettings.rampDuration) {
        didSet {
            guard let dsp = dsp, let addr = parameter?.address else { return }
            setParameterRampDurationDSP(dsp, addr, rampDuration)
        }
    }

    public var rampTaper: Float = 1 {
        didSet {
            guard let dsp = dsp, let addr = parameter?.address else { return }
            setParameterRampTaperDSP(dsp, addr, rampTaper)
        }
    }

    public var rampSkew: Float = 0 {
        didSet {
            guard let dsp = dsp, let addr = parameter?.address else { return }
            setParameterRampSkewDSP(dsp, addr, rampSkew)
        }
    }

    // MARK: Lifecycle

    public init(identifier: String, value: AUValue = 0) {
        self.identifier = identifier
        self.value = value
    }

    /// This function should be called from AKNode subclasses as soon as a valid AU is obtained
    public func associate(with au: AKAudioUnitBase?, value: AUValue? = nil) {
        dsp = au?.dsp
        parameter = au?.parameterTree?[identifier]

        guard let dsp = dsp, let addr = parameter?.address else { return }
        setParameterRampDurationDSP(dsp, addr, rampDuration)
        setParameterRampTaperDSP(dsp, addr, rampTaper)
        setParameterRampSkewDSP(dsp, addr, rampSkew)

        let value = value ?? self.value
        // set initial value (and ensure initial value is set)
        self.value = value
        guard let min = parameter?.minValue, let max = parameter?.maxValue else { return }
        parameter?.value = (min...max).clamp(value)
    }

    /// This function should be called from AKNode subclasses as soon as a valid AU is obtained
    public func associate(with au: AKAudioUnitBase?, value: Bool) {
        associate(with: au, value: value ? 1.0 : 0.0)
    }

    /// Sends a .touch event to the parameter automation observer, beginning automation recording if
    /// enabled in AKParameterAutomation.
    /// A value may be passed as the initial automation value. The current value is used if none is passed.
    public func beginTouch(value: AUValue? = nil) {
        guard let value = value ?? parameter?.value else { return }
        parameter?.setValue(value, originator: nil, atHostTime: 0, eventType: .touch)
    }

    /// Sends a .release event to the parameter observation observer, ending any automation recording.
    /// A value may be passed as the final automation value. The current value is used if none is passed.
    public func endTouch(value: AUValue? = nil) {
        guard let value = value ?? parameter?.value else { return }
        parameter?.setValue(value, originator: nil, atHostTime: 0, eventType: .release)
    }
}

/// AKNodeParameter wraps AUParameter in a user-friendly interface and adds some AudioKit-specific functionality.
/// New version for use with Parameter property wrapper.
public class AKNodeParameter2 {

    private var dsp: AKDSPRef?

    private var parameter: AUParameter?

    // MARK: Parameter properties

    public var value: AUValue = 0 {
        didSet {
            guard let min = parameter?.minValue, let max = parameter?.maxValue else { return }
            value = (min...max).clamp(value)
            if value == oldValue { return }
            parameter?.value = value
        }
    }

    public var boolValue: Bool {
        get { value > 0.5 }
        set { value = newValue ? 1.0 : 0.0 }
    }

    public var minValue: AUValue {
        parameter?.minValue ?? 0
    }

    public var maxValue: AUValue {
        parameter?.maxValue ?? 1
    }

    public var range: ClosedRange<AUValue> {
        (parameter?.minValue ?? 0) ... (parameter?.maxValue ?? 1)
    }

    public var rampDuration: Float = Float(AKSettings.rampDuration) {
        didSet {
            guard let dsp = dsp, let addr = parameter?.address else { return }
            setParameterRampDurationDSP(dsp, addr, rampDuration)
        }
    }

    public var rampTaper: Float = 1 {
        didSet {
            guard let dsp = dsp, let addr = parameter?.address else { return }
            setParameterRampTaperDSP(dsp, addr, rampTaper)
        }
    }

    public var rampSkew: Float = 0 {
        didSet {
            guard let dsp = dsp, let addr = parameter?.address else { return }
            setParameterRampSkewDSP(dsp, addr, rampSkew)
        }
    }

    // MARK: Lifecycle

    /// This function should be called from AKNode subclasses as soon as a valid AU is obtained
    public func associate(with au: AKAudioUnitBase, identifier: String) {
        dsp = au.dsp
        parameter = au.parameterTree?[identifier]
        assert(parameter != nil)

        guard let dsp = dsp, let addr = parameter?.address else { return }
        setParameterRampDurationDSP(dsp, addr, rampDuration)
        setParameterRampTaperDSP(dsp, addr, rampTaper)
        setParameterRampSkewDSP(dsp, addr, rampSkew)

        guard let min = parameter?.minValue, let max = parameter?.maxValue else { return }
        parameter?.value = (min...max).clamp(value)
    }

    /// Sends a .touch event to the parameter automation observer, beginning automation recording if
    /// enabled in AKParameterAutomation.
    /// A value may be passed as the initial automation value. The current value is used if none is passed.
    public func beginTouch(value: AUValue? = nil) {
        guard let value = value ?? parameter?.value else { return }
        parameter?.setValue(value, originator: nil, atHostTime: 0, eventType: .touch)
    }

    /// Sends a .release event to the parameter observation observer, ending any automation recording.
    /// A value may be passed as the final automation value. The current value is used if none is passed.
    public func endTouch(value: AUValue? = nil) {
        guard let value = value ?? parameter?.value else { return }
        parameter?.setValue(value, originator: nil, atHostTime: 0, eventType: .release)
    }
}

/// Wraps AKNodeParameter so we can easily assign values to it.
///
/// Instead of`osc.frequency.value = 440`, we have `osc.frequency = 440`
///
/// Use the $ operator to access the underlying AKNodeParameter. For example:
/// `osc.$frequency.maxValue`
///
/// When writing an AKNode, use:
/// ```
/// @Parameter("myParameterName") var myParameterName: AUValue
/// ```
/// This syntax gives us additional flexibility for how parameters are implemented internally.
@propertyWrapper
public struct Parameter {

    var param = AKNodeParameter2()

    public init() { }

    public var wrappedValue: AUValue {
        get { param.value }
        set { param.value = newValue }
    }

    public var projectedValue: AKNodeParameter2 {
        get { param }
        set { param = newValue }
    }
}

extension AKNode: AKOutput {
    public var outputNode: AVAudioNode {
        return self.avAudioUnitOrNode
    }
}

/// Protocol for responding to play and stop of MIDI notes
public protocol AKPolyphonic {
    /// Play a sound corresponding to a MIDI note
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity:   MIDI Velocity
    ///   - frequency:  Play this frequency
    func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, frequency: AUValue, channel: MIDIChannel)

    /// Play a sound corresponding to a MIDI note
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity:   MIDI Velocity
    ///
    func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel)

    /// Stop a sound corresponding to a MIDI note
    ///
    /// - parameter noteNumber: MIDI Note Number
    ///
    func stop(noteNumber: MIDINoteNumber)
}

/// Bare bones implementation of AKPolyphonic protocol
@objc open class AKPolyphonicNode: AKNode, AKPolyphonic {
    /// Global tuning table used by AKPolyphonicNode (AKNode classes adopting AKPolyphonic protocol)
    @objc public static var tuningTable = AKTuningTable()
    open var midiInstrument: AVAudioUnitMIDIInstrument?

    /// Play a sound corresponding to a MIDI note with frequency
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity:   MIDI Velocity
    ///   - frequency:  Play this frequency
    ///
    open func play(noteNumber: MIDINoteNumber,
                   velocity: MIDIVelocity,
                   frequency: AUValue,
                   channel: MIDIChannel = 0) {
        AKLog("Playing note: \(noteNumber), velocity: \(velocity), frequency: \(frequency), channel: \(channel), " +
            "override in subclass")
    }

    /// Play a sound corresponding to a MIDI note
    ///
    /// - Parameters:
    ///   - noteNumber: MIDI Note Number
    ///   - velocity:   MIDI Velocity
    ///
    open func play(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel = 0) {
        // MARK: Microtonal pitch lookup

        // default implementation is 12 ET
        let frequency = AKPolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber)
        self.play(noteNumber: noteNumber, velocity: velocity, frequency: AUValue(frequency), channel: channel)
    }

    /// Stop a sound corresponding to a MIDI note
    ///
    /// - parameter noteNumber: MIDI Note Number
    ///
    open func stop(noteNumber: MIDINoteNumber) {
        AKLog("Stopping note \(noteNumber), override in subclass")
    }
}

/// Protocol for dictating that a node can be in a started or stopped state
public protocol AKToggleable {
    /// Tells whether the node is processing (ie. started, playing, or active)
    var isStarted: Bool { get }

    /// Function to start, play, or activate the node, all do the same thing
    func start()

    /// Function to stop or bypass the node, both are equivalent
    func stop()
}

/// Default functions for nodes that conform to AKToggleable
public extension AKToggleable {
    /// Synonym for isStarted that may make more sense with musical instruments
    var isPlaying: Bool {
        return isStarted
    }

    /// Antonym for isStarted
    var isStopped: Bool {
        return !isStarted
    }

    /// Antonym for isStarted that may make more sense with effects
    var isBypassed: Bool {
        return !isStarted
    }

    /// Synonym to start that may more more sense with musical instruments
    func play() {
        start()
    }

    /// Synonym for stop that may make more sense with effects
    func bypass() {
        stop()
    }
}

public extension AKToggleable where Self: AKComponent {

    var isStarted: Bool {
        return (internalAU as? AKAudioUnitBase)?.isStarted ?? false
    }

    func start() {
        (internalAU as? AKAudioUnitBase)?.start()
    }

    func stop() {
        (internalAU as? AKAudioUnitBase)?.stop()
    }
}
