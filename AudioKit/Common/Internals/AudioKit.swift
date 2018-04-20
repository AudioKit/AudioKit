//
//  AudioKit.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#if !os(tvOS)
import CoreAudioKit
#endif

#if !os(macOS)
import UIKit
#endif
import Dispatch

public typealias AKCallback = () -> Void

/// Top level AudioKit managing class
@objc open class AudioKit: NSObject {

    // MARK: Global audio format (44.1K, Stereo)

    /// Format of AudioKit Nodes
    @objc open static var format = AKSettings.audioFormat

    // MARK: - Internal audio engine mechanics

    /// Reference to the AV Audio Engine
    @objc open static var engine = AVAudioEngine()

    /// Reference to singleton MIDI

    #if !os(tvOS)
    open static let midi = AKMIDI()
    #endif

    @objc static var shouldBeRunning = false

    @objc static var finalMixer = AKMixer()

    /// Notification observers
    fileprivate static var notificationObservers: [Any] = []

    /// An audio output operation that most applications will need to use last
    @objc open static var output: AKNode? {
        didSet {
            do {
                try updateSessionCategoryAndOptions()
                output?.connect(to: finalMixer)
                engine.connect(finalMixer.avAudioNode, to: engine.outputNode)
            } catch {
                AKLog("Could not set output: \(error)")
            }
        }
    }

    // MARK: - Device Management

    /// Enumerate the list of available input devices.
    @objc open static var inputDevices: [AKDevice]? {
        #if os(macOS)
            EZAudioUtilities.setShouldExitOnCheckResultFail(false)
            return EZAudioDevice.inputDevices().map {
                AKDevice(name: ($0 as AnyObject).name, deviceID: ($0 as AnyObject).deviceID)
            }
        #else
            var returnDevices = [AKDevice]()
            if let devices = AVAudioSession.sharedInstance().availableInputs {
                for device in devices {
                    if device.dataSources == nil || device.dataSources!.isEmpty {
                        returnDevices.append(AKDevice(name: device.portName, deviceID: device.uid))
                    } else {
                        for dataSource in device.dataSources! {
                            returnDevices.append(AKDevice(name: device.portName,
                                                          deviceID: "\(device.uid) \(dataSource.dataSourceName)"))
                        }
                    }
                }
                return returnDevices
            }
            return nil
        #endif
    }

    /// Enumerate the list of available output devices.
    @objc open static var outputDevices: [AKDevice]? {
        #if os(macOS)
            EZAudioUtilities.setShouldExitOnCheckResultFail(false)
            return EZAudioDevice.outputDevices().map {
                AKDevice(name: ($0 as AnyObject).name, deviceID: ($0 as AnyObject).deviceID)
            }
        #else
            let devs = AVAudioSession.sharedInstance().currentRoute.outputs
            if devs.isNotEmpty {
                var outs = [AKDevice]()
                for dev in devs {
                    outs.append(AKDevice(name: dev.portName, deviceID: dev.uid))
                }
                return outs
            }
            return nil
        #endif
    }

    /// The name of the current input device, if available.
    @objc open static var inputDevice: AKDevice? {
        #if os(macOS)
            if let dev = EZAudioDevice.currentInput() {
                return AKDevice(name: dev.name, deviceID: dev.deviceID)
            }
        #else
            if let dev = AVAudioSession.sharedInstance().preferredInput {
                return AKDevice(name: dev.portName, deviceID: dev.uid)
            } else {
                let inputDevices = AVAudioSession.sharedInstance().currentRoute.inputs
                if inputDevices.isNotEmpty {
                    for device in inputDevices {
                        let dataSourceString = device.selectedDataSource?.description ?? ""
                        let id = "\(device.uid) \(dataSourceString)".trimmingCharacters(in: [" "])
                        return AKDevice(name: device.portName, deviceID: id)
                    }
                }
            }
        #endif
        return nil
    }

    /// The name of the current output device, if available.
    @objc open static var outputDevice: AKDevice? {
        #if os(macOS)
            if let dev = EZAudioDevice.currentOutput() {
                return AKDevice(name: dev.name, deviceID: dev.deviceID)
            }
        #else
            let devs = AVAudioSession.sharedInstance().currentRoute.outputs
            if devs.isNotEmpty {
                return AKDevice(name: devs[0].portName, deviceID: devs[0].uid)
            }

        #endif
        return nil
    }

    /// Change the preferred input device, giving it one of the names from the list of available inputs.
    @objc open static func setInputDevice(_ input: AKDevice) throws {
        #if os(macOS)
            try AKTry {
                var address = AudioObjectPropertyAddress(
                    mSelector: kAudioHardwarePropertyDefaultInputDevice,
                    mScope: kAudioObjectPropertyScopeGlobal,
                    mElement: kAudioObjectPropertyElementMaster)
                var devid = input.deviceID
                AudioObjectSetPropertyData(
                    AudioObjectID(kAudioObjectSystemObject),
                    &address, 0, nil, UInt32(MemoryLayout<AudioDeviceID>.size), &devid)
            }
        #else
            if let devices = AVAudioSession.sharedInstance().availableInputs {
                for device in devices {
                    if device.dataSources == nil || device.dataSources!.isEmpty {
                        if device.uid == input.deviceID {
                            do {
                                try AVAudioSession.sharedInstance().setPreferredInput(device)
                            } catch {
                                AKLog("Could not set the preferred input to \(input)")
                            }
                        }
                    } else {
                        for dataSource in device.dataSources! {
                            if input.deviceID == "\(device.uid) \(dataSource.dataSourceName)" {
                                do {
                                    try AVAudioSession.sharedInstance().setInputDataSource(dataSource)
                                } catch {
                                    AKLog("Could not set the preferred input to \(input)")
                                }
                            }
                        }
                    }
                }
            }

            if let devices = AVAudioSession.sharedInstance().availableInputs {
                for dev in devices {
                    if dev.uid == input.deviceID {
                        do {
                            try AVAudioSession.sharedInstance().setPreferredInput(dev)
                        } catch {
                            AKLog("Could not set the preferred input to \(input)")
                        }
                    }
                }
            }
        #endif
    }

    /// Change the preferred output device, giving it one of the names from the list of available output.
    @objc open static func setOutputDevice(_ output: AKDevice) throws {
        #if os(macOS)
            try AKTry {
                var id = output.deviceID
                if let audioUnit = AudioKit.engine.outputNode.audioUnit {
                    AudioUnitSetProperty(audioUnit,
                                         kAudioOutputUnitProperty_CurrentDevice,
                                         kAudioUnitScope_Global, 0,
                                         &id,
                                         UInt32(MemoryLayout<DeviceID>.size))
                }
            }
        #else
            //not available on ios
        #endif
    }

    // MARK: - Start/Stop

    /// Start up the audio engine with periodic functions
    open static func start(withPeriodicFunctions functions: AKPeriodicFunction...) throws {
        for function in functions {
            function.connect(to: finalMixer)
        }
        try start()
    }

    /// Start up the audio engine
    @objc open static func start() throws {
        if output == nil {
            AKLog("No output node has been set yet, no processing will happen.")
        }
        // Start the engine.
        try AKTry {
            engine.prepare()
        }

        #if os(iOS)

            if AKSettings.enableRouteChangeHandling {

                let routeChangeObserver = NotificationCenter.default.addObserver(forName: .AVAudioSessionRouteChange,
                                                                                 object: nil,
                                                                                 queue: OperationQueue.main,
                                                                                 using: { (notification) in
                                                                                    AudioKit.restartEngineAfterRouteChange(notification)
                })
                notificationObservers.append(routeChangeObserver)

            }

            if AKSettings.enableCategoryChangeHandling {
                let configurationChangeObserver = NotificationCenter.default.addObserver(forName: .AVAudioEngineConfigurationChange,
                                                                                         object: engine,
                                                                                         queue: OperationQueue.main,
                                                                                         using: { (notification) in
                                                                                            AudioKit.restartEngineAfterConfigurationChange(notification)
                })
                notificationObservers.append(configurationChangeObserver)
            }
            try updateSessionCategoryAndOptions()
            try AVAudioSession.sharedInstance().setActive(true)
        #endif

        try AKTry {
            try engine.start()
        }
        shouldBeRunning = true
    }

    @objc fileprivate static func updateSessionCategoryAndOptions() throws {
        #if !os(macOS)
            let sessionCategory = AKSettings.computedSessionCategory()

            #if os(iOS)
                let sessionOptions = AKSettings.computedSessionOptions()
                try AKSettings.setSession(category: sessionCategory,
                                          with: sessionOptions)
            #elseif os(tvOS)
                try AKSettings.setSession(category: sessionCategory)
            #endif
        #endif
    }

    /// Stop the audio engine
    @objc open static func stop() throws {
        // Stop the engine.
        try AKTry {
            engine.stop()
        }
        shouldBeRunning = false

        #if os(iOS)
        notificationObservers.forEach { (observer) in
            NotificationCenter.default.removeObserver(observer)
        }

        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            AKLog("couldn't stop session \(error)")
            throw error
        }
        #endif
    }


    // MARK: - Configuration Change Response

    // Listen to changes in audio configuration
    // and restart the audio engine if it stops and should be playing
    @objc fileprivate static func restartEngineAfterConfigurationChange(_ notification: Notification) {
        do {
            if shouldBeRunning && !engine.isRunning {
                #if !os(macOS)
                    let appIsNotActive = UIApplication.shared.applicationState != .active
                    let appDoesNotSupportBackgroundAudio = !AKSettings.appSupportsBackgroundAudio

                    if appIsNotActive && appDoesNotSupportBackgroundAudio {
                        AKLog("engine not restarted after configuration change since app was not active and does not support background audio")
                        return
                    }
                #endif

                try engine.start()

                // Sends notification after restarting the engine, so it is safe to resume AudioKit functions.
                if AKSettings.notificationsEnabled {
                    NotificationCenter.default.post(
                        name: .AKEngineRestartedAfterConfigurationChange,
                        object: nil,
                        userInfo: notification.userInfo)
                }
            }
        } catch {
            AKLog("error restarting engine after route change")
            // Note: doesn't throw since this is called from a notification observer
        }
    }

    // Restarts the engine after audio output has been changed, like headphones plugged in.
    @objc fileprivate static func restartEngineAfterRouteChange(_ notification: Notification) {
        if shouldBeRunning && !engine.isRunning {
            do {
                #if !os(macOS)
                    let appIsNotActive = UIApplication.shared.applicationState != .active
                    let appDoesNotSupportBackgroundAudio = !AKSettings.appSupportsBackgroundAudio

                    if appIsNotActive && appDoesNotSupportBackgroundAudio {
                        AKLog("engine not restarted after route change since app was not active and does not support background audio")
                        return
                    }
                #endif

                try engine.start()

                // Sends notification after restarting the engine, so it is safe to resume AudioKit functions.
                if AKSettings.notificationsEnabled {
                    NotificationCenter.default.post(
                        name: .AKEngineRestartedAfterRouteChange,
                        object: nil,
                        userInfo: notification.userInfo)
                }
            } catch {
                AKLog("error restarting engine after route change")
                // Note: doesn't throw since this is called from a notification observer
            }
        }
    }

    // MARK: - Disconnect node inputs

    /// Disconnect all inputs
    @objc open static func disconnectAllInputs() {
        engine.disconnectNodeInput(finalMixer.avAudioNode)
    }

    // MARK: - Deinitialization

    deinit {
        #if os(iOS)
            NotificationCenter.default.removeObserver(
                self,
                name: .AKEngineRestartedAfterRouteChange,
                object: nil)
        #endif
    }
}
