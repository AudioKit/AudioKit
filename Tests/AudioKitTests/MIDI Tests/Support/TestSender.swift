// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)
import CoreMIDI

@available(iOS 14.0, OSX 11.0, *)
private extension MIDIEventList.Builder {
    // for some reason MIDIEventList.Builder causes a crash when called with a size smaller than MIDIEventList word-size
    convenience init(inProtocol: MIDIProtocolID) {
        self.init(inProtocol: inProtocol, wordSize: MemoryLayout<MIDIEventList>.size / MemoryLayout<UInt32>.stride)
    }
}

// simple test sender only for testing, will not work on simulator
class TestSender {
    var client: MIDIClientRef = 0
    var source: MIDIEndpointRef = 0

    init() {
        MIDIClientCreateWithBlock("TestClient" as CFString, &client, nil)
        if #available(iOS 14.0, OSX 11.0, *) {
            MIDISourceCreateWithProtocol(client, "TestSender" as CFString, ._1_0, &source)
        }
    }

    deinit {
        MIDIEndpointDispose(source)
        MIDIClientDispose(client)
    }

    func send(words: [UInt32]) {
        if #available(iOS 14.0, OSX 11.0, *) {
            let builder = MIDIEventList.Builder(inProtocol: ._1_0)
            builder.append(timestamp: mach_absolute_time(), words: words)
            _ = builder.withUnsafePointer {
                MIDIReceivedEventList(source, $0)
            }
        }
    }

    var uniqueID: MIDIUniqueID {
        var uniqueID: Int32 = 0
        MIDIObjectGetIntegerProperty(source, kMIDIPropertyUniqueID, &uniqueID)
        return uniqueID
    }
}
#endif
