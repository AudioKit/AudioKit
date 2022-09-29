// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/// AudioKit version of Apple's Distortion Audio Unit
///
@available(iOS 8.0, *)
public class AppleDistortion: Node {
    fileprivate let distAU = AVAudioUnitDistortion()

    let input: Node

    /// Connected nodes
    public var connections: [Node] { [input] }

    /// Underlying AVAudioNode
    public var avAudioNode: AVAudioNode

    /// Dry/Wet Mix (Default 50)
    public var dryWetMix: AUValue = 50 {
        didSet {
            distAU.wetDryMix = dryWetMix
        }
    }

    /// preGain (Default -6)
    public var preGain: AUValue = -6 {
        didSet {
            distAU.preGain = preGain
        }
    }

    /// Initialize the distortion node
    ///
    /// - Parameters:
    ///   - input: Node to distort
    ///   - dryWetMix: Amount of processed signal (Default: 50, Range: 0 - 100)
    ///   - preGain: Amount of processed signal (Default: -6, Range: -80 - 20)
    ///
    public init(_ input: Node, dryWetMix: AUValue = 50,
                preGain: AUValue = -6) {
        self.input = input
        self.dryWetMix = dryWetMix

        avAudioNode = distAU

        distAU.preGain = preGain
        distAU.wetDryMix = dryWetMix
    }

    /// Load an Apple Factory Preset
    public func loadFactoryPreset(_ preset: AVAudioUnitDistortionPreset) {
        distAU.loadFactoryPreset(preset)
    }
}

@available(iOS 8.0, *)
public extension AVAudioUnitDistortionPreset {
    static var allCases: [AVAudioUnitDistortionPreset] =
        [.drumsBitBrush, .drumsBufferBeats,
         .drumsLoFi, .multiBrokenSpeaker, .multiCellphoneConcert,
         .multiDecimated1, .multiDecimated2, .multiDecimated3,
         .multiDecimated4, .multiDistortedFunk, .multiDistortedCubed,
         .multiDistortedSquared, .multiEcho1, .multiEcho2,
         .multiEchoTight1, .multiEchoTight2, .multiEverythingIsBroken,
         .speechAlienChatter, .speechCosmicInterference, .speechGoldenPi,
         .speechRadioTower, .speechWaves]

    var name: String {
        switch self {
        case .drumsBitBrush:
            return "Drums Bit Brush"
        case .drumsBufferBeats:
            return "Drums Buffer Beats"
        case .drumsLoFi:
            return "Drums LoFi"
        case .multiBrokenSpeaker:
            return "Multi-Broken Speaker"
        case .multiCellphoneConcert:
            return "Multi-Cellphone Concert"
        case .multiDecimated1:
            return "Multi-Decimated 1"
        case .multiDecimated2:
            return "Multi-Decimated 2"
        case .multiDecimated3:
            return "Multi-Decimated 3"
        case .multiDecimated4:
            return "Multi-Decimated 4"
        case .multiDistortedFunk:
            return "Multi-Distorted Funk"
        case .multiDistortedCubed:
            return "Multi-Distorted Cubed"
        case .multiDistortedSquared:
            return "Multi-Distorted Squared"
        case .multiEcho1:
            return "Multi-Echo 1"
        case .multiEcho2:
            return "Multi-Echo 2"
        case .multiEchoTight1:
            return "Multi-Echo Tight 1"
        case .multiEchoTight2:
            return "Multi-Echo Tight 2"
        case .multiEverythingIsBroken:
            return "Multi-Everything Is Broken"
        case .speechAlienChatter:
            return "Speech Alien Chatter"
        case .speechCosmicInterference:
            return "Speech Cosmic Interference"
        case .speechGoldenPi:
            return "Speech Golden Pi"
        case .speechRadioTower:
            return "Speech Radio Tower"
        case .speechWaves:
            return "Speech Waves"
        @unknown default:
            return "Unknown"
        }
    }

    static var defaultValue: AVAudioUnitDistortionPreset {
        return .drumsBitBrush
    }

    var next: AVAudioUnitDistortionPreset {
        return AVAudioUnitDistortionPreset(rawValue:
                                            (rawValue + 1) % AVAudioUnitDistortionPreset.allCases.count)
        ?? AVAudioUnitDistortionPreset.defaultValue
    }

    var previous: AVAudioUnitDistortionPreset {
        var newValue = rawValue - 1
        while newValue < 0 {
            newValue += AVAudioUnitDistortionPreset.allCases.count
        }
        return AVAudioUnitDistortionPreset(rawValue: newValue) ?? AVAudioUnitDistortionPreset.defaultValue
    }
}
