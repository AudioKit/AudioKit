// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

//  AKMIDIMonoPolyListener: AKMIDIListener
//
//  This class probably needs to support observers as well
//  so that a client may be able to be notified of state changes
//
//  This class is constructed to be subclassed.
//
//  Subclasses can override monoPolyChange() to observe changes
//

#if !os(tvOS)

import Foundation
import CoreMIDI

public class AKMIDIMonoPolyListener: NSObject {

    var monoMode: Bool

    public init(mono: Bool = true) {
        monoMode = mono
    }
}

// MARK: - AKMIDIMonoPolyListener should be used as an AKMIDIListener

extension AKMIDIMonoPolyListener: AKMIDIListener {
    public func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
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

    public func monoPolyChange() {
        // override in subclass?
    }

    public func receivedMIDIAftertouch(noteNumber: MIDINoteNumber, pressure: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDIAftertouch(_ pressure: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDIProgramChange(_ program: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDISystemCommand(_ data: [MIDIByte], portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDISetupChange() {
        // Do nothing
    }

    public func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) {
        // Do nothing
    }

    public func receivedMIDINotification(notification: MIDINotification) {
        // Do nothing
    }
}

#endif
