// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public protocol AudioUnitContainer {
    associatedtype AudioUnitType: AUAudioUnit // eventually AudioUnitBase
    static var ComponentDescription: AudioComponentDescription { get }
    var internalAU: AudioUnitType? { get }
}

extension AudioUnitContainer {
    /// Register the audio unit subclass
    public func instantiateAudioUnit(callback: @escaping (AVAudioUnit) -> Void) {
        AUAudioUnit.registerSubclass(Self.AudioUnitType.self,
                                     as: Self.ComponentDescription,
                                     name: "Local \(Self.self)",
                                     version: .max)
        AVAudioUnit.instantiate(with: Self.ComponentDescription) { avAudioUnit, _ in
            guard let au = avAudioUnit else {
                fatalError("Unable to instantiate AVAudioUnit")
            }
            callback(au)
        }
    }
}

extension AUParameterTree {
    public subscript(key: String) -> AUParameter? {
        return value(forKey: key) as? AUParameter
    }
}

/// Adding convenience initializers
extension AudioComponentDescription {
    /// Initialize with type and sub-type
    public init(type: OSType, subType: OSType) {
        self.init(componentType: type,
                  componentSubType: subType,
                  componentManufacturer: fourCC("AuKt"),
                  componentFlags: AudioComponentFlags.sandboxSafe.rawValue,
                  componentFlagsMask: 0)
    }

    /// Initialize with an Apple effect
    public init(appleEffect subType: OSType) {
        self.init(componentType: kAudioUnitType_Effect,
                  componentSubType: subType,
                  componentManufacturer: kAudioUnitManufacturer_Apple,
                  componentFlags: 0,
                  componentFlagsMask: 0)
    }

    /// Initialize as an effect with sub-type
    public init(effect subType: OSType) {
        self.init(type: kAudioUnitType_Effect, subType: subType)
    }

    /// Initialize as an effect with sub-type string
    public init(effect subType: String) {
        self.init(effect: fourCC(subType))
    }

    /// Initialize as a mixer with a sub-type string
    public init(mixer subType: String) {
        self.init(type: kAudioUnitType_Mixer, subType: fourCC(subType))
    }

    /// Initialize as a generator with a sub-type string
    public init(generator subType: String) {
        self.init(type: kAudioUnitType_Generator, subType: fourCC(subType))
    }

    /// Initialize as an instrument with a sub-type string
    public init(instrument subType: String) {
        self.init(type: kAudioUnitType_MusicDevice, subType: fourCC(subType))
    }
}
