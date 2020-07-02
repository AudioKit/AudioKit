// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

extension AKManager {

    /// Observes changes to AVAudioEngineConfigurationChange..
    private static var configChangeObserver: Any?

    /// Observer for AVAudioSession.routeChangeNotification
    private static var routeChangeObserver: Any?

    /// Start up the audio engine with periodic functions
    public static func start(withPeriodicFunctions functions: AKPeriodicFunction...) throws {
        // ensure that an output has been set previously
        guard let finalMixer = finalMixer else {
            AKLog("No output has been assigned yet.")
            return
        }

        for function in functions {
            function.connect(to: finalMixer)
        }
        try start()
    }

    /// Start up the audio engine
    @objc public static func start() throws {
        if output == nil {
            AKLog("No output node has been set yet, no processing will happen.")
        }
        // Start the engine.
        try AKTry {
            engine.prepare()
        }

        #if os(iOS)
        if !AKSettings.disableAVAudioSessionCategoryManagement {
            try updateSessionCategoryAndOptions()
            try AVAudioSession.sharedInstance().setActive(true)
        }

        /// Notification observers

        // Subscribe to route changes that may affect our engine
        // Automatic handling of this change can be disabled via AKSettings.enableRouteChangeHandling
        routeChangeObserver = NotificationCenter.default.addObserver(forName: AVAudioSession.routeChangeNotification,
                                                                     object: nil,
                                                                     queue: OperationQueue.main,
                                                                     using: restartEngineAfterRouteChange)
        #endif

        // Subscribe to session/configuration changes to our engine
        // Automatic handling of this change can be disabled via AKSettings.enableConfigurationChangeHandling
        configChangeObserver = NotificationCenter.default.addObserver(forName: .AVAudioEngineConfigurationChange,
                                                          object: engine,
                                                          queue: OperationQueue.main,
                                                          using: restartEngineAfterConfigurationChange)

        try AKTry {
            try engine.start()
            // Send AudioKit started and ready for connections notification.
            // If you listen this notification, you may not need the `shouldBeRunning` variable.
            if AKSettings.notificationsEnabled {
                NotificationCenter.default.post(
                    name: .AKEngineStarted,
                    object: nil,
                    userInfo: nil)
            }
        }
        shouldBeRunning = true
    }

    /// Stop the audio engine
    @objc public static func stop() throws {
        // Stop the engine.
        try AKTry {
            engine.stop()
        }
        shouldBeRunning = false

        #if os(iOS)
        do {
            if !AKSettings.disableAudioSessionDeactivationOnStop {
                try AVAudioSession.sharedInstance().setActive(false)
            }
        } catch {
            AKLog("couldn't stop session \(error)")
            throw error
        }
        #endif
    }

    @objc public static func shutdown() throws {
        engine = AVAudioEngine()
        finalMixer = nil
        output = nil
        shouldBeRunning = false
    }
}

extension AKManager {
    // MARK: - Configuration Change Response

    // Listen to changes in audio configuration
    // and restart the audio engine if it stops and should be playing
    fileprivate static func restartEngineAfterConfigurationChange(_ notification: Notification) {
        // Notifications aren't guaranteed to be on the main thread
        let attemptRestart = {
            do {
                // By checking the notification sender in this block rather than during observer configuration
                // we avoid needing to create a new observer if the engine somehow changes
                guard let notifyingEngine = notification.object as? AVAudioEngine, notifyingEngine == engine else {
                    return
                }

                if AKSettings.enableConfigurationChangeHandling, !engine.isRunning, shouldBeRunning {
                    #if os(iOS)
                    let appIsNotActive = UIApplication.shared.applicationState != .active
                    let appDoesNotSupportBackgroundAudio = !AKSettings.appSupportsBackgroundAudio

                    if appIsNotActive && appDoesNotSupportBackgroundAudio {
                        AKLog("engine not restarted after configuration change since app was not active " +
                            "and does not support background audio")
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
            attemptRestart()
        } else {
            DispatchQueue.main.async(execute: attemptRestart)
        }
    }
}

#if !os(macOS)
extension AKManager {
    @objc internal static func updateSessionCategoryAndOptions() throws {
        guard AKSettings.disableAVAudioSessionCategoryManagement == false else { return }

        let sessionCategory = AKSettings.computedSessionCategory()

        #if os(iOS)
        let sessionOptions = AKSettings.computedSessionOptions()
        try AKSettings.setSession(category: sessionCategory, with: sessionOptions)
        #elseif os(tvOS)
        try AKSettings.setSession(category: sessionCategory)
        #endif
    }

    // MARK: - Route Change Response

    // Restarts the engine after audio output has been changed, like headphones plugged in.
    fileprivate static func restartEngineAfterRouteChange(_ notification: Notification) {
        // Notifications aren't guaranteed to come in on the main thread

        let attemptRestart = {
            if AKSettings.enableRouteChangeHandling, shouldBeRunning, !engine.isRunning {
                do {
                    #if os(macOS)
                    let appIsNotActive = UIApplication.shared.applicationState != .active
                    let appDoesNotSupportBackgroundAudio = !AKSettings.appSupportsBackgroundAudio

                    if appIsNotActive && appDoesNotSupportBackgroundAudio {
                        AKLog("engine not restarted after configuration change since app was not active " +
                            "and does not support background audio")
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
            attemptRestart()
        } else {
            DispatchQueue.main.async(execute: attemptRestart)
        }
    }
}
#endif
