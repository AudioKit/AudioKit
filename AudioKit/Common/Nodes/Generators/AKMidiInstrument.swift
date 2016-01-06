//
//  AKMidiInstrument.swift
//  AudioKit
//
//  Created by Jeff Cooper on 1/1/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import AVFoundation
import CoreAudio

public class AKMidiInstrument: AKNode {
    
    /// Required property for AKNode
    public var avAudioNode: AVAudioNode
    /// Required property for AKNode containing all the node's connections
    public var connectionPoints = [AVAudioConnectionPoint]()
    
    /// MIDI Input
    public var midiIn = MIDIEndpointRef()
    
    public var name = "AKMidiInstrument"
    public var internalOscs:[AKOscillator] = [] //this should ideally be anything that can be COPIED
    //public var internalOscs:[AKNode(???)] = [] //this should ideally be anything that can be COPIED
    var notesPlayed:[Int] = []
    var voicePlaying = 0
    var numVoices = 1
    let subMixer = AKMixer()
    
    public init(osc:AKOscillator, numVoicesInit:Int = 1) {
    //public init(AKNode(???), numVoicesInit:Int = 1) {
        
        print("creating akmidiinstrument with \(numVoicesInit) voices")
        
        //set up the voices
        notesPlayed = [Int](count: numVoicesInit, repeatedValue: 0)
        numVoices = numVoicesInit
        self.avAudioNode = subMixer.avAudioNode
        for (var i = 0 ; i < numVoices; ++i){
            internalOscs.append(osc.copy())
            subMixer.connect(internalOscs[i])
            internalOscs[i].amplitude = 0
        }
        
    }
    
    /// Enable MIDI input from a given MIDI client
    public func enableMidi(midiClient: MIDIClientRef, name: String) {
        var result:OSStatus
        result = MIDIDestinationCreateWithBlock(midiClient, name, &midiIn, MyMIDIReadBlock)
        CheckError(result)
    }
    
    /// Send MIDI data to the audio unit
    func handleMidi(data1: UInt32, data2: UInt32, data3: UInt32) {
        let status = data1 >> 4
        let channel = data1 & 0xF
        if(Int(status) == AKMidiStatus.NoteOn.rawValue && data3 > 0){
            startNote(UInt8(data2), withVelocity: UInt8(data3), onChannel: UInt8(channel))
        }else if(Int(status) == AKMidiStatus.NoteOn.rawValue && data3 == 0){
            stopNote(UInt8(data2), onChannel: UInt8(channel))
        }
    }
    
    public func handleMidiNotif(notif:NSNotification){
        let note = Int((notif.userInfo?["note"])! as! NSNumber)
        let vel = Int((notif.userInfo?["velocity"])! as! NSNumber)
        let chan = Int((notif.userInfo?["channel"])! as! NSNumber)
        if(notif.name == AKMidiStatus.NoteOn.name() && vel > 0){
            startNote(UInt8(note), withVelocity: UInt8(vel), onChannel: UInt8(chan))
        }else if(notif.name == AKMidiStatus.NoteOn.name() && vel == 0){
            stopNote(UInt8(note), onChannel: UInt8(chan))
        }
    }
    
    public func startNote(note: UInt8, withVelocity velocity: UInt8, onChannel channel: UInt8) {
        //print("note:\(note) - vel:\(velocity) - chan:\(channel)")
        
        let frequency = Int(note).midiNoteToFrequency()
        let amplitude = Double(velocity)/127.0
        
        internalOscs[voicePlaying].frequency = frequency
        internalOscs[voicePlaying].amplitude = amplitude
        internalOscs[voicePlaying].start()
        notesPlayed[voicePlaying] = Int(note)
        //print("Voice playing is \(voicePlaying) - note:\(note) - freq:\(internalOscs[voicePlaying].frequency)")
        
        voicePlaying = (voicePlaying + 1) % numVoices
    }
    
    public func stopNote(note: UInt8, onChannel channel: UInt8) {
        //print("note:\(note) - chan:\(channel)")
        
        var voiceToStop = notesPlayed.indexOf(Int(note))
        //print("voiceToStop: \(voiceToStop) - note:\(note)")
        while(voiceToStop != nil){
            internalOscs[voiceToStop!].stop()
            notesPlayed[voiceToStop!] = 0
            voiceToStop = notesPlayed.indexOf(Int(note))
        }
    }
    
    public func panic(){
        for(var i = 0; i < numVoices; i++){
            internalOscs[i].amplitude = 0
        }
    }
    
    private func MyMIDIReadBlock(
        packetList: UnsafePointer<MIDIPacketList>,
        srcConnRefCon: UnsafeMutablePointer<Void>) -> Void {
            let numPackets = Int(packetList.memory.numPackets)
            let packet = packetList.memory.packet as MIDIPacket
            var packetPtr: UnsafeMutablePointer<MIDIPacket> = UnsafeMutablePointer.alloc(1)
            packetPtr.initialize(packet)
            for var i = 0; i < numPackets; ++i {
                let event = AKMidiEvent(packet: packetPtr.memory)
                //the next line is unique for midiInstruments - otherwise this function is the same as AKMidi
                handleMidi(UInt32(event.internalData[0]), data2: UInt32(event.internalData[1]), data3: UInt32(event.internalData[2]))
                packetPtr = MIDIPacketNext(packetPtr)
            }
    }
}