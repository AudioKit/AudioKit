//
//  AKNotifications.swift
//  AudioKit
//
//  Created by John Groenhof, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

import Foundation

/// Object to handle notifications for events that can affect the audio
@objc open class AKNotifications: NSObject {
    /// After the audio route is changed, (headphones plugged in, for example) AudioKit restarts,
    ///  and engineRestartAfterRouteChange is sent.
    /// 
    /// The userInfo dictionary of this notification contains the AVAudioSessionRouteChangeReasonKey
    ///  and AVAudioSessionSilenceSecondaryAudioHintTypeKey keys, which provide information about the route change.
    ///
    open static let engineRestartedAfterRouteChange: String = "io.audiokit.enginerestartedafterroutechange"
}
