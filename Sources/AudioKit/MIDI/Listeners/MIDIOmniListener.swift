// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

//  AKMIDIOMNIListener: AKMIDIListener
//
//  This class probably needs to support observers as well
//  so that a client may be able to be notified of state changes

#if !os(tvOS)
import Foundation
import CoreMIDI

public class AKMIDIOMNIListener: NSObject {

    var omniMode: Bool

    public init(omni: Bool = true) {
        omniMode = omni
    }
}

// MARK: - AKMIDIOMNIListener should be used as an AKMIDIListener

extension AKMIDIOMNIListener: AKMIDIListener {
    public func receivedMIDINoteOn(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDINoteOff(noteNumber: MIDINoteNumber, velocity: MIDIVelocity, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
        // Do nothing
    }

    public func receivedMIDIController(_ controller: MIDIByte, value: MIDIByte, channel: MIDIChannel, portID: MIDIUniqueID?, offset: MIDITimeStamp) {
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


    public func omniStateChange() {
        // override in subclass?
    }
}

#endif
