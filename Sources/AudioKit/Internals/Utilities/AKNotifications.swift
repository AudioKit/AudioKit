// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import Foundation

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

    /// After the audio session is changed, (example: setting session from .playback to .playAndRecord);
    /// we need to restart AudioKit but using engine.start() and adding some other players,
    /// connections can cause some crash because Audio Engine is not fully ready yet.
    ///
    /// This notification is giving the right time when AudioKit Engine is ready.
    ///
    public static let AKEngineStarted =
        Notification.Name(rawValue: "io.audiokit.engineStarted")
}
