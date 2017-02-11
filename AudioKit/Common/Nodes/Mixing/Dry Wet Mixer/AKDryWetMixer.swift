//
//  AKDryWetMixer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

import Foundation
import AVFoundation

/// Balanceable Mix between two signals, usually used for a dry signal and wet signal
///
open class AKDryWetMixer: AKNode {
    fileprivate let mixer = AKMixer()

    /// Balance (Default 0.5)
    open var balance: Double = 0.5 {
        didSet {
            balance = (0...1).clamp(balance)
            dryGain?.volume = 1 - balance
            wetGain?.volume = balance
        }
    }

    fileprivate var dryGain: AKMixer?
    fileprivate var wetGain: AKMixer?

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted = true

    /// Initialize this dry wet mixer node
    ///
    /// - Parameters:
    ///   - dry: Dry Input (or just input 1)
    ///   - wet: Wet Input (or just input 2)
    ///   - balance: Balance Point (0 = all dry, 1 = all wet)
    ///
    public init(_ dry: AKNode, _ wet: AKNode, balance: Double = 0.5) {

        self.balance = balance

        super.init()
        avAudioNode = mixer.avAudioNode

        dryGain = AKMixer(dry)
        dryGain!.volume = 1 - balance
        mixer.connect(dryGain!)

        wetGain = AKMixer(wet)
        wetGain!.volume = balance
        mixer.connect(wetGain!)
    }
}
