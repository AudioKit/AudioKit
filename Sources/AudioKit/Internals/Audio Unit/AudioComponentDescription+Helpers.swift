// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

public extension AUParameterTree {
    /// Look up parameters by key
    subscript(key: String) -> AUParameter? {
        return value(forKey: key) as? AUParameter
    }
}

/// Adding convenience initializers
public extension AudioComponentDescription {
    /// Initialize with type and sub-type
    /// - Parameters:
    ///   - type: Primary type
    ///   - subType: OSType Subtype
    init(type: OSType, subType: OSType) {
        self.init(componentType: type,
                  componentSubType: subType,
                  componentManufacturer: fourCC("AuKt"),
                  componentFlags: AudioComponentFlags.sandboxSafe.rawValue,
                  componentFlagsMask: 0)
    }

    /// Initialize with an Apple effect
    /// - Parameter subType: Apple effect subtype
    init(appleEffect subType: OSType) {
        self.init(componentType: kAudioUnitType_Effect,
                  componentSubType: subType,
                  componentManufacturer: kAudioUnitManufacturer_Apple,
                  componentFlags: 0,
                  componentFlagsMask: 0)
    }

    /// Initialize as an effect with sub-type
    /// - Parameter subType: OSType
    init(effect subType: OSType) {
        self.init(type: kAudioUnitType_MusicEffect, subType: subType)
    }

    /// Initialize as an effect with sub-type string
    /// - Parameter subType: Subtype string
    init(effect subType: String) {
        self.init(effect: fourCC(subType))
    }

    /// Initialize as a non-realtime effect with sub-type
    /// - Parameter subType: OSType
    init(nonRealTimeEffect subType: OSType) {
        self.init(type: kAudioUnitType_FormatConverter, subType: subType)
    }

    /// Initialize as a non-realtime effect with sub-type string
    /// - Parameter subType: Subtype string
    init(nonRealTimeEffect subType: String) {
        self.init(nonRealTimeEffect: fourCC(subType))
    }

    /// Initialize as a mixer with a sub-type string
    /// - Parameter subType: Subtype string
    init(mixer subType: String) {
        self.init(type: kAudioUnitType_Mixer, subType: fourCC(subType))
    }

    /// Initialize as a generator with a sub-type string
    /// - Parameter subType: Subtype string
    init(generator subType: String) {
        self.init(type: kAudioUnitType_Generator, subType: fourCC(subType))
    }

    /// Initialize as an instrument with a sub-type string
    /// - Parameter subType: Subtype string
    init(instrument subType: String) {
        self.init(type: kAudioUnitType_MusicDevice, subType: fourCC(subType))
    }
}
