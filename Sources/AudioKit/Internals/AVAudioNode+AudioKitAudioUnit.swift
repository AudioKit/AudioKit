// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

extension AVAudioNode {
    /// `auAudioUnit`, reachable from a macOS 11 deployment target.
    ///
    /// Xcode 27's Swift overlay marks `AVAudioNode.auAudioUnit` as macOS 13+, although the
    /// Objective-C property is available from macOS 10.13. Use the property directly wherever the
    /// compiler allows it, and only fall back to the selector on macOS 11–12. The fallback runs
    /// inside its own autorelease pool: `perform(_:)` returns a +0 object that would otherwise sit
    /// in the caller's pool and keep the node's AVAudioUnit alive until that pool drains.
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
