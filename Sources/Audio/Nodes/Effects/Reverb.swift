// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import Utilities

/// AudioKit version of Apple's Reverb Audio Unit
///
public class Reverb: Node {
    fileprivate let effectAU: AVAudioUnit

    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var avAudioNode: AVAudioNode { effectAU }

    // Hacking start, stop, play, and bypass to use dryWetMix because reverbAU's bypass results in no sound

    /// Start the node
    public func start() {
        isStarted = true
//        reverbAU.wetDryMix = dryWetMix * 100.0
    }

    /// Stop the node
    public func stop() {
        isStarted = false
//        reverbAU.wetDryMix = 0.0
    }
//
//    /// Play the node
//    public func play() { start() }
//
    /// Bypass the node
    public func bypass() { stop() }
//
//    /// Dry/Wet Mix (Default 0.5)
//    public var dryWetMix: AUValue = 0.5 {
//        didSet {
//            dryWetMix = dryWetMix.clamped(to: 0 ... 1)
//            reverbAU.wetDryMix = dryWetMix * 100.0
//        }
//    }

    /// Load an Apple Factory Preset
    public func loadFactoryPreset(_ preset: ReverbPreset) {
        let auPreset = AUAudioUnitPreset()
        auPreset.number = preset.rawValue
        effectAU.auAudioUnit.currentPreset = auPreset
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

    /// Initialize the reverb node
    ///
    /// - Parameters:
    ///   - input: Node to reverberate
    ///   - dryWetMix: Amount of processed signal (Default: 0.5, Range: 0 - 1)
    ///
    public init(_ input: Node) {
        self.input = input

        let desc = AudioComponentDescription(appleEffect: kAudioUnitSubType_MatrixReverb)
        effectAU = instantiate(componentDescription: desc)
        associateParams(with: effectAU.auAudioUnit)

    }
}

public enum ReverbPreset: Int, CaseIterable, CustomStringConvertible {
    case smallRoom
    case mediumRoom
    case largeRoom
    case mediumHall
    case largeHall
    case plate
    case mediumChamber
    case largeChamber
    case cathedral
    case largeRoom2
    case mediumHall2
    case mediumHall3
    case largeHall2

    public var name: String {
        switch self {
        case .smallRoom:
            return "Small Room"
        case .mediumRoom:
            return "Medium Room"
        case .largeRoom:
            return "Large Room"
        case .mediumHall:
            return "Medium Hall"
        case .largeHall:
            return "Large Hall"
        case .plate:
            return "Plate"
        case .mediumChamber:
            return "Medium Chamber"
        case .largeChamber:
            return "Large Chamber"
        case .cathedral:
            return "Cathedral"
        case .largeRoom2:
            return "Large Room 2"
        case .mediumHall2:
            return "Medium Hall 2"
        case .mediumHall3:
            return "Medium Hall 3"
        case .largeHall2:
            return "Large Hall 2"
        @unknown default:
            return "Unknown "
        }
    }

    public var description: String {
        return name
    }
}
