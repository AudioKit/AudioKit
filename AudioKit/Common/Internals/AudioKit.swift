//
//  AudioKit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

public typealias AKCallback = (Void) -> Void

extension AVAudioEngine {
    open func connect(_ node1: AVAudioNode, to node2: AVAudioNode) {
        self.connect(node1, to: node2, format: AudioKit.format)
    }
}

/// Top level AudioKit managing class
@objc open class AudioKit: NSObject {

    // MARK: Global audio format (44.1K, Stereo)

    /// Format of AudioKit Nodes
    open static var format = AKSettings.audioFormat

    // MARK: - Internal audio engine mechanics

    /// Reference to the AV Audio Engine
    open static let engine = AVAudioEngine()

    static var shouldBeRunning = false

    /// An audio output operation that most applications will need to use last
    open static var output: AKNode? {
        didSet {
            engine.connect(output!.avAudioNode, to: engine.outputNode)
        }
    }
    
    // MARK: - Device Management

    /// Enumerate the list of available input devices.
    open static var availableInputs: [AKDevice]? {
        #if os(OSX)
            EZAudioUtilities.setShouldExitOnCheckResultFail(false)
            return EZAudioDevice.inputDevices().map {
                AKDevice(name: ($0 as AnyObject).name, deviceID: ($0 as AnyObject).deviceID)
            }
        #else
            if let devices = AVAudioSession.sharedInstance().availableInputs {
                return devices.map {
                    AKDevice(name: $0.portName, deviceID: $0.uid)
                }
            }
            return nil
        #endif
    }
    /// Enumerate the list of available output devices.
    open static var availableOutputs: [AKDevice]? {
        #if os(OSX)
            EZAudioUtilities.setShouldExitOnCheckResultFail(false)
            return EZAudioDevice.outputDevices().map {
                AKDevice(name: ($0 as AnyObject).name, deviceID: ($0 as AnyObject).deviceID)
            }
        #else
            return nil
        #endif
    }

    /// The name of the current preferred input device, if available.
    open static var inputDevice: AKDevice? {
        #if os(OSX)
            if let dev = EZAudioDevice.currentInput() {
                return AKDevice(name: dev.name, deviceID: dev.deviceID)
            }
        #else
            if let dev = AVAudioSession.sharedInstance().preferredInput {
                return AKDevice(name: dev.portName, deviceID: dev.uid)
            }
        #endif
        return nil
    }

    /// Change the preferred input device, giving it one of the names from the list of available inputs.
    open static func setInputDevice(_ input: AKDevice) throws {
        #if os(OSX)
            var address = AudioObjectPropertyAddress(
                mSelector: kAudioHardwarePropertyDefaultInputDevice,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMaster)
            var devid = input.deviceID
            AudioObjectSetPropertyData(
                AudioObjectID(kAudioObjectSystemObject),
                &address, 0, nil, UInt32(MemoryLayout<AudioDeviceID>.size), &devid)
        #else
            if let devices = AVAudioSession.sharedInstance().availableInputs {
                for dev in devices {
                    if dev.uid == input.deviceID {
                        try AVAudioSession.sharedInstance().setPreferredInput(dev)
                    }
                }
            }
        #endif
    }
    
    /// Change the preferred output device, giving it one of the names from the list of available output.
    open static func setOutputDevice(_ output: AKDevice) throws {
        #if os(OSX)
            var address = AudioObjectPropertyAddress(
                mSelector: kAudioHardwarePropertyDefaultOutputDevice,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMaster)
            var devid = output.deviceID
            AudioObjectSetPropertyData(
                AudioObjectID(kAudioObjectSystemObject),
                &address, 0, nil, UInt32(MemoryLayout<AudioDeviceID>.size), &devid)
        #else
            //not available on ios
        #endif
    }

    // MARK: - Start/Stop
    
    /// Start up the audio engine
    open static func start() {
        if output == nil {
            NSLog("AudioKit: No output node has been set yet, no processing will happen.")
        }
        // Start the engine.
        do {
            self.engine.prepare()

            #if os(iOS)

                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(restartEngineAfterRouteChange),
                    name: NSNotification.Name.AVAudioSessionRouteChange,
                    object: nil)
            #endif
            #if !os(OSX)
                if AKSettings.audioInputEnabled {

                #if os(iOS)
                    if AKSettings.defaultToSpeaker {
                        try AKSettings.setSession(category: .playAndRecord,
                                                  with: .defaultToSpeaker)

                        // listen to AVAudioEngineConfigurationChangeNotification
                        // and restart the engine if it is stopped.
                        NotificationCenter.default.addObserver(
                            self,
                            selector: #selector(audioEngineConfigurationChange),
                            name: NSNotification.Name.AVAudioEngineConfigurationChange,
                            object: engine)

                    } else {

                        try AKSettings.setSession(category: .playAndRecord,
                                                  with: .mixWithOthers)

                    }
                #else
                    // tvOS

                    try AKSettings.setSession(category: .playAndRecord)

                #endif

                } else if AKSettings.playbackWhileMuted {

                    try AKSettings.setSession(category: .playback)

                } else {
                    try AKSettings.setSession(category: .ambient)

                }
            #if os(iOS)
                try AVAudioSession.sharedInstance().setActive(true)
            #endif

            #endif

            try self.engine.start()

            shouldBeRunning = true
        } catch {
            fatalError("AudioKit: Could not start engine. error: \(error).")
        }

    }

    /// Stop the audio engine
    open static func stop() {
        // Stop the engine.
        self.engine.stop()
        shouldBeRunning = false
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("couldn't stop session \(error)")
        }
        #endif
    }

    // MARK: - Testing

    /// Testing AKNode
    open static var tester: AKTester?

    /// Test the output of a given node
    ///
    /// - Parameters:
    ///   - node: AKNode to test
    ///   - duration: Number of seconds to test (accurate to the sample)
    ///
    open static func test(node: AKNode, duration: Double) {
        let samples = Int(duration * AKSettings.sampleRate)
        
        tester = AKTester(node, samples: samples)
        output = tester
        start()
        self.engine.pause()
        tester?.play()
        let renderer = AKOfflineRenderer(engine: self.engine)
        renderer?.render(Int32(samples))
    }
    
    /// Audition the test to hear what it sounds like
    ///
    /// - Parameters:
    ///   - node: AKNode to test
    ///   - duration: Number of seconds to test (accurate to the sample)
    ///
    open static func auditionTest(node: AKNode, duration: Double) {
        output = node
        start()
        if let playableNode = node as? AKToggleable {
            playableNode.play()
        }
        usleep(UInt32(duration * 1000000))
        stop()
        start()
    }
    
    // MARK: - Configuration Change Response

    // Listen to changes in audio configuration
    // and restart the audio engine if it stops and should be playing
    @objc fileprivate static func audioEngineConfigurationChange(_ notification: Notification) -> Void {

        if shouldBeRunning && !engine.isRunning {
            do {
                try self.engine.start()
            } catch {
                print("couldn't start engine after configuration change \(error)")
            }
        }

    }

    // Restarts the engine after audio output has been changed, like headphones plugged in.
    @objc fileprivate static func restartEngineAfterRouteChange(_ notification: Notification) {
        if shouldBeRunning {
            do {
                try self.engine.start()
                // Sends notification after restarting the engine, so it is safe to resume AudioKit functions.
                if AKSettings.notificationsEnabled {
                    NotificationCenter.default.post(
                        name: Notification.Name(rawValue: AKNotifications.engineRestartedAfterRouteChange),
                        object: nil,
                        userInfo: (notification as NSNotification).userInfo)

                }
            } catch {
                print("error restarting engine after route change")
            }
        }
    }
    
    // MARK: - Deinitialization

    deinit {
        #if os(iOS)
            NotificationCenter.default.removeObserver(
                self,
                name: NSNotification.Name(rawValue: AKNotifications.engineRestartedAfterRouteChange),
                object: nil)
        #endif
    }
}
