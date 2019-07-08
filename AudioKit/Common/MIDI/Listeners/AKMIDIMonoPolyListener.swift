//
//  AKMIDIMonoPolyListener.swift
//  AudioKit
//
//  Created by Kurt Arnlund on 1/27/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//
//  AKMIDIMonoPolyListener: AKMIDIListener
//
//  This class probably needs to support observers as well
//  so that a client may be able to be notified of state changes
//
//  This class is constructed to be subclassed.
//
//  Subclasses can override monoPolyChange() to observe changes
//

import Foundation
import CoreMIDI

open class AKMIDIMonoPolyListener: NSObject {

    var monoMode: Bool

    @objc public init(mono: Bool = true) {
        monoMode = mono
    }
}

// MARK: - AKMIDIMonoPolyListener should be used as an AKMIDIListener

extension AKMIDIMonoPolyListener: AKMIDIListener {

    public func receivedMIDIController(_ controller: MIDIByte,
                                       value: MIDIByte,
                                       channel: MIDIChannel,
                                       offset: MIDITimeStamp = 0) {
        if controller == AKMIDIControl.monoOperation.rawValue {
            guard monoMode == false else { return }
            monoMode = true
            monoPolyChange()
        }
        if controller == AKMIDIControl.polyOperation.rawValue {
            guard monoMode == true else { return }
            monoMode = false
            monoPolyChange()
        }
    }

    @objc public func monoPolyChange() {

    }
}
