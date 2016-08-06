//
//  AKDryWetMixer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2016 AudioKit. All rights reserved.
//

import Foundation
import AVFoundation

/// Balanceable Mix between two signals, usually used for a dry signal and wet signal
///
/// - Parameters:
///   - dry: Dry Input (or just input 1)
///   - wet: Wet Input (or just input 2)
///   - balance: Balance Point (0 = all dry, 1 = all wet)
///
public class AKDryWetMixer: AKNode {
    private let mixer = AKMixer()

    /// Balance (Default 0.5)
    public var balance: Double = 0.5 {
        didSet {
            if balance < 0 {
                balance = 0
            }
            if balance > 1 {
                balance = 1
            }
            dryGain?.volume = 1 - balance
            wetGain?.volume = balance
        }
    }

    private var dryGain: AKMixer?
    private var wetGain: AKMixer?

    /// Tells whether the node is processing (ie. started, playing, or active)
    public var isStarted = true

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
