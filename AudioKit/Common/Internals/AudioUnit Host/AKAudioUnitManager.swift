//
//  AKAudioUnitManager.swift
//  AudioKit
//
//  Created by Ryan Francesconi, revision history on Github.
//  Copyright © 2017 Ryan Francesconi. All rights reserved.
//
import AVFoundation

extension Notification.Name {
    static let ComponentRegistrationsChanged = Notification.Name(rawValue: kAudioComponentRegistrationsChangedNotification as String)

    static let ComponentInstanceInvalidation = Notification.Name(rawValue: kAudioComponentInstanceInvalidationNotification as String)

}

/// Audio Unit Manager
open class AKAudioUnitManager: NSObject {
    static let ComponentDescription = AudioComponentDescription(type: kAudioUnitType_MusicDevice, subType: 0)

    /// All possible types of notifications this class may generate
    public enum Notification {
        case effectsAvailable, instrumentsAvailable, changed, crashed, added
    }

    // not including the Apple ones, only the custom ones
    public private (set) var internalAudioUnits = ["AKVariableDelay", "AKBitCrusher", "AKClipper",
                                                   "AKDynamicRangeCompressor", "AKDynaRageCompressor", "AKAmplitudeEnvelope", "AKTremolo",
                                                   "AKAutoWah", "AKBandPassButterworthFilter", "AKBandRejectButterworthFilter", "AKDCBlock",
                                                   "AKEqualizerFilter", "AKFormantFilter", "AKHighPassButterworthFilter",
                                                   "AKHighShelfParametricEqualizerFilter", "AKKorgLowPassFilter",
                                                   "AKLowPassButterworthFilter", "AKLowShelfParametricEqualizerFilter", "AKModalResonanceFilter",
                                                   "AKMoogLadder", "AKPeakingParametricEqualizerFilter", "AKResonantFilter", "AKRolandTB303Filter",
                                                   "AKStringResonator", "AKThreePoleLowpassFilter", "AKToneComplementFilter", "AKToneFilter",
                                                   "AKRhinoGuitarProcessor", "AKPhaser", "AKPitchShifter",
                                                   "AKChowningReverb", "AKCombFilterReverb", "AKCostelloReverb",
                                                   "AKFlatFrequencyResponseReverb", "AKZitaReverb", "AKBooster", "AKBooster2",
                                                   "AKTanhDistortion"]    //"AKRingModulator",

    /// Delegate that will be sent notifications
    open weak var delegate: AKAudioUnitManagerDelegate?

    /// first node in chain, generally a player or instrument
    open var input: AKNode?

    /// last node in chain, generally a mixer or some kind of output
    open var output: AKNode?

    // Serializes all access to `availableEffects`.
    private let availableEffectsAccessQueue = DispatchQueue(label: "AKAudioUnitManager.availableEffectsAccessQueue")

    // List of available audio unit components.
    private var _availableEffects = [AVAudioUnitComponent]()

    // Serializes all access to `_availableInstruments`.
    private let availableInstrumentsAccessQueue = DispatchQueue(label: "AKAudioUnitManager.availableInstrumentsAccessQueue")

    // List of available audio unit components.
    private var _availableInstruments = [AVAudioUnitComponent]()

    private var _effectsChain = [AVAudioUnit?](repeating: nil, count: 6)

    /// Effects Chain
    public var effectsChain: [AVAudioUnit?] {
        get {
            return _effectsChain
        }

        set {
            guard newValue.count == _effectsChain.count else {
                AKLog("number of newValues doesnt match number of inserts")
                return
            }

            var unitsCreated: Int = 0

            for i in 0 ..< newValue.count {
                if _effectsChain[i] != newValue[i] {
                    if newValue[i] == nil {
                        unitsCreated += 1
                        removeEffect(at: i, reconnectChain: false)
                        continue
                    }

                    if let acd = newValue[i]?.audioComponentDescription {
                        createEffectAudioUnit(acd) { au in
                            unitsCreated += 1
                            self._effectsChain[i] = au
                        }
                    }
                } else {
                    unitsCreated += 1
                }

                if unitsCreated == _effectsChain.count {
                    self.connectEffects()
                }
            }
        }
    }

    // just get a non nil list of Audio Units
    private var linkedEffects: [AVAudioUnit] {
        return _effectsChain.flatMap { $0 }
    }

    /// How many effects are active
    public var effectsCount: Int {
        return linkedEffects.count
    }

    /// `availableEffects` is accessed from multiple thread contexts. Use a dispatch queue for synchronization.
    public var availableEffects: [AVAudioUnitComponent] {
        get {
            return availableEffectsAccessQueue.sync {
                self._availableEffects
            }
        }

        set {
            availableEffectsAccessQueue.sync {
                self._availableEffects = newValue
            }
        }
    }

    /// `availableEffects` is accessed from multiple thread contexts. Use a dispatch queue for synchronization.
    public var availableInstruments: [AVAudioUnitComponent] {
        get {
            return availableInstrumentsAccessQueue.sync {
                 self._availableInstruments
            }
        }

        set {
            availableInstrumentsAccessQueue.sync {
                self._availableInstruments = newValue
            }
        }
    }

    /// Initialize the manager with arbritary amount of inserts
    public convenience init(inserts: Int) {
        self.init()
        _effectsChain = [AVAudioUnit?](repeating: nil, count: inserts)
    }

    /// Initialize the manager
    override public init() {
        super.init()

        internalAudioUnits.sort()

        // Sign up for a notification when the list of available components changes.
        NotificationCenter.default.addObserver(forName: .ComponentRegistrationsChanged, object: nil, queue: nil) { [weak self] _ in

            guard let strongSelf = self else {
                AKLog("Unable to create strong ref to self")
                return
            }

            AKLog("* Audio Units available changed *")

            strongSelf.delegate?.handleAudioUnitNotification(type: .changed, object: nil)

        }

        //TODO: This might not be working?
        // Sign up for a notification when an audio unit crashes. Note that we handle this on the main queue for thread-safety.

        NotificationCenter.default.addObserver(forName: .ComponentInstanceInvalidation, object: nil, queue: nil) { [weak self] notification in
            guard let strongSelf = self else {
                AKLog("Unable to create strong ref to self")
                return
            }

            //TODO: remove from signal chain
            let crashedAU = notification.object as? AUAudioUnit

            AKLog("Audio Unit Crashed: \(crashedAU.debugDescription)")

            strongSelf.delegate?.handleAudioUnitNotification(type: .crashed, object: crashedAU)
        }
    }

    /// request a list of Effects, will be returned async
    public func requestEffects(completionHandler: (([AVAudioUnitComponent]) -> Void)? = nil) {
        updateEffectsList {
            completionHandler?(self.availableEffects)
        }
    }

    private func updateEffectsList( completionHandler: (() -> Void)? = nil) {
        //Locating components can be a little slow, especially the first time.
        //Do this work on a separate dispatch thread.
        DispatchQueue.global(qos: .default).async {
            /// Predicate will return all types of effects including kAudioUnitType_Effect and kAudioUnitType_MusicEffect
            /// which are the ones that we care about here
            let predicate = NSPredicate(format: "typeName CONTAINS 'Effect'", argumentArray: [])
            self.availableEffects = AVAudioUnitComponentManager.shared().components(matching: predicate)

            self.availableEffects = self.availableEffects.sorted {
                return $0.name < $1.name
            }

            // Let the UI know that we have an updated list of units.
            DispatchQueue.main.async {
                // notify delegate
                self.delegate?.handleAudioUnitNotification(type: .effectsAvailable,
                                                           object: self.availableEffects)
                completionHandler?()

            }
        }
    }

    /// request a list of Instruments, will be returned async
    public func requestInstruments(completionHandler: (([AVAudioUnitComponent]) -> Void)? = nil) {
        updateInstrumentsList {
            completionHandler?(self.availableInstruments)
        }
    }

    private func updateInstrumentsList( completionHandler: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .default).async {
            /*
             Locating components can be a little slow, especially the first time.
             Do this work on a separate dispatch thread.

             Make a component description matching any AU of the type.
             */


            self.availableInstruments = AVAudioUnitComponentManager.shared().components(matching: AKAudioUnitManager.ComponentDescription)

            // Let the UI know that we have an updated list of units.
            DispatchQueue.main.async {
                // notify delegate

                self.delegate?.handleAudioUnitNotification(type: .instrumentsAvailable,
                                                           object: self.availableInstruments)

                completionHandler?()

            } // dispatch main
        } //dispatch global
    }

    /*
     Asynchronously create the AU, then call the
     supplied completion handler when the operation is complete.
     */
    public func createEffectAudioUnit(_ componentDescription: AudioComponentDescription,
                                      completionHandler: @escaping ((AVAudioUnit?) -> Void)) {

        AVAudioUnitEffect.instantiate(with: componentDescription, options: .loadOutOfProcess) { avAudioUnit, _ in
            guard let avAudioUnit = avAudioUnit else {
                completionHandler(nil)
                return
            }
            completionHandler(avAudioUnit)
        }
    }

    /*
     Asynchronously create the AU, then call the
     supplied completion handler when the operation is complete.
     */
    public func createInstrumentAudioUnit(_ componentDescription: AudioComponentDescription,
                                          completionHandler: @escaping ((AVAudioUnitMIDIInstrument?) -> Void)) {
        AVAudioUnitMIDIInstrument.instantiate(with: componentDescription, options: .loadOutOfProcess) { avAudioUnit, _ in
            guard let avAudioUnit = avAudioUnit else {
                completionHandler(nil)
                return
            }
            completionHandler(avAudioUnit as? AVAudioUnitMIDIInstrument)
        }
    }

    public func removeEffect(at index: Int, reconnectChain: Bool = true) {

        if let au = _effectsChain[index] {
            AKLog("removeEffect: \(au.auAudioUnit.audioUnitName ?? "")")

            if au.engine != nil {
                AudioKit.engine.disconnectNodeInput(au)
                AudioKit.engine.detach(au)
            }
        }
        _effectsChain[index] = nil

        if reconnectChain {
            connectEffects()
        }

        self.delegate?.handleEffectRemoved(at: index)
    }

    // Create the Audio Unit at the specified index of the chain
    public func insertAudioUnit(name: String, at index: Int) {
        guard _effectsChain.indices.contains(index) else { return }

        if let component = (availableEffects.first { $0.name == name }) {
            let acd = component.audioComponentDescription

            AKLog("#\(index) \(name) -- \(acd)")

            createEffectAudioUnit(acd) { au in
                guard let audioUnit = au else {
                    AKLog("Unable to create audioUnit")
                    return
                }

                if audioUnit.inputFormat(forBus: 0).channelCount == 1 {
                    // Dialog.showInformation(title: "Mono Effects aren't supported",
                    //                        text: "\(audioUnit.name) is a Mono effect. Please select a stereo version of it.")
                    // return
                    // TODO: handle this better
                    //AKLog("Warning: \(audioUnit.name) is a Mono effect.")
                }

                //Swift.print("* \(audioUnit.name) : Audio Unit created, version: \(audioUnit)")

                self._effectsChain[index] = audioUnit
                self.connectEffects()
                self.delegate?.handleEffectAdded(at: index)
            }
        }

        // if it didn't find it in the component list, see if it's an internal one
        else if let avUnit = createInternalAU(name: name) {

            self._effectsChain[index] = avUnit
            self.connectEffects()
            self.delegate?.handleEffectAdded(at: index)
        }
    }

    private func createInternalAU(name: String) -> AVAudioUnit? {
        // how does this crap work?
        //        let instance = NSClassFromString(name) as! AKNode.Type
        //        if let av = instance.init().avAudioNode as? AVAudioUnit {
        //            return av
        //        }
        var avUnit: AVAudioUnit?

        // in the meantime:
        if name == "AKVariableDelay" {
            avUnit = AKVariableDelay().avAudioNode as? AVAudioUnit
        } else if name == "AKBitCrusher" {
            avUnit = AKBitCrusher().avAudioNode as? AVAudioUnit
        } else if name == "AKClipper" {
            avUnit = AKClipper().avAudioNode as? AVAudioUnit
        } else if name == "AKRingModulator" {
            avUnit = AKRingModulator().avAudioNode as? AVAudioUnit
        } else if name == "AKDynamicRangeCompressor" {
            avUnit = AKDynamicRangeCompressor().avAudioNode as? AVAudioUnit
        } else if name == "AKDynaRageCompressor" {
            avUnit = AKDynaRageCompressor().avAudioNode as? AVAudioUnit
        } else if name == "AKAmplitudeEnvelope" {
            avUnit = AKAmplitudeEnvelope().avAudioNode as? AVAudioUnit
        } else if name == "AKTremolo" {
            avUnit = AKTremolo().avAudioNode as? AVAudioUnit
        } else if name == "AKAutoWah" {
            avUnit = AKAutoWah().avAudioNode as? AVAudioUnit
        } else if name == "AKBandPassButterworthFilter" {
            avUnit = AKBandPassButterworthFilter().avAudioNode as? AVAudioUnit
        } else if name == "AKBandRejectButterworthFilter" {
            avUnit = AKBandRejectButterworthFilter().avAudioNode as? AVAudioUnit
        } else if name == "AKDCBlock" {
            avUnit = AKDCBlock().avAudioNode as? AVAudioUnit
        } else if name == "AKEqualizerFilter" {
            avUnit = AKEqualizerFilter().avAudioNode as? AVAudioUnit
        } else if name == "AKFormantFilter" {
            avUnit = AKFormantFilter().avAudioNode as? AVAudioUnit
        } else if name == "AKHighPassButterworthFilter" {
            avUnit = AKHighPassButterworthFilter().avAudioNode as? AVAudioUnit
        } else if name == "AKHighShelfParametricEqualizerFilter" {
            avUnit = AKHighShelfParametricEqualizerFilter().avAudioNode as? AVAudioUnit
        } else if name == "AKKorgLowPassFilter" {
            avUnit = AKKorgLowPassFilter().avAudioNode as? AVAudioUnit
        } else if name == "AKLowPassButterworthFilter" {
            avUnit = AKLowPassButterworthFilter().avAudioNode as? AVAudioUnit
        } else if name == "AKLowShelfParametricEqualizerFilter" {
            avUnit = AKLowShelfParametricEqualizerFilter().avAudioNode as? AVAudioUnit
        } else if name == "AKModalResonanceFilter" {
            avUnit = AKModalResonanceFilter().avAudioNode as? AVAudioUnit
        } else if name == "AKMoogLadder" {
            avUnit = AKMoogLadder().avAudioNode as? AVAudioUnit
        } else if name == "AKPeakingParametricEqualizerFilter" {
            avUnit = AKPeakingParametricEqualizerFilter().avAudioNode as? AVAudioUnit
        } else if name == "AKResonantFilter" {
            avUnit = AKResonantFilter().avAudioNode as? AVAudioUnit
        } else if name == "AKRolandTB303Filter" {
            avUnit = AKRolandTB303Filter().avAudioNode as? AVAudioUnit
        } else if name == "AKStringResonator" {
            avUnit = AKStringResonator().avAudioNode as? AVAudioUnit
        } else if name == "AKThreePoleLowpassFilter" {
            avUnit = AKThreePoleLowpassFilter().avAudioNode as? AVAudioUnit
        } else if name == "AKToneComplementFilter" {
            avUnit = AKToneComplementFilter().avAudioNode as? AVAudioUnit
        } else if name == "AKToneFilter" {
            avUnit = AKToneFilter().avAudioNode as? AVAudioUnit
        } else if name == "AKRhinoGuitarProcessor" {
            avUnit = AKRhinoGuitarProcessor().avAudioNode as? AVAudioUnit
        } else if name == "AKPhaser" {
            avUnit = AKPhaser().avAudioNode as? AVAudioUnit
        } else if name == "AKPitchShifter" {
            avUnit = AKPitchShifter().avAudioNode as? AVAudioUnit
        } else if name == "AKChowningReverb" {
            avUnit = AKChowningReverb().avAudioNode as? AVAudioUnit
        } else if name == "AKCombFilterReverb" {
            avUnit = AKCombFilterReverb().avAudioNode as? AVAudioUnit
        } else if name == "AKCostelloReverb" {
            avUnit = AKCostelloReverb().avAudioNode as? AVAudioUnit
        } else if name == "AKFlatFrequencyResponseReverb" {
            avUnit = AKFlatFrequencyResponseReverb().avAudioNode as? AVAudioUnit
        } else if name == "AKZitaReverb" {
            avUnit = AKZitaReverb().avAudioNode as? AVAudioUnit
        } else if name == "AKBooster" {
            avUnit = AKBooster().avAudioNode as? AVAudioUnit
        } else if name == "AKBooster2" {
            avUnit = AKBooster().avAudioNode as? AVAudioUnit
        } else if name == "AKTanhDistortion" {
            avUnit = AKTanhDistortion().avAudioNode as? AVAudioUnit
        }
        // requires an impulse response...
        //            } else if name == "AKConvolution" {
        //                avUnit = AKConvolution().avAudioNode as? AVAudioUnit

        return avUnit
    }

    /// Create an instrument with a name and a completion handler
    public func createInstrument(name: String, completionHandler: ((AVAudioUnitMIDIInstrument?) -> Void)? = nil) {
        guard let desc = (availableInstruments.first { $0.name == name })?.audioComponentDescription else { return }
        createInstrumentAudioUnit(desc) { au in
            guard let audioUnit = au else {
                AKLog("Unable to create audioUnit")
                return
            }

            completionHandler?(audioUnit)
        }
    }

    /// Reset all effects
    open func resetEffects() {
        for i in 0 ..< _effectsChain.count {
            if let au = _effectsChain[i] {
                //AKLog("Detaching: \(au.auAudioUnit.audioUnitName)")

                if au.engine != nil {
                    AudioKit.engine.disconnectNodeInput(au)
                    AudioKit.engine.detach(au)
                }

                _effectsChain[i] = nil
            }
        }
    }

    /// called from client to hook the chain together
    /// firstNode would be something like a player, and last something like a mixer that's headed
    /// to the output.
    open func connectEffects( firstNode: AKNode? = nil, lastNode: AKNode? = nil) {
        if firstNode != nil {
            self.input = firstNode
        }

        if lastNode != nil {
            self.output = lastNode
        }

        guard self.input != nil else {
            AKLog("input is nil")
            return
        }
        guard self.output != nil else {
            AKLog("output is nil")
            return
        }

        // it's an effects sandwich
        let inputAV = self.input!.avAudioNode
        let effects = linkedEffects
        let outputAV = self.output!.avAudioNode

        let processingFormat = inputAV.outputFormat(forBus: 0)
        AKLog("\(effects.count) to connect... chain source format: \(processingFormat)")

        if effects.count == 0 {
            AudioKit.connect(inputAV, to: outputAV, format: processingFormat)
            return
        }
        var au = effects[0]

        AudioKit.connect(inputAV, to: au, format: processingFormat)

        if effects.count > 1 {
            for i in 1 ..< effects.count {
                au = effects[i]
                let prevAU = effects[i - 1]

                AudioKit.connect(prevAU, to: au, format: processingFormat)

                //AKLog("Connecting \(prevAU.name) to \(au.name) with format \(processingFormat)")
            }
        }

        //AKLog("Connecting \(au.name) to output: \(outputAV),  with format \(processingFormat)")
        AudioKit.connect(au, to: outputAV, format: processingFormat)

    }

    /// resets the processing state and clears the buffers in the AUs
    public func reset() {
        for aunit in linkedEffects {
            aunit.reset()
        }
    }

    /// Testing
    private func initAudioUnitFactoryPreset(_ au: AVAudioUnit ) {
        guard let presets = au.auAudioUnit.factoryPresets else { return }
        for p in presets {
            Swift.print("Factory Preset: \(p.name) \(p.number)")
        }

        presets.first.map {
            Swift.print("Setting Preset: \($0.name) \($0.number)")
            au.auAudioUnit.currentPreset = $0
        }
    }

}

public protocol AKAudioUnitManagerDelegate: class {
    func handleAudioUnitNotification(type: AKAudioUnitManager.Notification, object: Any?)
    func handleEffectAdded(at auIndex: Int)

    /// If your UI needs to handle an effect being removed
    func handleEffectRemoved(at auIndex: Int)
}
