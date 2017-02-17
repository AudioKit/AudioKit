//
//  AKClipper.swift
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

/// Clips a signal to a predefined limit, in a "soft" manner, using one of three
/// methods.
///
open class AKClipper: AKNode, AKToggleable, AKComponent {
    public typealias AKAudioUnitType = AKClipperAudioUnit
    public static let ComponentDescription = AudioComponentDescription(effect: "clip")

    // MARK: - Properties

    private var internalAU: AKAudioUnitType?
    private var token: AUParameterObserverToken?

    fileprivate var limitParameter: AUParameter?

    /// Ramp Time represents the speed at which parameters are allowed to change
    open var rampTime: Double = AKSettings.rampTime {
        willSet {
            internalAU?.rampTime = newValue
        }
    }

    /// Threshold / limiting value.
    open var limit: Double = 1.0 {
        willSet {
            if limit != newValue {
                if internalAU!.isSetUp() {
                    limitParameter?.setValue(Float(newValue), originator: token!)
                } else {
                    internalAU?.limit = Float(newValue)
                }
            }
        }
    }

    /// Tells whether the node is processing (ie. started, playing, or active)
    open var isStarted: Bool {
        return internalAU!.isPlaying()
    }

    // MARK: - Initialization

    /// Initialize this clipper node
    ///
    /// - Parameters:
    ///   - input: Input node to process
    ///   - limit: Threshold / limiting value.
    ///
    public init(
        _ input: AKNode,
        limit: Double = 1.0) {

        self.limit = limit

        _Self.register()

        super.init()
        AVAudioUnit._instantiate(with: _Self.ComponentDescription) { [weak self] in
            self?.avAudioNode = $0
            self?.internalAU = $0.auAudioUnit as? AKAudioUnitType

            input.addConnectionPoint(self!)
        }

                guard let tree = internalAU?.parameterTree else {
            return
        }

        limitParameter = tree["limit"]

        token = tree.token (byAddingParameterObserver: { [weak self] address, value in

            DispatchQueue.main.async {
                if address == self?.limitParameter!.address {
                    self?.limit = Double(value)
                }
            }
        })

        internalAU?.limit = Float(limit)
    }

    // MARK: - Control

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        internalAU?.start()
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        internalAU?.stop()
    }
}
