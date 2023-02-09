// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#if !os(tvOS)

import Foundation
import MIDIKitIO
import Utilities

///  This class probably needs to support observers as well
///  so that a client may be able to be notified of state changes
///
///  This class is constructed to be subclassed.
///
///  Subclasses can override monoPolyChange() to observe changes
///
/// MIDI Mono Poly Listener is a generic object but  should be used as an MIDIListener
public class MIDIMonoPolyListener: NSObject {
    var monoMode: Bool

    /// Initialize in mono or poly
    /// - Parameter mono: Mono mode, for poly set to false
    public init(mono: Bool = true) {
        monoMode = mono
    }
}

extension MIDIMonoPolyListener: MIDIListener {
    public func received(midiEvent: MIDIEvent, timeStamp _: CoreMIDITimeStamp, source _: MIDIOutputEndpoint?) {
        switch midiEvent {
            case let .cc(payload):
                switch payload.controller {
                    case .mode(.monoModeOn):
                        guard monoMode == false else { return }
                        monoMode = true
                        monoPolyChanged()

                    case .mode(.polyModeOn):
                        guard monoMode == true else { return }
                        monoMode = false
                        monoPolyChanged()

                    default:
                        break
                }
            default:
                break
        }
    }

    public func received(midiNotification _: MIDIKitIO.MIDIIONotification) {
        // not needed
    }
}

public extension MIDIMonoPolyListener {
    /// Function called when mono poly mode has changed
    func monoPolyChanged() {
        // override in subclass?
    }
}

#endif
