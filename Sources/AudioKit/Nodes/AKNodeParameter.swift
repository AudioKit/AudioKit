// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import CAudioKit

public struct AKNodeParameterDef {
    public var identifier: String
    public var name: String
    public var address: AUParameterAddress
    public var range: ClosedRange<AUValue>
    public var unit: AudioUnitParameterUnit
    public var flags: AudioUnitParameterOptions
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

/// AKNodeParameter wraps AUParameter in a user-friendly interface and adds some AudioKit-specific functionality.
/// New version for use with Parameter property wrapper.
public class AKNodeParameter {

    private var avAudioUnit: AVAudioUnit!

    public private(set) var parameter: AUParameter!

    // MARK: Parameter properties

    public var value: AUValue {
        get { parameter.value }
        set { parameter.value = range.clamp(newValue) }
    }

    public var boolValue: Bool {
        get { value > 0.5 }
        set { value = newValue ? 1.0 : 0.0 }
    }

    public var minValue: AUValue {
        parameter.minValue
    }

    public var maxValue: AUValue {
        parameter.maxValue
    }

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
    public func automate(events: [AKAutomationEvent], startTime: AVAudioTime? = nil) {

        var lastRenderTime = avAudioUnit.lastRenderTime ?? AVAudioTime(sampleTime: 0, atRate: AKSettings.sampleRate)

        if !lastRenderTime.isSampleTimeValid {
            lastRenderTime = AVAudioTime(sampleTime: 0, atRate: AKSettings.sampleRate)
        }

        var lastTime = startTime ?? lastRenderTime

        if lastTime.isHostTimeValid {
            // Convert to sample time.
            let lastTimeSeconds = AVAudioTime.seconds(forHostTime: lastRenderTime.hostTime)
            let startTimeSeconds = AVAudioTime.seconds(forHostTime: lastTime.hostTime)

            lastTime = lastRenderTime.offset(seconds: (startTimeSeconds - lastTimeSeconds))
        }

        assert(lastTime.isSampleTimeValid)
        stopAutomation()

        events.withUnsafeBufferPointer { automationPtr in

            guard let automationBaseAddress = automationPtr.baseAddress else { return }

            guard let observer = AKParameterAutomationGetRenderObserver(parameter.address,
                                                                  avAudioUnit.auAudioUnit.scheduleParameterBlock,
                                                                  Float(AKSettings.sampleRate),
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
                   AUAudioFrameCount(duration * Float(AKSettings.sampleRate)),
                   parameter.address,
                   range.clamp(value))
    }

    public func stopAutomation() {

        if let token = renderObserverToken {
            avAudioUnit.auAudioUnit.removeRenderObserver(token)
        }

    }

    private var parameterObserverToken: AUParameterObserverToken?

    /// Records automation for this parameter.
    /// - Parameter callback: Called on the main queue for each parameter event.
    public func recordAutomation(callback: @escaping (AUParameterAutomationEvent) -> Void) {

        parameterObserverToken = parameter.token(byAddingParameterAutomationObserver: { (numberEvents, events) in

            for index in 0..<numberEvents {
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

    /// This function should be called from AKNode subclasses as soon as a valid AU is obtained
    public func associate(with avAudioUnit: AVAudioUnit,
                          identifier: String) {

        self.avAudioUnit = avAudioUnit
        parameter = avAudioUnit.auAudioUnit.parameterTree?[identifier]
        assert(parameter != nil)
    }

    public func associate(with avAudioUnit: AVAudioUnit,
                          index: Int) {

        self.avAudioUnit = avAudioUnit
        parameter = avAudioUnit.auAudioUnit.parameterTree!.allParameters[index]
        assert(parameter != nil)
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

/// Base protocol for any type supported by @Parameter
public protocol AKNodeParameterType {
    func toAUValue() -> AUValue
    init(_ value: AUValue)
}

extension Bool: AKNodeParameterType {
    public func toAUValue() -> AUValue {
        self ? 1.0 : 0.0
    }
    public init(_ value: AUValue) {
        self = value > 0.5
    }
}

extension AUValue: AKNodeParameterType {
    public func toAUValue() -> AUValue {
        self
    }
}

/// Used internally so we can iterate over parameters using reflection.
protocol ParameterBase {
    var projectedValue: AKNodeParameter { get }
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
/// @Parameter var myParameterName: AUValue
/// ```
/// This syntax gives us additional flexibility for how parameters are implemented internally.
///
/// Note that we don't allow initialization of Parameters to values
/// because we don't yet have an underlying AUParameter.
@propertyWrapper
public struct Parameter<Value: AKNodeParameterType>: ParameterBase {

    var param = AKNodeParameter()

    public init() { }

    public var wrappedValue: Value {
        get { Value(param.value) }
        set { param.value = newValue.toAUValue() }
    }

    public var projectedValue: AKNodeParameter {
        get { param }
        set { param = newValue }
    }
}
