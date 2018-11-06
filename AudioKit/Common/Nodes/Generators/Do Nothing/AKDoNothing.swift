//
//  AKDoNothing.swift
//  AudioKit
//
//  Created by Jeff Cooper, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

/// An alternative to AKSampler or AKAudioPlayer, AKDoNothing is a player that
/// doesn't rely on an as much Apple AV foundation/engine code as the others.
/// As any other Sampler, it plays a part of a given sound file at a specified rate
/// with specified volume. Changing the rate plays it faster and therefore sounds
/// higher or lower. Set rate to 2.0 to double playback speed and create an octave.
/// Give it a blast on `Sample Player.xcplaygroundpage`
import Foundation

/// Audio player that loads a sample into memory
open class AKDoNothing: AKPolyphonicNode, AKComponent {

    public typealias AKAudioUnitType = AKDoNothingAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "dont")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?

    open var callback: AKMIDICallback = { status, data1, data2 in } {
        willSet {
            internalAU?.callback = newValue
        }
    }
    // MARK: - Initialization

    @objc public override init() {

        _Self.register()

        super.init()

        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in
            guard let strongSelf = self else {
                AKLog("Error: self is nil")
                return
            }
            strongSelf.avAudioUnit = avAudioUnit
            strongSelf.avAudioNode = avAudioUnit
            self?.midiInstrument = avAudioUnit as? AVAudioUnitMIDIInstrument
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
        }

    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        internalAU?.stop()
    }

    deinit {
        internalAU?.destroy()
    }
}
