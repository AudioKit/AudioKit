//
//  AKMIDIInstrument.swift
//  AudioKit
//
//  Created by Jeff Cooper on 1/1/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AVFoundation
import CoreAudio

/// A version of AKInstrument specifically targeted to instruments that 
/// should be triggerable via MIDI or sequenced with the sequencer.
public class AKMIDIInstrument: AKNode {

    /// MIDI Input
    public var midiIn = MIDIEndpointRef()
    
    /// Name of the instrument
    public var name = "AKMIDIInstrument"
    
    internal var internalInstrument: AKPolyphonicInstrument?
    
    /// Initialize the MIDI instrument
    ///
    /// - parameter instrument: A polyphonic instrument that will be triggered via MIDI
    ///
    public init(instrument: AKPolyphonicInstrument) {
        internalInstrument = instrument;
        super.init()
        avAudioNode = (internalInstrument?.avAudioNode)!
    }
    
    /// Enable MIDI input from a given MIDI client
    /// This is not in the init function because it must be called AFTER you start audiokit
    ///
    /// - parameter midiClient: A refernce to the midi client
    /// - parameter name: Name to connect with
    ///
    public func enableMIDI(midiClient: MIDIClientRef, name: String) {
        var result:OSStatus
        result = MIDIDestinationCreateWithBlock(midiClient, name, &midiIn, MyMIDIReadBlock)
        CheckError(result)
    }
    
    // Send MIDI data to the audio unit
    func handleMIDI(data1: UInt32, data2: UInt32, data3: UInt32) {
        let status = data1 >> 4
        let channel = data1 & 0xF
        if(Int(status) == AKMIDIStatus.NoteOn.rawValue && data3 > 0) {
            startNote(Int(data2), withVelocity: Int(data3), onChannel: Int(channel))
        }else if(Int(status) == AKMIDIStatus.NoteOn.rawValue && data3 == 0) {
            stopNote(Int(data2), onChannel: Int(channel))
        }
    }
    
    /// Handle MIDI commands that come in through NSNotificationCenter
    ///
    /// - parameter notification: Notification fo a note on or off event
    ///
    public func handleMIDINotification(notification: NSNotification) {
        let note     = Int((notification.userInfo?["note"])!     as! NSNumber)
        let velocity = Int((notification.userInfo?["velocity"])! as! NSNumber)
        let channel  = Int((notification.userInfo?["channel"])!  as! NSNumber)
        
        if(notification.name == AKMIDIStatus.NoteOn.name() && velocity > 0) {
            startNote(note, withVelocity: velocity, onChannel: channel)
        } else if ((
            notification.name == AKMIDIStatus.NoteOn.name() && velocity == 0) ||
            notification.name == AKMIDIStatus.NoteOff.name()) {
            stopNote(note, onChannel: channel)
        }
    }
    
    /// Start a note
    public func startNote(note: Int, withVelocity velocity: Int, onChannel channel: Int) {
        internalInstrument!.playNote(note, velocity: velocity)
    }
    
    /// Stop a note
    public func stopNote(note: Int, onChannel channel: Int) {
        internalInstrument!.stopNote(note)
    }
    
    private func MyMIDIReadBlock(
        packetList: UnsafePointer<MIDIPacketList>,
        srcConnRefCon: UnsafeMutablePointer<Void>) -> Void {
            let numPackets = Int(packetList.memory.numPackets)
            let packet = packetList.memory.packet as MIDIPacket
            var packetPtr: UnsafeMutablePointer<MIDIPacket> = UnsafeMutablePointer.alloc(1)
            packetPtr.initialize(packet)
            for var i = 0; i < numPackets; ++i {
                let event = AKMIDIEvent(packet: packetPtr.memory)
                //the next line is unique for midiInstruments - otherwise this function is the same as AKMIDI
                handleMIDI(UInt32(event.internalData[0]), data2: UInt32(event.internalData[1]), data3: UInt32(event.internalData[2]))
                packetPtr = MIDIPacketNext(packetPtr)
            }
    }
}