//
//  AudioKit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

public typealias AKCallback = Void -> Void

/// Top level AudioKit managing class
@objc public class AudioKit: NSObject {

    // MARK: Global audio format (44.1K, Stereo)

    /// Format of AudioKit Nodes
    public static let format = AKSettings.audioFormat

    // MARK: - Internal audio engine mechanics

    /// Reference to the AV Audio Engine
    public static let engine = AVAudioEngine()

    static var shouldBeRunning = false

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
    /// Enumerate the list of available output devices.
    public static var availableOutputs: [AKDevice]? {
        #if os(OSX)
            EZAudioUtilities.setShouldExitOnCheckResultFail(false)
            return EZAudioDevice.outputDevices().map({ AKDevice(name: $0.name, deviceID: $0.deviceID) })
        #else
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
            var address = AudioObjectPropertyAddress(
                mSelector: kAudioHardwarePropertyDefaultInputDevice,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMaster)
            var devid = input.deviceID
            AudioObjectSetPropertyData(
                AudioObjectID(kAudioObjectSystemObject),
                &address, 0, nil, UInt32(sizeof(AudioDeviceID)), &devid)
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
    /// Change the preferred output device, giving it one of the names from the list of available output.
    public static func setOutputDevice(output: AKDevice) throws {
        #if os(OSX)
            var address = AudioObjectPropertyAddress(
                mSelector: kAudioHardwarePropertyDefaultOutputDevice,
                mScope: kAudioObjectPropertyScopeGlobal,
                mElement: kAudioObjectPropertyElementMaster)
            var devid = output.deviceID
            AudioObjectSetPropertyData(
                AudioObjectID(kAudioObjectSystemObject),
                &address, 0, nil, UInt32(sizeof(AudioDeviceID)), &devid)
        #else
            //not available on ios
        #endif
    }

    /// Start up the audio engine
    public static func start() {
        if output == nil {
            NSLog("AudioKit: No output node has been set yet, no processing will happen.")
        }
        // Start the engine.
        do {
            self.engine.prepare()

            #if os(iOS)

                NSNotificationCenter.defaultCenter().addObserver(
                    self,
                    selector: #selector(AudioKit.restartEngineAfterRouteChange(_:)),
                    name: AVAudioSessionRouteChangeNotification,
                    object: nil)
            #endif
            #if !os(OSX)
                if AKSettings.audioInputEnabled {

                #if os(iOS)
                    if AKSettings.defaultToSpeaker {

                        try AVAudioSession.sharedInstance().setCategory(
                            AVAudioSessionCategoryPlayAndRecord,
                            withOptions: AVAudioSessionCategoryOptions.DefaultToSpeaker)

                        // listen to AVAudioEngineConfigurationChangeNotification
                        // and restart the engine if it's stopped.
                        NSNotificationCenter.defaultCenter().addObserver(
                            self,
                            selector: #selector(AudioKit.audioEngineConfigurationChange(_:)),
                            name: AVAudioEngineConfigurationChangeNotification,
                            object: engine)

                    } else {
                        try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)

                    }
                #else
                    // tvOS
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)

                #endif

                } else if AKSettings.playbackWhileMuted {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                } else {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
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
    public static func stop() {
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

    // MARK: Testing

    /// Testing AKNode
    public static var tester: AKTester?

    /// Test the output of a given node
    ///
    /// - Parameters:
    ///   - node: AKNode to test
    ///   - samples: Number of samples to generate in the test
    ///
    public static func testOutput(node: AKNode, samples: Int) {
        tester = AKTester(node, samples: samples)
        output = tester
    }

    // Listen to changes in audio configuration
    // and restart the audio engine if it stops and should be playing
    @objc private static func audioEngineConfigurationChange(notification: NSNotification) -> Void {

        if (shouldBeRunning == true && self.engine.running == false) {
            do {
                try self.engine.start()
            } catch {
                print("couldn't start engine after configuration change \(error)")
            }
        }

    }

    // Restarts the engine after audio output has been changed, like headphones plugged in.
    @objc private static func restartEngineAfterRouteChange(notification: NSNotification) {
        if shouldBeRunning {
            do {
                try self.engine.start()
                // Sends notification after restarting the engine, so it is safe to resume AudioKit functions.
                if AKSettings.notificationsEnabled {
                    NSNotificationCenter.defaultCenter().postNotificationName(
                        AKNotifications.engineRestartedAfterRouteChange,
                        object: nil,
                        userInfo: notification.userInfo)

                }
            } catch {
                print("error restarting engine after route change")
            }
        }
    }

    deinit {
        #if os(iOS)
            NSNotificationCenter.defaultCenter().removeObserver(
                self,
                name: AKNotifications.engineRestartedAfterRouteChange,
                object: nil)
        #endif
    }
}
