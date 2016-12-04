//
//  AKMicrophone.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Audio from the standard input
open class AKMicrophone: AKNode, AKToggleable {
    
    internal let mixer = AVAudioMixerNode()
    
    /// Output Volume (Default 1)
    open var volume: Double = 1.0 {
        didSet {
            volume = max(volume, 0)
            mixer.outputVolume = Float(volume)
        }
    }
    
    /// Set the actual microphone device
    public func setDevice(_ device: AKDevice) throws {
        #if os(OSX)
            var id = device.deviceID
            var currentID = device.deviceID
            var size: UInt32 = 0
            let _ = AudioUnitGetProperty(AudioKit.engine.inputNode!.audioUnit!,
                                         kAudioOutputUnitProperty_CurrentDevice,
                                         kAudioUnitScope_Global,
                                         0, &currentID, &size)
            if currentID != id {
                AudioUnitSetProperty(AudioKit.engine.inputNode!.audioUnit!,
                                     kAudioOutputUnitProperty_CurrentDevice,
                                     kAudioUnitScope_Global, 0,
                                     &id,
                                     UInt32(MemoryLayout<DeviceID>.size))
            }
        #else
            do {
                try AudioKit.setInputDevice(device)
            } catch {
                print("Could not set input device")
            }
        #endif
    }
    
    fileprivate var lastKnownVolume: Double = 1.0
    
    /// Determine if the microphone is currently on.
    open var isStarted: Bool {
        return volume != 0.0
    }
    
    /// Initialize the microphone 
    override public init() {
        #if !os(tvOS)
            super.init()
            self.avAudioNode = mixer
            AKSettings.audioInputEnabled = true
            AudioKit.engine.attach(mixer)
            AudioKit.engine.connect(AudioKit.engine.inputNode!, to: self.avAudioNode, format: nil)
        #endif
    }
    
    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        if isStopped {
            volume = lastKnownVolume
        }
    }
    
    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        if isPlaying {
            lastKnownVolume = volume
            volume = 0
        }
    }
}
