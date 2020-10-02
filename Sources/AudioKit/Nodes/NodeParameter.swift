// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

/// Definition or specification of a node parameter
public struct NodeParameterDef {
    /// Unique ID
    public var identifier: String
    /// Name
    public var name: String
    /// Address
    public var address: AUParameterAddress
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
    ///   - range: Value range
    ///   - unit: Physical units
    ///   - flags: <#flags description#>Options
    public init(identifier: String,
                name: String,
                address: AUParameterAddress,
                range: ClosedRange<AUValue>,
                unit: AudioUnitParameterUnit,
                flags: AudioUnitParameterOptions) {
        self.identifier = identifier
        self.name = name
        self.address = address
        self.range = range
        self.unit = unit
        self.flags = flags
    }
}

/// NodeParameter wraps AUParameter in a user-friendly interface and adds some AudioKit-specific functionality.
/// New version for use with Parameter property wrapper.
public class NodeParameter {
    private var avAudioUnit: AVAudioUnit!

    /// AU Parameter that this wraps
    public private(set) var parameter: AUParameter!

    // MARK: Parameter properties

    /// Value of the parameter
    public var value: AUValue {
        get { parameter.value }
        set { parameter.value = range.clamp(newValue) }
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
        (parameter.minValue ... parameter.maxValue)
    }

    // MARK: Automation

    private var renderObserverToken: Int?

    /// Begin automation of the parameter.
    ///
    /// If `startTime` is nil, the automation will be scheduled as soon as possible.
    ///
    /// - Parameter events: automation curve
    /// - Parameter startTime: optional time to start automation
    public func automate(events: [AutomationEvent], startTime: AVAudioTime? = nil) {
        var lastRenderTime = avAudioUnit.lastRenderTime ?? AVAudioTime(sampleTime: 0, atRate: Settings.sampleRate)

        if !lastRenderTime.isSampleTimeValid {
            lastRenderTime = AVAudioTime(sampleTime: 0, atRate: Settings.sampleRate)
        }

        var lastTime = startTime ?? lastRenderTime

        if lastTime.isHostTimeValid {
            // Convert to sample time.
            let lastTimeSeconds = AVAudioTime.seconds(forHostTime: lastRenderTime.hostTime)
            let startTimeSeconds = AVAudioTime.seconds(forHostTime: lastTime.hostTime)

            lastTime = lastRenderTime.offset(seconds: startTimeSeconds - lastTimeSeconds)
        }

        assert(lastTime.isSampleTimeValid)
        stopAutomation()

        events.withUnsafeBufferPointer { automationPtr in

            guard let automationBaseAddress = automationPtr.baseAddress else { return }

            guard let observer = ParameterAutomationGetRenderObserver(parameter.address,
                                                                      avAudioUnit.auAudioUnit.scheduleParameterBlock,
                                                                      Float(Settings.sampleRate),
                                                                      Float(lastTime.sampleTime),
                                                                      automationBaseAddress,
                                                                      events.count) else { return }

            renderObserverToken = avAudioUnit.auAudioUnit.token(byAddingRenderObserver: observer)
        }
    }

    /// Automate to a new value using a ramp.
    public func ramp(to value: AUValue, duration: Float) {
        let paramBlock = avAudioUnit.auAudioUnit.scheduleParameterBlock
        paramBlock(AUEventSampleTimeImmediate,
                   AUAudioFrameCount(duration * Float(Settings.sampleRate)),
                   parameter.address,
                   range.clamp(value))
    }

    /// Stop automation
    public func stopAutomation() {
        if let token = renderObserverToken {
            avAudioUnit.auAudioUnit.removeRenderObserver(token)
        }
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

    /// This function should be called from Node subclasses as soon as a valid AU is obtained
    public func associate(with avAudioUnit: AVAudioUnit, identifier: String) {
        self.avAudioUnit = avAudioUnit
        parameter = avAudioUnit.auAudioUnit.parameterTree?[identifier]
        assert(parameter != nil)
    }

    /// Helper function to attach the parameter to the appropriate tree
    /// - Parameters:
    ///   - avAudioUnit: AVAudioUnit to associate with
    ///   - index: Position of the parameter
    public func associate(with avAudioUnit: AVAudioUnit, index: Int) {
        self.avAudioUnit = avAudioUnit
        parameter = avAudioUnit.auAudioUnit.parameterTree!.allParameters[index]
        assert(parameter != nil)
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
    /// Conver to AUValue
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
/// When writing an Node, use:
/// ```
/// @Parameter var myParameterName: AUValue
/// ```
/// This syntax gives us additional flexibility for how parameters are implemented internally.
///
/// Note that we don't allow initialization of Parameters to values
/// because we don't yet have an underlying AUParameter.
@propertyWrapper
public struct Parameter<Value: NodeParameterType>: ParameterBase {
    var param = NodeParameter()

    /// Empty initializer
    public init() {}

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
