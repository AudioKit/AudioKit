//
//  AKRMS.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import Foundation

/// Tap to do basic amplitude analysis on any node
open class AKAmplitudeTap {
    internal let bufferSize: UInt32 = 1_024

    /// Intialize the ampltiude tap
    ///
    /// - parameter input: Node to analyze
    ///
    public init(_ input: AKNode) {
        input.avAudioNode.installTap(onBus: 0, bufferSize: bufferSize, format: AudioKit.format) {
            (buffer, _) in

            var sum: Float = 0

            // do a quick calc from the buffer values
            for i in 0 ..< Int(self.bufferSize) {
                sum += pow(Float((buffer.floatChannelData?.pointee[i])!), 2)
            }
        }
    }
}
