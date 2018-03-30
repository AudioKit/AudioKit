//
//  AKAudioUnitManager.swift
//  AudioKit
//
//  Created by Ryan Francesconi, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

extension Notification.Name {
    static let ComponentRegistrationsChanged = Notification.Name(rawValue:
        kAudioComponentRegistrationsChangedNotification as String)
    static let ComponentInstanceInvalidation = Notification.Name(rawValue:
        kAudioComponentInstanceInvalidationNotification as String)
}

/// Audio Unit Manager
open class AKAudioUnitManager: NSObject {
    // static let ComponentDescription = AudioComponentDescription(type: kAudioUnitType_MusicDevice, subType: 0)

    /// The notifications this class may generate
    public enum Notification {
        case effectsAvailable, instrumentsAvailable, changed, crashed, added
    }

    /// Internal audio units not including the Apple ones, only the custom ones
    public private(set) var internalAudioUnits = ["AKVariableDelay",
                                                  "AKChorus",
                                                  "AKFlanger",
                                                  "AKBitCrusher",
                                                  "AKClipper",
                                                  "AKDynamicRangeCompressor",
                                                  "AKDynaRageCompressor",
                                                  "AKAmplitudeEnvelope",
                                                  "AKTremolo",
                                                  "AKAutoWah",
                                                  "AKBandPassButterworthFilter",
                                                  "AKBandRejectButterworthFilter",
                                                  "AKDCBlock",
                                                  "AKEqualizerFilter",
                                                  "AKFormantFilter",
                                                  "AKHighPassButterworthFilter",
                                                  "AKHighShelfParametricEqualizerFilter",
                                                  "AKKorgLowPassFilter",
                                                  "AKLowPassButterworthFilter",
                                                  "AKLowShelfParametricEqualizerFilter",
                                                  "AKModalResonanceFilter",
                                                  "AKMoogLadder",
                                                  "AKPeakingParametricEqualizerFilter",
                                                  "AKResonantFilter",
                                                  "AKRolandTB303Filter",
                                                  "AKStringResonator",
                                                  "AKThreePoleLowpassFilter",
                                                  "AKToneComplementFilter",
                                                  "AKToneFilter",
                                                  "AKRhinoGuitarProcessor",
                                                  "AKPhaser",
                                                  "AKPitchShifter",
                                                  "AKTimePitch",
                                                  "AKVariSpeed",
                                                  "AKChowningReverb",
                                                  "AKCombFilterReverb",
                                                  "AKCostelloReverb",
                                                  "AKFlatFrequencyResponseReverb",
                                                  "AKZitaReverb",
                                                  "AKBooster",
                                                  "AKTanhDistortion"]

    /// Callback definitions
    public typealias AKComponentListCallback = ([AVAudioUnitComponent]) -> Void
    public typealias AKEffectCallback = (AVAudioUnit?) -> Void
    public typealias AKInstrumentCallback = (AVAudioUnitMIDIInstrument?) -> Void

    /// Delegate that will be sent notifications
    open weak var delegate: AKAudioUnitManagerDelegate?

    /// first node in chain, generally a player or instrument
    open var input: AKNode?

    /// last node in chain, generally a mixer or some kind of output
    open var output: AKNode?

    // Serializes all access to `availableEffects`.
    private let availableEffectsAccessQueue = DispatchQueue(label:
        "AKAudioUnitManager.availableEffectsAccessQueue")

    // List of available audio unit components.
    private var _availableEffects = [AVAudioUnitComponent]()

    // Serializes all access to `_availableInstruments`.
    private let availableInstrumentsAccessQueue = DispatchQueue(label:
        "AKAudioUnitManager.availableInstrumentsAccessQueue")

    // List of available audio unit components.
    private var _availableInstruments = [AVAudioUnitComponent]()

    // Defaults to a chain of 6 effects
    private var _effectsChain = [AVAudioUnit?](repeating: nil, count: 6)

    /// Effects Chain
    public var effectsChain: [AVAudioUnit?] {
        get {
            return _effectsChain
        }

        set {
            guard newValue.count == _effectsChain.count else {
                AKLog("number of newValues doesn't match number of inserts")
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
                    connectEffects()
                }
            }
        }
    }

    // just get a non nil list of Audio Units
    private var linkedEffects: [AVAudioUnit] {
        return _effectsChain.compactMap { $0 }
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

    // MARK: - Initialization

    /// Initialize the manager with arbritary amount of inserts
    public convenience init(inserts: Int) {
        self.init()
        _effectsChain = [AVAudioUnit?](repeating: nil, count: inserts)
    }

    /// Initialize the manager
    public override init() {
        super.init()

        // regardless of how they're organized above, this'll sort them out
        internalAudioUnits.sort()

        // Sign up for a notification when the list of available components changes.
        NotificationCenter.default.addObserver(forName: .ComponentRegistrationsChanged,
                                               object: nil,
                                               queue: nil) { [weak self] _ in

            guard let strongSelf = self else {
                AKLog("Unable to create strong ref to self")
                return
            }
            AKLog("* Audio Units available changed *")

            strongSelf.delegate?.handleAudioUnitNotification(type: .changed, object: nil)

        }

        // TODO: This might not be working?
        // Sign up for a notification when an audio unit crashes. Note that we handle this on the
        // main queue for thread-safety.

        NotificationCenter.default.addObserver(forName: .ComponentInstanceInvalidation,
                                               object: nil,
                                               queue: nil) { [weak self] notification in

            guard let strongSelf = self else {
                AKLog("Unable to create strong reference to self")
                return
            }

            // TODO: remove from signal chain
            let crashedAU = notification.object as? AUAudioUnit
            AKLog("Audio Unit Crashed: \(crashedAU.debugDescription)")

            strongSelf.delegate?.handleAudioUnitNotification(type: .crashed, object: crashedAU)
        }
    }

    /// request a list of Effects, will be returned async

    public func requestEffects(completionHandler: AKComponentListCallback? = nil) {
        updateEffectsList {
            completionHandler?(self.availableEffects)
        }
    }

    private func updateEffectsList(completionHandler: (() -> Void)? = nil) {
        // Locating components can be a little slow, especially the first time.
        // Do this work on a separate dispatch thread.
        DispatchQueue.global(qos: .default).async {
            // Predicate will return all types of effects including
            // kAudioUnitType_Effect and kAudioUnitType_MusicEffect
            // which are the ones that we care about here
            let predicate = NSPredicate(format: "typeName CONTAINS 'Effect'", argumentArray: [])
            self.availableEffects = AVAudioUnitComponentManager.shared().components(matching: predicate)

            self.availableEffects = self.availableEffects.sorted { $0.name < $1.name }

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

    public func requestInstruments(completionHandler: AKComponentListCallback? = nil) {
        updateInstrumentsList {
            completionHandler?(self.availableInstruments)
        }
    }

    private func updateInstrumentsList(completionHandler: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .default).async {

            /// Locating components can be a little slow, especially the first time.
            /// Do this work on a separate dispatch thread.
            let predicate = NSPredicate(format: "typeName == '\(AVAudioUnitTypeMusicDevice)'", argumentArray: [])
            self.availableInstruments = AVAudioUnitComponentManager.shared().components(matching: predicate)

            self.availableInstruments = self.availableInstruments.sorted { $0.name < $1.name }

            // Let the UI know that we have an updated list of units.
            DispatchQueue.main.async {
                // notify delegate

                self.delegate?.handleAudioUnitNotification(type: .instrumentsAvailable,
                                                           object: self.availableInstruments)

                completionHandler?()

            } // dispatch main
        } // dispatch global
    }

    /// Asynchronously create the AU, then call the
    /// supplied completion handler when the operation is complete.
    public func createEffectAudioUnit(_ componentDescription: AudioComponentDescription,
                                      completionHandler: @escaping AKEffectCallback) {

        AVAudioUnitEffect.instantiate(with: componentDescription, options: .loadOutOfProcess) { avAudioUnit, _ in
            guard let avAudioUnit = avAudioUnit else {
                completionHandler(nil)
                return
            }
            completionHandler(avAudioUnit)
        }
    }

    /// Asynchronously create the AU, then call the
    /// supplied completion handler when the operation is complete.
    public func createInstrumentAudioUnit(_ componentDescription: AudioComponentDescription,
                                          completionHandler: @escaping AKInstrumentCallback) {
        AVAudioUnitMIDIInstrument.instantiate(with: componentDescription,
                                              options: .loadOutOfProcess) { avAudioUnit, _ in
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

        delegate?.handleEffectRemoved(at: index)
    }

    /// Create the Audio Unit at the specified index of the chain
    public func insertAudioUnit(name: String, at index: Int) {
        guard _effectsChain.indices.contains(index) else {
            AKLog(index, "index is invalid.")
            return
        }

        if let component = (availableEffects.first { $0.name == name }) {
            let acd = component.audioComponentDescription
            // AKLog("\(index) \(name) -- \(acd)")

            createEffectAudioUnit(acd) { au in
                guard let audioUnit = au else {
                    AKLog("Unable to create audioUnit")
                    return
                }

                if audioUnit.inputFormat(forBus: 0).channelCount == 1 {
                    // AKLog("\(audioUnit.name) is a Mono effect. Please select a stereo version of it.")
                }

                AKLog("* \(audioUnit.name) : Audio Unit created at index \(index), version: \(audioUnit)")

                self._effectsChain[index] = audioUnit
                self.connectEffects()
                DispatchQueue.main.async {
                    self.delegate?.handleEffectAdded(at: index)
                }
            }
        } else if let avUnit = createInternalAU(name: name) {

            _effectsChain[index] = avUnit
            connectEffects()
            DispatchQueue.main.async {
                self.delegate?.handleEffectAdded(at: index)
            }
        }
    }

    // Create an instance of an AudioKit internal effect
    private func createInternalAU(name: String) -> AVAudioUnit? {
        var node: AKNode?
        // this would be nice but isn't possible at the moment:
        //        if let anyClass = NSClassFromString("AudioKit." + auname) {
        //            if let aknode = anyClass as? AKNode.Type {
        //                let instance = aknode.init()
        //            }
        //        }

        switch name {
        case "AKVariableDelay":
            node = AKVariableDelay()
        case "AKChorus":
            node = AKChorus()
        case "AKFlanger":
            node = AKFlanger()
        case "AKBitCrusher":
            node = AKBitCrusher()
        case "AKClipper":
            node = AKClipper()
        case "AKRingModulator":
            node = AKRingModulator()
        case "AKDynamicRangeCompressor":
            node = AKDynamicRangeCompressor()
        case "AKDynaRageCompressor":
            node = AKDynaRageCompressor()
        case "AKAmplitudeEnvelope":
            node = AKAmplitudeEnvelope()
        case "AKTremolo":
            node = AKTremolo()
        case "AKAutoWah":
            node = AKAutoWah()
        case "AKBandPassButterworthFilter":
            node = AKBandPassButterworthFilter()
        case "AKBandRejectButterworthFilter":
            node = AKBandRejectButterworthFilter()
        case "AKDCBlock":
            node = AKDCBlock()
        case "AKEqualizerFilter":
            node = AKEqualizerFilter()
        case "AKFormantFilter":
            node = AKFormantFilter()
        case "AKHighPassButterworthFilter":
            node = AKHighPassButterworthFilter()
        case "AKHighShelfParametricEqualizerFilter":
            node = AKHighShelfParametricEqualizerFilter()
        case "AKKorgLowPassFilter":
            node = AKKorgLowPassFilter()
        case "AKLowPassButterworthFilter":
            node = AKLowPassButterworthFilter()
        case "AKLowShelfParametricEqualizerFilter":
            node = AKLowShelfParametricEqualizerFilter()
        case "AKModalResonanceFilter":
            node = AKModalResonanceFilter()
        case "AKMoogLadder":
            node = AKMoogLadder()
        case "AKPeakingParametricEqualizerFilter":
            node = AKPeakingParametricEqualizerFilter()
        case "AKResonantFilter":
            node = AKResonantFilter()
        case "AKRolandTB303Filter":
            node = AKRolandTB303Filter()
        case "AKStringResonator":
            node = AKStringResonator()
        case "AKThreePoleLowpassFilter":
            node = AKThreePoleLowpassFilter()
        case "AKToneComplementFilter":
            node = AKToneComplementFilter()
        case "AKToneFilter":
            node = AKToneFilter()
        case "AKRhinoGuitarProcessor":
            node = AKRhinoGuitarProcessor()
        case "AKPhaser":
            node = AKPhaser()
        case "AKPitchShifter":
            node = AKPitchShifter()
        case "AKChowningReverb":
            node = AKChowningReverb()
        case "AKCombFilterReverb":
            node = AKCombFilterReverb()
        case "AKCostelloReverb":
            node = AKCostelloReverb()
        case "AKFlatFrequencyResponseReverb":
            node = AKFlatFrequencyResponseReverb()
        case "AKZitaReverb":
            node = AKZitaReverb()
        case "AKBooster":
            node = AKBooster()
        case "AKTanhDistortion":
            node = AKTanhDistortion()
        case "AKTimePitch":
            node = AKTimePitch()
        case "AKVariSpeed":
            node = AKVariSpeed()
        default:
            return nil
        }

        (node as? AKToggleable)?.start()
        return node?.avAudioNode as? AVAudioUnit
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
                // AKLog("Detaching: \(au.auAudioUnit.audioUnitName)")

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
    open func connectEffects(firstNode: AKNode? = nil, lastNode: AKNode? = nil) {
        if firstNode != nil {
            input = firstNode
        }

        if lastNode != nil {
            output = lastNode
        }

        guard let input = input else {
            AKLog("input is nil")
            return
        }
        guard let output = output else {
            AKLog("output is nil")
            return
        }

        // it's an effects sandwich
        let inputAV = input.avAudioNode
        let effects = linkedEffects
        let outputAV = output.avAudioNode

        let processingFormat = inputAV.outputFormat(forBus: 0)
        // AKLog("\(effects.count) to connect... chain source format: \(processingFormat)")

        if effects.isEmpty {
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
                // AKLog("Connecting \(prevAU.name) to \(au.name) with format \(processingFormat)")
            }
        }

        // AKLog("Connecting \(au.name) to output: \(outputAV),  with format \(processingFormat)")
        AudioKit.connect(au, to: outputAV, format: processingFormat)

    }

    /// resets the processing state and clears the buffers in the AUs
    public func reset() {
        for aunit in linkedEffects {
            aunit.reset()
        }
    }

    /// Testing
    private func initAudioUnitFactoryPreset(_ audioUnit: AVAudioUnit) {
        guard let presets = audioUnit.auAudioUnit.factoryPresets else { return }
        for p in presets {
            AKLog("Factory Preset: \(p.name) \(p.number)")
        }

        presets.first.map {
            AKLog("Setting Preset: \($0.name) \($0.number)")
            audioUnit.auAudioUnit.currentPreset = $0
        }
    }

    deinit {

    }
}

public protocol AKAudioUnitManagerDelegate: class {
    func handleAudioUnitNotification(type: AKAudioUnitManager.Notification, object: Any?)
    func handleEffectAdded(at auIndex: Int)

    /// If your UI needs to handle an effect being removed
    func handleEffectRemoved(at auIndex: Int)
}
