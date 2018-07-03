//
//  AKDryWetMixer.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// Balanceable Mix between two signals, usually used for a dry signal and wet signal
///
open class AKDryWetMixer: AKNode, AKInput {
    fileprivate let mixer = AKMixer()

    /// Balance (Default 0.5)
    @objc open dynamic var balance: Double = 0.5 {
        didSet {
            balance = (0...1).clamp(balance)
            dryGain.volume = 1 - balance
            wetGain.volume = balance
        }
    }

    fileprivate var dryGain = AKMixer()
    fileprivate var wetGain = AKMixer()

    /// Tells whether the node is processing (ie. started, playing, or active)
    @objc open dynamic var isStarted = true

    /// Initialize this dry wet mixer node
    ///
    /// - Parameters:
    ///   - dry: Dry Input (or just input 1)
    ///   - wet: Wet Input (or just input 2)
    ///   - balance: Balance Point (0 = all dry, 1 = all wet)
    ///
    @objc public init(_ dry: AKNode? = nil, _ wet: AKNode? = nil, balance: Double = 0.5) {

        self.balance = balance

        super.init()
        avAudioNode = mixer.avAudioNode

        dry?.connect(to: dryGain)
        dryGain.volume = 1 - balance
        dryGain.connect(to: mixer)

        wet?.connect(to: wetGain)
        wetGain.volume = balance
        wetGain.connect(to: mixer)
    }
    public var inputNode: AVAudioNode {
        return dryGain.avAudioNode
    }

    open var dryInput: AVAudioConnectionPoint {
        return AVAudioConnectionPoint(node: dryGain.avAudioNode, bus: 0)
    }
    open var wetInput: AVAudioConnectionPoint {
        return AVAudioConnectionPoint(node: wetGain.avAudioNode, bus: 0)
    }

    // Disconnect the node
    override open func disconnect() {
        AudioKit.detach(nodes: [mixer.avAudioNode, dryGain.avAudioNode, wetGain.avAudioNode])
    }

}
