//
//  AKMIDI+ReceivingMIDI.swift
//  AudioKit For OSX
//
//  Created by Aurelius Prochazka on 4/30/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

extension AKMIDI {
    
    /// Array of input names
    public var inputNames: [String] {
        var nameArray = [String]()
        let sourceCount = MIDIGetNumberOfSources()
        
        for i in 0 ..< sourceCount {
            let source = MIDIGetSource(i)
            var inputName: Unmanaged<CFString>?
            inputName = nil
            MIDIObjectGetStringProperty(source, kMIDIPropertyName, &inputName)
            let inputNameStr = (inputName?.takeRetainedValue())! as String
            nameArray.append(inputNameStr)
        }
        return nameArray
    }
    
    /// Add a listener to the listeners
    public func addListener(listener: AKMIDIListener) {
        listeners.append(listener)
    }

    /// Open a MIDI Input port
    ///
    /// - parameter namedInput: String containing the name of the MIDI Input
    ///
    public func openInput(namedInput: String = "") {
        var result = noErr
        
        let sourceCount = MIDIGetNumberOfSources()
        
        for i in 0 ..< sourceCount {
            let src = MIDIGetSource(i)
            var tempName: Unmanaged<CFString>? = nil
            
            MIDIObjectGetStringProperty(src, kMIDIPropertyName, &tempName)
            let inputNameStr = (tempName?.takeRetainedValue())! as String
            if namedInput.isEmpty || namedInput == inputNameStr {
                
                inputPorts.append(MIDIPortRef())
                var port = inputPorts.last!
                result = MIDIInputPortCreateWithBlock(
                    client, inputPortName, &port, MyMIDIReadBlock)
                if result != noErr {
                    print("Error creating midiInPort : \(result)")
                }
                MIDIPortConnectSource(port, src, nil)
            }
        }
    }
    
    internal func handleMidiMessage(event: AKMIDIEvent) {
        for listener in listeners {
            let type = event.status
            switch type {
            case AKMIDIStatus.ControllerChange:
                listener.midiController(Int(event.internalData[1]),
                                        value: Int(event.internalData[2]),
                                        channel: Int(event.channel))
            case AKMIDIStatus.ChannelAftertouch:
                listener.midiAfterTouch(Int(event.internalData[1]),
                                        channel: Int(event.channel))
            case AKMIDIStatus.NoteOn:
                listener.midiNoteOn(Int(event.internalData[1]),
                                    velocity: Int(event.internalData[2]),
                                    channel: Int(event.channel))
            case AKMIDIStatus.NoteOff:
                listener.midiNoteOff(Int(event.internalData[1]),
                                     velocity: Int(event.internalData[2]),
                                     channel: Int(event.channel))
            case AKMIDIStatus.PitchWheel:
                listener.midiPitchWheel(Int(event.data),
                                        channel: Int(event.channel))
            case AKMIDIStatus.PolyphonicAftertouch:
                listener.midiAftertouchOnNote(Int(event.internalData[1]),
                                              pressure: Int(event.internalData[2]),
                                              channel: Int(event.channel))
            case AKMIDIStatus.ProgramChange:
                listener.midiProgramChange(Int(event.internalData[1]),
                                           channel: Int(event.channel))
            case AKMIDIStatus.SystemCommand:
                listener.midiSystemCommand(event.internalData)
            }
        }
    }
    
    internal func MyMIDINotifyBlock(midiNotification: UnsafePointer<MIDINotification>) {
        _ = midiNotification.memory
        //do something with notification - change _ above to let varname
        //print("MIDI Notify, messageId= \(notification.messageID.rawValue)")
        
    }
    
    internal func MyMIDIReadBlock(
        packetList: UnsafePointer<MIDIPacketList>,
        srcConnRefCon: UnsafeMutablePointer<Void>) -> Void {
        /*
         //can't yet figure out how to access the port passed via srcConnRefCon
         //maybe having this port is not that necessary though...
         let midiPortPointer = UnsafeMutablePointer<MIDIPortRef>(srcConnRefCon)
         let midiPort = midiPortPointer.memory
         */
        
        for packet in packetList.memory {
            // a coremidi packet may contain multiple midi events
            for event in packet {
                handleMidiMessage(event)
            }
        }
    }
}