//
//  AKComponent.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Helpful in reducing repetitive code in AudioKit
public protocol Aliased {
    associatedtype _Self = Self
}

/// Helpful in reducing repetitive code in AudioKit
public protocol AUComponent: class, Aliased {
    static var ComponentDescription: AudioComponentDescription { get }
}

protocol AUEffect: AUComponent { }

extension AUEffect {
    static var effect: AVAudioUnitEffect {
        return AVAudioUnitEffect(audioComponentDescription: ComponentDescription)
    }
}

/// Helpful in reducing repetitive code in AudioKit
public protocol AKComponent: AUComponent {
    associatedtype AKAudioUnitType: AnyObject
}

extension AKComponent {
    /// Register the audio unit subclass
    public static func register() {
        AUAudioUnit.registerSubclass(Self.AKAudioUnitType.self,
                                     as: Self.ComponentDescription,
                                     name: "Local \(Self.self)",
                                     version: UInt32.max)
    }
}

extension AUParameterTree {
    public subscript (key: String) -> AUParameter? {
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
                  componentFlags: 0,
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
}
