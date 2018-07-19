//
//  AudioKit+StartStop.swift
//  AudioKit
//
//  Created by Jeff Cooper on 4/20/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import Foundation
#if !os(macOS)
import UIKit
#endif

extension AudioKit {

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
        try updateSessionCategoryAndOptions()
        try AVAudioSession.sharedInstance().setActive(true)

        /// Notification observers

        // Subscribe to route changes that may affect our engine
        // Automatic handling of this change can be disabled via AKSettings.enableRouteChangeHandling
        NotificationCenter.default.removeObserver(self, name: .AVAudioSessionRouteChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(restartEngineAfterRouteChange), name: .AVAudioSessionRouteChange, object: nil)

        // Subscribe to session/configuration changes to our engine
        // Automatic handling of this change can be disabled via AKSettings.enableCategoryChangeHandling
        NotificationCenter.default.removeObserver(self, name: .AVAudioEngineConfigurationChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(restartEngineAfterConfigurationChange), name: .AVAudioEngineConfigurationChange, object: nil)
        #endif

        try AKTry {
            try engine.start()
        }
        shouldBeRunning = true
    }

    @objc internal static func updateSessionCategoryAndOptions() throws {
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
        do {
            NotificationCenter.default.removeObserver(self, name: .AVAudioSessionRouteChange, object: nil)
            NotificationCenter.default.removeObserver(self, name: .AVAudioEngineConfigurationChange, object: nil)
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
        // Notifications aren't guaranteed to be on the main thread
        let checkRestart = {
            do {
                // By checking the notification sender in this block rather than during observer configuration we avoid needing to create a new observer if the engine somehow changes
                guard let notifyingEngine = notification.object as? AVAudioEngine, notifyingEngine == engine else {
                    return
                }

                if AKSettings.enableCategoryChangeHandling && !engine.isRunning && shouldBeRunning {

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
        if Thread.isMainThread {
            checkRestart()
        } else {
            DispatchQueue.main.async(execute: checkRestart)
        }
    }

    // Restarts the engine after audio output has been changed, like headphones plugged in.
    @objc fileprivate static func restartEngineAfterRouteChange(_ notification: Notification) {
        // Notifications aren't guaranteed to come in on the main thread

        let checkRestart = {

            if AKSettings.enableRouteChangeHandling && shouldBeRunning && !engine.isRunning {
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
        if Thread.isMainThread {
            checkRestart()
        } else {
            DispatchQueue.main.async(execute: checkRestart)
        }
    }
}
