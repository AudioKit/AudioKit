// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation
import Utilities

/// AudioKit version of Apple's Reverb Audio Unit
///
public class Reverb: Node {
    public var au: AUAudioUnit

    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    // Hacking start, stop, play, and bypass to use dryWetMix because reverbAU's bypass results in no sound

    /// Specification details for dry wet mix
    public static let wetDryMixDef = NodeParameterDef(
        identifier: "wetDryMix",
        name: "Wet-Dry Mix",
        address: 0,
        defaultValue: 100,
        range: 0.0 ... 100.0,
        unit: .generic
    )

    /// Wet/Dry mix. Should be a value between 0-100.
    @Parameter(wetDryMixDef) public var wetDryMix: AUValue

    /// Load an Apple Factory Preset
    public func loadFactoryPreset(_ preset: ReverbPreset) {
        let auPreset = AUAudioUnitPreset()
        auPreset.number = preset.rawValue
        au.currentPreset = auPreset
    }

    /// Initialize the reverb node
    ///
    /// - Parameters:
    ///   - input: Node to reverberate
    ///   - wetDryMix: Amount of processed signal (Default: 100, Range: 0 - 100)
    ///
    public init(_ input: Node, wetDryMix: AUValue = 100) {
        self.input = input

        let desc = AudioComponentDescription(appleEffect: kAudioUnitSubType_Reverb2)
        au = instantiateAU(componentDescription: desc)
        associateParams(with: au)

        self.wetDryMix = wetDryMix
        Engine.nodeInstanceCount.wrappingIncrement(ordering: .relaxed)
    }

    deinit {
        Engine.nodeInstanceCount.wrappingDecrement(ordering: .relaxed)
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
        }
    }

    public var description: String {
        return name
    }
}
