//
//  AudioKit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Top level AudioKit managing class
@objc public class AudioKit : NSObject {
    
    // MARK: Global audio format (44.1K, Stereo)
    
    /// Format of AudioKit Nodes
    public static let format = AKSettings.audioFormat

    // MARK: - Internal audio engine mechanics
    
    /// Reference to the AV Audio Engine
    public static let engine = AVAudioEngine()
    
    /// An audio output operation that most applications will need to use last
    public static var output: AKNode? {
        didSet {
            engine.connect(output!.avAudioNode, to: engine.outputNode, format: AudioKit.format)
        }
    }
    
    /// Enumerate the list of available input devices.
    public static var availableInputs: [AKDevice]? {
        #if os(OSX)
            EZAudioUtilities.setShouldExitOnCheckResultFail(false)
            return EZAudioDevice.inputDevices().map({ AKDevice(name: $0.name, deviceID: $0.deviceID) })
        #else
            if let devices = AVAudioSession.sharedInstance().availableInputs {
                return devices.map({ AKDevice(name: $0.portName, deviceID: $0.UID) })
            }
            return nil
        #endif
    }

    /// The name of the current preferred input device, if available.
    public static var inputDevice: AKDevice? {
        #if os(OSX)
            if let dev = EZAudioDevice.currentInputDevice() {
                return AKDevice(name: dev.name, deviceID: dev.deviceID)
            }
        #else
            if let dev = AVAudioSession.sharedInstance().preferredInput {
                return AKDevice(name: dev.portName, deviceID: dev.UID)
            }
        #endif
        return nil
    }

    /// Change the preferred input device, giving it one of the names from the list of available inputs.
    public static func setInputDevice(input: AKDevice) throws {
        #if os(OSX)
            var address = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDefaultInputDevice,
                                                     mScope: kAudioObjectPropertyScopeGlobal,
                                                     mElement: kAudioObjectPropertyElementMaster)
            var devid = input.deviceID
            AudioObjectSetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, UInt32(sizeof(AudioDeviceID)), &devid)
        #else
            if let devices = AVAudioSession.sharedInstance().availableInputs {
                for dev in devices {
                    if dev.UID == input.deviceID {
                        try AVAudioSession.sharedInstance().setPreferredInput(dev)
                    }
                }
            }
        #endif
    }
    
    /// Start up the audio engine
    public static func start() {
        if output == nil {
            NSLog("AudioKit: No output node has been set yet, no processing will happen.")
        }
        // Start the engine.
        do {
            try self.engine.start()
            #if !os(OSX)
                if AKSettings.audioInputEnabled {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
                } else if AKSettings.playbackWhileMuted {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                } else {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
                }
                try AVAudioSession.sharedInstance().setActive(true)
            #endif
        } catch {
            fatalError("AudioKit: Could not start engine. error: \(error).")
        }
    }
    
    /// Stop the audio engine
    public static func stop() {
        // Stop the engine.
        self.engine.stop()
    }
    
    // MARK: Testing
    
    /// Testing AKNode
    public static var tester: AKTester?

    /// Test the output of a given node
    ///
    /// - parameter node: AKNode to test
    /// - parameter samples: Number of samples to generate in the test
    ///
    public static func testOutput(node: AKNode, samples: Int) {
        tester = AKTester(node, samples: samples)
        output = tester
    }
}
