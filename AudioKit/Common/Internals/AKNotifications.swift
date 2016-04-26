//
//  AKNotifications.swift
//  AudioKit
//
//  Created by John Groenhof, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation

@objc public class AKNotifications: NSObject {
    /// After the audio route is changed, (headphones plugged in, for example) AudioKit restarts,
    ///  and engineRestartAfterRouteChange is sent.
    /// 
    /// The userInfo dictionary of this notification contains the AVAudioSessionRouteChangeReasonKey
    ///  and AVAudioSessionSilenceSecondaryAudioHintTypeKey keys, which provide information about the route change.
    ///
    public static let engineRestartedAfterRouteChange: String = "io.audiokit.enginerestartedafterroutechange"
}

