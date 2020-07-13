// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AudioKit

/// STK Clarinet
///
open class AKClarinet: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKClarinetAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "flut")
    // MARK: - Properties

    public private(set) var internalAU: AKAudioUnitType?

    /// Variable frequency. Values less than the initial frequency will be doubled until it is greater than that.
    open var frequency: AUValue = 110 {
        willSet {
            let clampedValue = (0.0 ... 20_000.0).clamp(newValue)
            guard frequency != clampedValue else { return }
            internalAU?.frequency.value = clampedValue
        }
    }

    /// Amplitude
    open var amplitude: AUValue = 0.5 {
        willSet {
            let clampedValue = (0.0 ... 10.0).clamp(newValue)
            guard amplitude != clampedValue else { return }
            internalAU?.amplitude.value = clampedValue
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU?.isStarted ?? false
    }

    // MARK: - Initialization

    /// Initialize the STK Clarinet model
    ///
    /// - Parameters:
    ///   - frequency: Variable frequency. Values less than the initial frequency will be doubled until it is
    ///                greater than that.
    ///   - amplitude: Amplitude
    ///
    public init(frequency: AUValue = 440, amplitude: AUValue = 0.5) {
        super.init(avAudioNode: AVAudioNode())

        instantiateAudioUnit { avAudioUnit in
            self.avAudioUnit = avAudioUnit
            self.avAudioNode = avAudioUnit
            self.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            self.frequency = frequency
            self.amplitude = amplitude
        }
    }

    /// Trigger the sound with current parameters
    ///
    open func trigger() {
        internalAU?.start()
        internalAU?.trigger()
    }

    /// Trigger the sound with a set of parameters
    ///
    /// - Parameters:
    ///   - frequency: Frequency in Hz
    ///   - amplitude amplitude: Volume
    ///
    open func trigger(frequency: AUValue, amplitude: AUValue = 1) {
        self.frequency = frequency
        self.amplitude = amplitude
        internalAU?.start()
        internalAU?.triggerFrequency(frequency, amplitude: amplitude)
    }

}
