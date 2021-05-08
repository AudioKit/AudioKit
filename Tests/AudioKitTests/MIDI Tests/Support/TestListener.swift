// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
import AudioKit
import CoreMIDI
import XCTest

final class TestListener: MIDIListener {
    enum Message: Equatable {

        // channel voice
        case noteOff(channel: UInt8, number: UInt8, velocity: UInt8, portID: MIDIUniqueID?)
        case noteOn(channel: UInt8, number: UInt8, velocity: UInt8, portID: MIDIUniqueID?)
        case polyPressure(channel: UInt8, number: UInt8, value: UInt8, portID: MIDIUniqueID?)
        case controlChange(channel: UInt8, number: UInt8, value: UInt8, portID: MIDIUniqueID?)
        case programChange(channel: UInt8, number: UInt8, portID: MIDIUniqueID?)
        case channelPressure(channel: UInt8, value: UInt8, portID: MIDIUniqueID?)
        case pitchBend(channel: UInt8, value: MIDIWord, portID: MIDIUniqueID?)

        // system
        case systemCommand(data: [UInt8], portID: MIDIUniqueID?)
    }
    var messages = [Message]()
    let received = XCTestExpectation()

    func receivedMIDINoteOn(noteNumber: MIDINoteNumber,
                            velocity: MIDIVelocity,
                            channel: MIDIChannel,
                            portID: MIDIUniqueID? = nil,
                            timeStamp: MIDITimeStamp? = nil) {
        DispatchQueue.main.async {
            self.messages.append(.noteOn(channel: channel,
                                         number: noteNumber,
                                         velocity: velocity,
                                         portID: portID))
            self.received.fulfill()
        }
    }

    func receivedMIDINoteOff(noteNumber: MIDINoteNumber,
                             velocity: MIDIVelocity,
                             channel: MIDIChannel,
                             portID: MIDIUniqueID? = nil,
                             timeStamp: MIDITimeStamp? = nil) {
        DispatchQueue.main.async {
            self.messages.append(.noteOff(channel: channel,
                                          number: noteNumber,
                                          velocity: velocity,
                                          portID: portID))
            self.received.fulfill()
        }
    }

    func receivedMIDIController(_ controller: MIDIByte,
                                value: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil,
                                timeStamp: MIDITimeStamp? = nil) {
        DispatchQueue.main.async {
            self.messages.append(.controlChange(channel: channel,
                                                number: controller,
                                                value: value,
                                                portID: portID))
            self.received.fulfill()
        }
    }

    func receivedMIDIAftertouch(noteNumber: MIDINoteNumber,
                                pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil,
                                timeStamp: MIDITimeStamp? = nil) {
        DispatchQueue.main.async {
            self.messages.append(.polyPressure(channel: channel,
                                               number: noteNumber,
                                               value: pressure,
                                               portID: portID))
            self.received.fulfill()
        }
    }

    func receivedMIDIAftertouch(_ pressure: MIDIByte,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil,
                                timeStamp: MIDITimeStamp? = nil) {
        DispatchQueue.main.async {
            self.messages.append(.channelPressure(channel: channel, value: pressure, portID: portID))
            self.received.fulfill()
        }
    }

    func receivedMIDIPitchWheel(_ pitchWheelValue: MIDIWord,
                                channel: MIDIChannel,
                                portID: MIDIUniqueID? = nil,
                                timeStamp: MIDITimeStamp? = nil) {
        DispatchQueue.main.async {
            self.messages.append(.pitchBend(channel: channel, value: pitchWheelValue, portID: portID))
            self.received.fulfill()
        }
    }

    func receivedMIDIProgramChange(_ program: MIDIByte,
                                   channel: MIDIChannel,
                                   portID: MIDIUniqueID? = nil,
                                   timeStamp: MIDITimeStamp? = nil) {
        DispatchQueue.main.async {
            self.messages.append(.programChange(channel: channel, number: program, portID: portID))
            self.received.fulfill()
        }

    }

    func receivedMIDISystemCommand(_ data: [MIDIByte],
                                   portID: MIDIUniqueID? = nil,
                                   timeStamp: MIDITimeStamp? = nil) {
        DispatchQueue.main.async {
            self.messages.append(.systemCommand(data: data, portID: portID))
            self.received.fulfill()
        }
    }

    func receivedMIDISetupChange() {

    }

    func receivedMIDIPropertyChange(propertyChangeInfo: MIDIObjectPropertyChangeNotification) {

    }

    func receivedMIDINotification(notification: MIDINotification) {

    }
}
#endif
