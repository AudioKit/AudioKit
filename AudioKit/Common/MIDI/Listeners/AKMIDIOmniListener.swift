//
//  AKMIDIOmniListener.swift
//  AudioKit
//
//  Created by Kurt Arnlund on 1/27/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//
//  AKMIDIOMNIListener: AKMIDIListener
//
//  This class probably needs to support observers as well
//  so that a client may be able to be notified of state changes

import Foundation
import CoreMIDI

open class AKMIDIOMNIListener: NSObject {

    var omniMode: Bool

    @objc public init(omni: Bool = true) {
        omniMode = omni
    }
}

// MARK: - AKMIDIOMNIListener should be used as an AKMIDIListener

extension AKMIDIOMNIListener: AKMIDIListener {

    public func receivedMIDIController(_ controller: MIDIByte,
                                       value: MIDIByte,
                                       channel: MIDIChannel,
                                       offset: MIDITimeStamp = 0) {
        if controller == AKMIDIControl.omniModeOff.rawValue {
            guard omniMode == true else { return }
            omniMode = false
            omniStateChange()
        }
        if controller == AKMIDIControl.omniModeOn.rawValue {
            guard omniMode == false else { return }
            omniMode = true
            omniStateChange()
        }
    }

    @objc public func omniStateChange() {

    }
}
