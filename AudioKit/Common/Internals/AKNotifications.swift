//
//  AKNotifications.swift
//  AudioKit
//
//  Created by John Groenhof, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Object to handle notifications for events that can affect the audio

extension NSNotification.Name {
    /// After the audio route is changed, (headphones plugged in, for example) AudioKit restarts,
    ///  and engineRestartAfterRouteChange is sent.
    /// 
    /// The userInfo dictionary of this notification contains the AVAudioSessionRouteChangeReasonKey
    ///  and AVAudioSessionSilenceSecondaryAudioHintTypeKey keys, which provide information about the route change.
    ///
    public static let AKEngineRestartedAfterRouteChange =
      NSNotification.Name(rawValue: "io.audiokit.enginerestartedafterroutechange")
}
