//
//  DIYSeq.swift
//  AudioKit
//
//  Created by Jeff Cooper on 1/25/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

import Foundation

/// Audio player that loads a sample into memory
open class DIYSeq: AKNode, AKComponent {

    public typealias AKAudioUnitType = AKDIYSeqEngine

    /// Four letter unique description of the node
    public static let ComponentDescription = AudioComponentDescription(generator: "diys")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var startPointParameter: AUParameter?
    private var targetNode: AKNode?
    private var engine: AKDIYSeqEngine!

    /// Ramp Duration represents the speed at which parameters are allowed to change
    @objc open dynamic var rampDuration: Double = AKSettings.rampDuration {
        willSet {
            internalAU?.rampDuration = newValue
        }
    }

    /// startPoint in samples - where to start playing the sample from
    private var startPoint: Sample = 0

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
            strongSelf.internalAU = avAudioUnit.auAudioUnit as? AKAudioUnitType
        }

        guard let tree = internalAU?.parameterTree else {
            AKLog("Parameter Tree Failed")
            return
        }

        startPointParameter = tree["startPoint"]

        token = tree.token(byAddingParameterObserver: { [weak self] _, _ in

            if self == nil {
                AKLog("Unable to create strong reference to self")
                return
            } // Replace _ with strongSelf if needed
            DispatchQueue.main.async {
                // This node does not change its own values so we won't add any
                // value observing, but if you need to, this is where that goes.
            }
        })
    }

    @objc public convenience init(targetNode: AKNode) {
        self.init()
        setTarget(node: targetNode)
    }

    public func setTarget(node: AKNode) {
        targetNode = node
        internalAU?.setTarget(targetNode?.avAudioUnit?.audioUnit)
    }

    public func play() {
        internalAU?.start()
    }
}
