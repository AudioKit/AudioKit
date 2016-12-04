//
//  AKComponent.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

public protocol AUComponent: class {
    associatedtype _Self = Self
    static var ComponentDescription: AudioComponentDescription { get }
}

public protocol AKComponent: AUComponent {
    associatedtype AKAudioUnitType: AnyObject
}

extension AKComponent {
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

extension AudioComponentDescription {
    public init(type: OSType, subType: OSType) {
        self.init(componentType: type,
                  componentSubType: subType,
                  componentManufacturer: fourCC("AuKt"),
                  componentFlags: 0,
                  componentFlagsMask: 0)
    }

    public init(appleEffect subType: OSType) {
        self.init(componentType: kAudioUnitType_Effect,
                  componentSubType: subType,
                  componentManufacturer: kAudioUnitManufacturer_Apple,
                  componentFlags: 0,
                  componentFlagsMask: 0)
    }

    public init(effect subType: OSType) {
        self.init(type: kAudioUnitType_Effect, subType: subType)
    }
    
    public init(effect subType: String) {
        self.init(effect: fourCC(subType))
    }
    
    public init(mixer subType: String) {
        self.init(type: kAudioUnitType_Mixer, subType: fourCC(subType))
    }
    
    public init(generator subType: String) {
        self.init(type: kAudioUnitType_Generator, subType: fourCC(subType))
    }
}

