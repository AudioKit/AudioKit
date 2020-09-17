// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

//  MIDIMonoPolyListener: MIDIListener
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

public class MIDIMonoPolyListener: NSObject {

    var monoMode: Bool

    public init(mono: Bool = true) {
        monoMode = mono
    }
}

// MARK: - MIDIMonoPolyListener should be used as an MIDIListener

extension MIDIMonoPolyListener: MIDIListener {
    public func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
                if controller == MIDIControl.monoOperation.rawValue {
            guard monoMode == false else { return }
            monoMode = true
            monoPolyChange()
        }
        if controller == MIDIControl.polyOperation.rawValue {
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
