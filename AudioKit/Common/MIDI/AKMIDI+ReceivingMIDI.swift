//
//  AKMIDI+ReceivingMIDI.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
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
    public func addListener(_ listener: AKMIDIListener) {
        listeners.append(listener)
    }
    
    /// Add a listener to the listeners
    public func clearListeners() {
        listeners.removeAll()
    }
    
    /// Open a MIDI Input port
    ///
    /// - parameter namedInput: String containing the name of the MIDI Input
    ///
    public func openInput(_ namedInput: String = "") {
        var result = noErr
        
        let sourceCount = MIDIGetNumberOfSources()
        
        for i in 0 ..< sourceCount {
            let src = MIDIGetSource(i)
            var tempName: Unmanaged<CFString>? = nil
            
            MIDIObjectGetStringProperty(src, kMIDIPropertyName, &tempName)
            let inputNameStr = (tempName?.takeRetainedValue())! as String
            if namedInput.isEmpty || namedInput == inputNameStr {
                
                inputPorts[namedInput] = MIDIPortRef()
                
                var port = inputPorts[namedInput]!
                
                result = MIDIInputPortCreateWithBlock(
                    client, inputPortName, &port, MyMIDIReadBlock)
                inputPorts[namedInput] = port
                
                if result != noErr {
                    print("Error creating midiInPort : \(result)")
                }
                MIDIPortConnectSource(port, src, nil)
                endpoints[namedInput] = src
            }
        }
    }
    
    /// Close a MIDI Input port
    ///
    /// - parameter namedInput: String containing the name of the MIDI Input
    ///
    public func closeInput(_ namedInput: String = "") {
        var result = noErr
        
        for key in inputPorts.keys {
            if namedInput.isEmpty || key == namedInput {
                if let port = inputPorts[key], endpoint = endpoints[key] {
                    
                    result = MIDIPortDisconnectSource(port, endpoint)
                    if result == noErr {
                        endpoints.removeValue(forKey: namedInput)
                        inputPorts.removeValue(forKey: namedInput)
                    } else {
                        print("Error closing midiInPort : \(result)")
                    }
                }
            }
        }
    }
    
    /// Close all MIDI Input ports
    ///
    public func closeAllInputs() {
        closeInput()
    }
    
    internal func handleMidiMessage(_ event: AKMIDIEvent) {
        for listener in listeners {
            let type = event.status
            switch type {
            case AKMIDIStatus.controllerChange:
                listener.receivedMIDIController(Int(event.internalData[1]),
                                                value: Int(event.internalData[2]),
                                                channel: Int(event.channel))
            case AKMIDIStatus.channelAftertouch:
                listener.receivedMIDIAfterTouch(Int(event.internalData[1]),
                                                channel: Int(event.channel))
            case AKMIDIStatus.noteOn:
                listener.receivedMIDINoteOn(Int(event.internalData[1]),
                                            velocity: Int(event.internalData[2]),
                                            channel: Int(event.channel))
            case AKMIDIStatus.noteOff:
                listener.receivedMIDINoteOff(Int(event.internalData[1]),
                                             velocity: Int(event.internalData[2]),
                                             channel: Int(event.channel))
            case AKMIDIStatus.pitchWheel:
                listener.receivedMIDIPitchWheel(Int(event.data),
                                                channel: Int(event.channel))
            case AKMIDIStatus.polyphonicAftertouch:
                listener.receivedMIDIAftertouchOnNote(Int(event.internalData[1]),
                                                      pressure: Int(event.internalData[2]),
                                                      channel: Int(event.channel))
            case AKMIDIStatus.programChange:
                listener.receivedMIDIProgramChange(Int(event.internalData[1]),
                                                   channel: Int(event.channel))
            case AKMIDIStatus.systemCommand:
                listener.receivedMIDISystemCommand(event.internalData)
            }
        }
    }
    
    internal func MyMIDINotifyBlock(_ midiNotification: UnsafePointer<MIDINotification>) {
        _ = midiNotification.pointee
        //do something with notification - change _ above to let varname
        //print("MIDI Notify, messageId= \(notification.messageID.rawValue)")
        
    }
    
    internal func MyMIDIReadBlock(
        _ packetList: UnsafePointer<MIDIPacketList>,
        srcConnRefCon: UnsafeMutablePointer<Void>) -> Void {
        /*
         //can't yet figure out how to access the port passed via srcConnRefCon
         //maybe having this port is not that necessary though...
         let midiPortPointer = UnsafeMutablePointer<MIDIPortRef>(srcConnRefCon)
         let midiPort = midiPortPointer.memory
         */
        
        for packet in packetList.pointee {
            // a coremidi packet may contain multiple midi events
            for event in packet {
                handleMidiMessage(event)
            }
        }
    }
}
