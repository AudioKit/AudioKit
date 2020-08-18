// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

public struct AKMIDIFileChunkEvent {
    let data: [MIDIByte] // all data passed in
    let timeFormat: MIDITimeFormat
    let timeDivision: Int
    let runningStatus: AKMIDIStatus?
    let timeOffset: Int //accumulated time from previous events

    init(data: [MIDIByte],
         timeFormat: MIDITimeFormat,
         timeDivision: Int,
         timeOffset: Int,
         runningStatus: AKMIDIStatus? = nil) {
        self.data = data
        self.timeFormat = timeFormat
        self.timeDivision = timeDivision
        self.timeOffset = timeOffset
        self.runningStatus = runningStatus
    }

    // computedData adds the status if running status was used
    var computedData: [MIDIByte] {
        var outData = [MIDIByte]()
        if let addStatus = runningStatus {
            outData.append(addStatus.byte)
        }
        outData.append(contentsOf: rawEventData)
        return outData
    }

    // just the event data, no timing info
    var rawEventData: [MIDIByte] {
        return Array(data.suffix(from: timeLength))
    }

    var vlq: MIDIVariableLengthQuantity? {
        return MIDIVariableLengthQuantity(fromBytes: data)
    }

    var timeLength: Int {
        return vlq?.length ?? 0
    }

    var deltaTime: Int {
        return Int(vlq?.quantity ?? 0)
    }

    var absoluteTime: Int {
        return deltaTime + timeOffset
    }

    var position: Double {
        return Double(absoluteTime) / Double(timeDivision)
    }

    var typeByte: MIDIByte? {
        if let runningStatus = self.runningStatus {
            return runningStatus.byte
        }
        if let index = typeIndex {
            return data[index]
        }
        return nil
    }

    var typeIndex: Int? {
        if data.count > timeLength {
            if data[timeLength] == 0xFF,
                data.count > timeLength + 1 { //is Meta-Event
                return timeLength + 1
            } else if AKMIDIStatus(byte: data[timeLength]) != nil {
                return timeLength
            } else if AKMIDISystemCommand(rawValue: data[timeLength]) != nil {
                return timeLength
            }
        }
        return nil
    }

    var length: Int {
        if let metaEvent = event as? AKMIDIMetaEvent {
            return metaEvent.length
        } else if let status = event as? AKMIDIStatus {
            return status.length
        } else if let command = event as? AKMIDISystemCommand {
            if let standardLength = command.length {
                return standardLength
            } else if command == .sysEx {
                return Int(data[timeLength + 1])
            } else {
                return data.count
            }
        } else if let index = typeIndex {
            return Int(data[index + 1])
        }
        return 0
    }

    var event: AKMIDIMessage? {
        if let meta = AKMIDIMetaEvent(data: rawEventData) {
            return meta
        } else if let type = typeByte {
            if let status = AKMIDIStatus(byte: type) {
                return status
            } else if let command = AKMIDISystemCommand(rawValue: type) {
                return command
            }
        }
        return nil
    }
}
