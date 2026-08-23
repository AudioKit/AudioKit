// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

extension AVAudioNode {
    /// Accesses `auAudioUnit` when building for a macOS 11 deployment target.
    ///
    /// Xcode 27 marks the Swift property as macOS 13+, so macOS 11–12 use the Objective-C
    /// selector. The local autorelease pool prevents that call from extending the audio unit's
    /// lifetime.
    var audioKitAudioUnit: AUAudioUnit {
        #if os(macOS)
            if #available(macOS 13, *) {
                return auAudioUnit
            }
            return autoreleasepool {
                let selector = NSSelectorFromString("AUAudioUnit")
                guard responds(to: selector),
                    let result = perform(selector),
                    let audioUnit = result.takeUnretainedValue() as? AUAudioUnit
                else {
                    fatalError("Expected AVAudioNode to provide an AUAudioUnit.")
                }
                return audioUnit
            }
        #else
            return auAudioUnit
        #endif
    }
}
