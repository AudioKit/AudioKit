//
//  AKTester.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Testing node
open class AKTester: AKNode, AKToggleable, AKComponent, AKInput {
    public typealias AKAudioUnitType = AKTesterAudioUnit
    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(effect: "tstr")

    // MARK: - Properties

    fileprivate var internalAU: AKAudioUnitType?
    fileprivate var testedNode: AKToggleable?
    fileprivate var token: AUParameterObserverToken?
    var totalSamples = 0

    /// Calculate the MD5
    open var MD5: String {
        return internalAU?.md5 ?? ""
    }

    /// Flag on whether or not the test is still in progress
    open var isStarted: Bool {
        if let samplesIn = internalAU?.samples {
            return Int(samplesIn) < totalSamples
        } else {
            return false
        }
    }

    // MARK: - Initializers

    /// Initialize this test node
    ///
    /// - Parameters:
    ///   - input: AKNode to test
    ///   - samples: Number of samples to produce
    ///
    @objc public init(_ input: AKNode?, samples: Int) {

        testedNode = input as? AKToggleable
        totalSamples = samples

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] avAudioUnit in

            self?.avAudioNode = avAudioUnit
            self?.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType

            input?.connect(to: self!)
            self?.internalAU?.samples = Int32(samples)
        }
    }

    /// Function to start, play, or activate the node, all do the same thing
    @objc open func start() {
        testedNode?.start()
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    @objc open func stop() {
        internalAU?.stop()
    }
}
