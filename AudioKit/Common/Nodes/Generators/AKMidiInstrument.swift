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
    public var voices:[AKVoice] = []
    var notesPlayed:[Int] = []
    var voicePlaying = 0
    var numVoices = 1
    let subMixer = AKMixer()
    
    public init(inst:AKVoice, numVoicesInit:Int = 1) {
        
        print("creating akmidiinstrument with \(numVoicesInit) voices")
        
        //set up the voices
        notesPlayed = [Int](count: numVoicesInit, repeatedValue: 0)
        numVoices = numVoicesInit
        self.avAudioNode = subMixer.avAudioNode
        for (var i = 0 ; i < numVoices; ++i){
            voices.append(inst.copy())
            subMixer.connect(voices[i])
            voices[i].stop()
        }
        
    }
    
    /// Enable MIDI input from a given MIDI client
    /// This is not in the init function because it must be called AFTER you start audiokit
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
            handleNoteOn(UInt8(data2), withVelocity: UInt8(data3), onChannel: UInt8(channel))
        }else if(Int(status) == AKMidiStatus.NoteOn.rawValue && data3 == 0){
            handleNoteOff(UInt8(data2), onChannel: UInt8(channel))
        }
    }
    
    public func handleMidiNotif(notif:NSNotification){
        let note = Int((notif.userInfo?["note"])! as! NSNumber)
        let vel = Int((notif.userInfo?["velocity"])! as! NSNumber)
        let chan = Int((notif.userInfo?["channel"])! as! NSNumber)
        if(notif.name == AKMidiStatus.NoteOn.name() && vel > 0){
            handleNoteOn(UInt8(note), withVelocity: UInt8(vel), onChannel: UInt8(chan))
        }else if(notif.name == AKMidiStatus.NoteOn.name() && vel == 0){
            handleNoteOff(UInt8(note), onChannel: UInt8(chan))
        }
    }
    
    public func handleNoteOn(note: UInt8, withVelocity velocity: UInt8, onChannel channel: UInt8) {
        notesPlayed[voicePlaying] = Int(note)
        startVoice(voicePlaying, note: note, withVelocity: velocity, onChannel: channel)
        voicePlaying = (voicePlaying + 1) % numVoices
    }
    
    public func startVoice(voice: Int, note: UInt8, withVelocity velocity: UInt8, onChannel channel: UInt8) {
        print("Voice playing is \(voice) - note:\(note) - vel:\(velocity) - chan:\(channel)")
        
        ///Override this function in your subclass of AKMidiInstrument
        /*
        //an example using a basic oscillator
        let frequency = Int(note).midiNoteToFrequency()
        let amplitude = Double(velocity)/127.0
        let voiceEntity = voices[voice] as! AKOscillator //you'll need to cast the voice to it's original form
        voiceEntity.frequency = frequency
        voiceEntity.amplitude = amplitude
        voiceEntity.start()
        */
    }
    
    public func handleNoteOff(note: UInt8, onChannel channel: UInt8) {
        var voiceToStop = notesPlayed.indexOf(Int(note))
        while(voiceToStop != nil){
            stopVoice(voiceToStop!, note: note, onChannel: channel)
            notesPlayed[voiceToStop!] = 0
            voiceToStop = notesPlayed.indexOf(Int(note))
        }
    }
    
    public func stopVoice(voice: Int, note: UInt8, onChannel channel: UInt8) {
        print("Stopping voice\(voice) - note:\(note) - chan:\(channel)")
        
        ///Override this function in your subclass of AKMidiInstrument
        /*
        //an example using a basic oscillator
        let voiceEntity = voices[voice] as! AKOscillator //you'll need to cast the voice to it's original form
        voiceEntity.stop()
        */
        
    }
    
    public func panic(){
        for(var i = 0; i < numVoices; i++){
            voices[i].stop()
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