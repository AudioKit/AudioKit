// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// Definition or specification of a node parameter
public struct NodeParameterDef {
    /// Unique ID
    public var identifier: String
    /// Name
    public var name: String
    /// Address
    public var address: AUParameterAddress
    /// Starting value if not set in initializer
    public var defaultValue: AUValue = 0.0
    /// Value Range
    public var range: ClosedRange<AUValue>
    /// Physical Units
    public var unit: AudioUnitParameterUnit
    /// Options
    public var flags: AudioUnitParameterOptions

    /// Initialize node parameter definition with all data
    /// - Parameters:
    ///   - identifier: Unique ID
    ///   - name: Name
    ///   - address: Address
    ///   - defaultValue: Starting value
    ///   - range: Value range
    ///   - unit: Physical units
    ///   - flags: Audio Unit Parameter options
    public init(identifier: String,
                name: String,
                address: AUParameterAddress,
                defaultValue: AUValue,
                range: ClosedRange<AUValue>,
                unit: AudioUnitParameterUnit,
                flags: AudioUnitParameterOptions = .default)
    {
        self.identifier = identifier
        self.name = name
        self.address = address
        self.defaultValue = defaultValue
        self.range = range
        self.unit = unit
        self.flags = flags
    }
}

/// NodeParameter wraps AUParameter in a user-friendly interface and adds some AudioKit-specific functionality.
/// New version for use with Parameter property wrapper.
public class NodeParameter {
    public private(set) var avAudioNode: AVAudioNode!

    /// AU Parameter that this wraps
    public private(set) var parameter: AUParameter!

    /// Definition.
    public var def: NodeParameterDef

    // MARK: Parameter properties

    /// Value of the parameter
    public var value: AUValue {
        get { parameter.value }
        set {
            if let avAudioUnit = avAudioNode as? AVAudioUnit {
                AudioUnitSetParameter(avAudioUnit.audioUnit,
                                      param: AudioUnitParameterID(def.address),
                                      to: newValue.clamped(to: range))
            }
            parameter.value = newValue.clamped(to: range)
        }
    }

    /// Boolean values for parameters
    public var boolValue: Bool {
        get { value > 0.5 }
        set { value = newValue ? 1.0 : 0.0 }
    }

    /// Minimum value
    public var minValue: AUValue {
        parameter.minValue
    }

    /// Maximum value
    public var maxValue: AUValue {
        parameter.maxValue
    }

    /// Value range
    public var range: ClosedRange<AUValue> {
        parameter.minValue ... parameter.maxValue
    }

    /// Initial with definition
    /// - Parameter def: Node parameter definition
    public init(_ def: NodeParameterDef) {
        self.def = def
    }

    // MARK: Automation

    public var renderObserverToken: Int?

    /// Automate to a new value using a ramp.
    public func ramp(to value: AUValue, duration: Float, delay: Float = 0) {
        var delaySamples = AUAudioFrameCount(delay * Float(Settings.sampleRate))
        if delaySamples > 4096 {
          Log("Warning: delay of \(delay) sec. at a sample rate of \(Settings.sampleRate) results in \(delaySamples), which is longer than 4096. Setting to to 4096")
            delaySamples = 4096
        }
        if !parameter.flags.contains(.flag_CanRamp) {
            Log("Error: can't ramp parameter \(parameter.displayName)", type: .error)
            return
        }
        assert(delaySamples <= 4096)
        let paramBlock = avAudioNode.auAudioUnit.scheduleParameterBlock
        paramBlock(AUEventSampleTimeImmediate + Int64(delaySamples),
                   AUAudioFrameCount(duration * Float(Settings.sampleRate)),
                   parameter.address,
                   value.clamped(to: range))
    }

    private var parameterObserverToken: AUParameterObserverToken?

    /// Records automation for this parameter.
    /// - Parameter callback: Called on the main queue for each parameter event.
    public func recordAutomation(callback: @escaping (AUParameterAutomationEvent) -> Void) {
        parameterObserverToken = parameter.token(byAddingParameterAutomationObserver: { numberEvents, events in

            for index in 0 ..< numberEvents {
                let event = events[index]

                // Dispatching to main thread avoids the restrictions
                // required of parameter automation observers.
                DispatchQueue.main.async {
                    callback(event)
                }
            }
        })
    }

    /// Stop calling the function passed to `recordAutomation`
    public func stopRecording() {
        if let token = parameterObserverToken {
            parameter.removeParameterObserver(token)
        }
    }

    // MARK: Lifecycle

    /// Helper function to attach the parameter to the appropriate tree
    /// - Parameters:
    ///   - avAudioNode: AVAudioUnit to associate with
    public func associate(with avAudioNode: AVAudioNode) {
        self.avAudioNode = avAudioNode
        guard let tree = avAudioNode.auAudioUnit.parameterTree else {
            fatalError("No parameter tree.")
        }
        parameter = tree.parameter(withAddress: def.address)
        assert(parameter != nil)
    }

    /// Helper function to attach the parameter to the appropriate tree
    /// - Parameters:
    ///   - avAudioNode: AVAudioUnit to associate with
    ///   - parameter: Parameter to associate
    public func associate(with avAudioNode: AVAudioNode, parameter: AUParameter) {
        self.avAudioNode = avAudioNode
        self.parameter = parameter
    }

    /// Sends a .touch event to the parameter automation observer, beginning automation recording if
    /// enabled in ParameterAutomation.
    /// A value may be passed as the initial automation value. The current value is used if none is passed.
    /// - Parameter value: Initial value
    public func beginTouch(value: AUValue? = nil) {
        guard let value = value ?? parameter?.value else { return }
        parameter?.setValue(value, originator: nil, atHostTime: 0, eventType: .touch)
    }

    /// Sends a .release event to the parameter observation observer, ending any automation recording.
    /// A value may be passed as the final automation value. The current value is used if none is passed.
    /// - Parameter value: Final value
    public func endTouch(value: AUValue? = nil) {
        guard let value = value ?? parameter?.value else { return }
        parameter?.setValue(value, originator: nil, atHostTime: 0, eventType: .release)
    }
}

/// So we can use NodeParameter with SwiftUI. See Cookbook.
extension NodeParameter: Identifiable { }

/// Base protocol for any type supported by @Parameter
public protocol NodeParameterType {
    /// Get the float value
    func toAUValue() -> AUValue
    /// Initialize with a floating point number
    /// - Parameter value: initial value
    init(_ value: AUValue)
}

extension Bool: NodeParameterType {
    /// Convert a Boolean to a floating point number
    /// - Returns: An AUValue
    public func toAUValue() -> AUValue {
        self ? 1.0 : 0.0
    }

    /// Initialize with a value
    /// - Parameter value: Initial value
    public init(_ value: AUValue) {
        self = value > 0.5
    }
}

extension AUValue: NodeParameterType {
    /// Convert to AUValue
    /// - Returns: Value of type AUValue
    public func toAUValue() -> AUValue {
        self
    }
}

/// Used internally so we can iterate over parameters using reflection.
protocol ParameterBase {
    var projectedValue: NodeParameter { get }
}

/// Wraps NodeParameter so we can easily assign values to it.
///
/// Instead of`osc.frequency.value = 440`, we have `osc.frequency = 440`
///
/// Use the $ operator to access the underlying NodeParameter. For example:
/// `osc.$frequency.maxValue`
///
/// When writing a Node, use:
/// ```
/// @Parameter(myParameterDef) var myParameterName: AUValue
/// ```
/// This syntax gives us additional flexibility for how parameters are implemented internally.
///
/// Note that we don't allow initialization of Parameters to values
/// because we don't yet have an underlying AUParameter.
@propertyWrapper
public struct Parameter<Value: NodeParameterType>: ParameterBase {
    var param: NodeParameter

    /// Create a parameter given a definition
    public init(_ def: NodeParameterDef) {
        param = NodeParameter(def)
    }

    /// Get the wrapped value
    public var wrappedValue: Value {
        get { Value(param.value) }
        set { param.value = newValue.toAUValue() }
    }

    /// Get the projected value
    public var projectedValue: NodeParameter {
        get { param }
        set { param = newValue }
    }
}
