//
//  AKComponent.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

protocol AUComponent: class {
    associatedtype _Self = Self
    static var ComponentDescription: AudioComponentDescription { get }
}

protocol AKComponent: AUComponent {
    associatedtype AKAudioUnitType: AnyObject
}

extension AKComponent {
    static func register() {
        AUAudioUnit.registerSubclass(Self.AKAudioUnitType.self,
                                     as: Self.ComponentDescription,
                                     name: "Local \(Self.self)",
                                     version: UInt32.max)
    }
}

extension AUParameterTree {
    internal subscript (key: String) -> AUParameter? {
        return value(forKey: key) as? AUParameter
    }
}

extension AudioComponentDescription {
    internal init(type: OSType, subType: OSType) {
        self.init(componentType: type,
                  componentSubType: subType,
                  componentManufacturer: fourCC("AuKt"),
                  componentFlags: 0,
                  componentFlagsMask: 0)
    }

    internal init(appleEffect subType: OSType) {
        self.init(componentType: kAudioUnitType_Effect,
                  componentSubType: subType,
                  componentManufacturer: kAudioUnitManufacturer_Apple,
                  componentFlags: 0,
                  componentFlagsMask: 0)
    }

    internal init(effect subType: OSType) {
        self.init(type: kAudioUnitType_Effect, subType: subType)
    }
    
    internal init(effect subType: String) {
        self.init(effect: fourCC(subType))
    }
    
    internal init(mixer subType: String) {
        self.init(type: kAudioUnitType_Mixer, subType: fourCC(subType))
    }
    
    internal init(generator subType: String) {
        self.init(type: kAudioUnitType_Generator, subType: fourCC(subType))
    }
}

