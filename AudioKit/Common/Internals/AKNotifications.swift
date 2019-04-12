//
//  AKNotifications.swift
//  AudioKit
//
//  Created by John Groenhof, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Object to handle notifications for events that can affect the audio

extension Notification.Name {
    /// After the audio route is changed, (headphones plugged in, for example) AudioKit restarts,
    ///  and engineRestartAfterRouteChange is sent.
    ///
    /// The userInfo dictionary of this notification contains the AVAudioSessionRouteChangeReasonKey
    ///  and AVAudioSessionSilenceSecondaryAudioHintTypeKey keys, which provide information about the route change.
    ///
    public static let AKEngineRestartedAfterRouteChange =
      Notification.Name(rawValue: "io.audiokit.enginerestartedafterroutechange")

    /// After the audio engine configuration is changed, (change in input or output hardware's channel count or
    /// sample rate, for example) AudioKit restarts, and engineRestartAfterCategoryChange is sent.
    ///
    /// The userInfo dictionary of this notification is the same as the originating
    /// AVAudioEngineConfigurationChange notification's userInfo.
    ///
    public static let AKEngineRestartedAfterConfigurationChange =
        Notification.Name(rawValue: "io.audiokit.enginerestartedafterconfigurationchange")

}
