//
//  AKMusicInstrument.swift
//  AudioKit For iOS
//
//  Created by Jeff Cooper on 1/6/16.
//  Copyright © 2016 AudioKit. All rights reserved.
//
import Foundation
import AVFoundation

/// Protocol for all AudioKit Nodes
public protocol AKVoice: AKNode, AKCopyableVoice, AKToggleable {
    
    //Combines these two protocols to allow for things like the midi instrument to work
}

//make sure these voices can be replicated by making them have a copy function
public protocol AKCopyableVoice {
    /// Function to duplicate this oscillator
    func copy() -> AKVoice
}
