//
//  AKAudioUnitManager.swift
//  AudioKit
//
//  Created by Ryan Francesconi, revision history on Github.
//  Copyright © 2017 Ryan Francesconi. All rights reserved.
//

import AVFoundation

/// Audio Unit Manager
open class AKAudioUnitManager: NSObject {

    /// All possible types of notifications this class may generate
    public enum Notification {
        case effectsAvailable, instrumentsAvailable, changed, crashed, added
    }

    //TODO: make this variable on init()
    public static let maxInserts: Int = 6

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

    private var _effectsChain = [AVAudioUnitEffect?](repeating: nil, count: AKAudioUnitManager.maxInserts)

    /// Effects Chain
    public var effectsChain: [AVAudioUnitEffect?] {
        get {
            return _effectsChain
        }

        set {
            guard newValue.count == AKAudioUnitManager.maxInserts else {
                AKLog("number of newValues doesnt match number of inserts")
                return
            }

            var unitsCreated: Int = 0

            for i in 0 ..< newValue.count {
                if _effectsChain[i] != newValue[i] {
                    if newValue[i] == nil {
                        // ?
                        //AudioKit.engine.removeNodeInputs(_effectsChain[i])]
                        unitsCreated += 1
                        self._effectsChain[i] = nil
                        continue
                    }

                    let acd = newValue[i]!.audioComponentDescription

                    createEffectAudioUnit(acd, completionHandler: { au in
                        unitsCreated += 1

                        self._effectsChain[i] = au
                    })
                } else {
                    unitsCreated += 1
                }

                if unitsCreated == AKAudioUnitManager.maxInserts {
                    self.connectEffects()
                }
            }
        }
    }

    // just get a non nil list of Audio Units
    private var linkedEffects: [AVAudioUnit] {
        var out = [AVAudioUnit]()

        for fx in _effectsChain {
            if fx != nil {
                out.append(fx!)
            }
        }
        return out
    }

    /// How many effects are active
    public var effectsCount: Int {
        return linkedEffects.count
    }

    /// `availableEffects` is accessed from multiple thread contexts. Use a dispatch queue for synchronization.
    public var availableEffects: [AVAudioUnitComponent] {
        get {
            var result: [AVAudioUnitComponent]!

            availableEffectsAccessQueue.sync {
                result = self._availableEffects
            }
            return result
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
            var result: [AVAudioUnitComponent]!

            availableInstrumentsAccessQueue.sync {
                result = self._availableInstruments
            }
            return result
        }

        set {
            availableInstrumentsAccessQueue.sync {
                self._availableInstruments = newValue
            }
        }
    }

    // MARK: - Initialization

    /// Initialize the manager
    override public init() {
        super.init()

        // Sign up for a notification when the list of available components changes.
        var name = NSNotification.Name(rawValue: kAudioComponentRegistrationsChangedNotification as String)
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { [weak self] _ in

            guard let strongSelf = self else {
                AKLog("Unable to create strong ref to self")
                return
            }

            AKLog("* Audio Units available changed *")

            if strongSelf.delegate != nil {
                strongSelf.delegate!.handleAudioUnitNotification(type: Notification.changed, object: nil)
            }
        }

        // Sign up for a notification when an audio unit crashes. Note that we handle this on the main queue for thread-safety.
        name = NSNotification.Name(String(kAudioComponentInstanceInvalidationNotification))
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: nil) { [weak self] notification in
            guard let strongSelf = self else {
                AKLog("Unable to create strong ref to self")
                return
            }
            /*
             If the crashed audio unit was that of our type, remove it from
             the signal chain. Note: we should notify the UI at this point.
             */
            let crashedAU = notification.object as? AUAudioUnit

            AKLog("Audio Unit Crashed: \(crashedAU.debugDescription)")

            if strongSelf.delegate != nil {
                strongSelf.delegate!.handleAudioUnitNotification(type: Notification.crashed, object: crashedAU)
            }
        }
    }

    /// request a list of Effects, will be returned async
    public func requestEffects(completionHandler: (([AVAudioUnitComponent]) -> Void)? = nil) {
        updateEffectsList(completionHandler: {
            if completionHandler != nil {
                completionHandler!( self.availableEffects )
            }
        })
    }

    private func updateEffectsList( completionHandler: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .default).async {
            /*
             Locating components can be a little slow, especially the first time.
             Do this work on a separate dispatch thread.
             
             Make a component description matching any AU of the type.
             */
            var componentDescription = AudioComponentDescription()
            componentDescription.componentType = kAudioUnitType_Effect
            componentDescription.componentSubType = 0
            componentDescription.componentManufacturer = 0
            componentDescription.componentFlags = 0
            componentDescription.componentFlagsMask = 0

            self.availableEffects = AVAudioUnitComponentManager.shared().components(matching: componentDescription)

            // Let the UI know that we have an updated list of units.
            DispatchQueue.main.async {
                for au in self.availableEffects {
                    AKLog("Registering Effect: \(au.name)")
                }
                // notify delegate
                if self.delegate != nil {
                    self.delegate!.handleAudioUnitNotification(type: AKAudioUnitManager.Notification.effectsAvailable,
                                                               object: self.availableEffects)
                }

                if completionHandler != nil {
                    completionHandler!()
                }
            } // dispatch main
        } //dispatch global
    }

    /// request a list of Instruments, will be returned async
    public func requestInstruments(completionHandler: (([AVAudioUnitComponent]) -> Void)? = nil) {
        updateInstrumentsList(completionHandler: {
            if completionHandler != nil {
                completionHandler!( self.availableInstruments )
            }
        })
    }

    private func updateInstrumentsList( completionHandler: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .default).async {
            /*
             Locating components can be a little slow, especially the first time.
             Do this work on a separate dispatch thread.
             
             Make a component description matching any AU of the type.
             */
            var componentDescription = AudioComponentDescription()
            componentDescription.componentType = kAudioUnitType_MusicDevice
            componentDescription.componentSubType = 0
            componentDescription.componentManufacturer = 0
            componentDescription.componentFlags = 0
            componentDescription.componentFlagsMask = 0

            self.availableInstruments = AVAudioUnitComponentManager.shared().components(matching: componentDescription)

            // Let the UI know that we have an updated list of units.
            DispatchQueue.main.async {
                for au in self.availableInstruments {
                    AKLog("Registering Instrument: \(au.name)")
                }
                // notify delegate
                if self.delegate != nil {
                    self.delegate!.handleAudioUnitNotification(type: AKAudioUnitManager.Notification.instrumentsAvailable,
                                                               object: self.availableInstruments)
                }

                if completionHandler != nil {
                    completionHandler!()
                }
            } // dispatch main
        } //dispatch global
    }

    /*
     Asynchronously create the AU, then call the
     supplied completion handler when the operation is complete.
     */
    public func createEffectAudioUnit(_ componentDescription: AudioComponentDescription,
                                      completionHandler: @escaping ((AVAudioUnitEffect?) -> Void)) {
        AVAudioUnitEffect.instantiate(with: componentDescription, options: .loadOutOfProcess) { avAudioUnit, _ in
            guard let avAudioUnit = avAudioUnit else {
                completionHandler(nil)
                return
            }
            completionHandler(avAudioUnit as? AVAudioUnitEffect)
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

    public func removeEffect(at index: Int) {
        _effectsChain[index] = nil
        connectEffects()
    }

    // Create the Audio Unit at the specified index of the chain
    public func insertAudioUnit( name: String, at index: Int) {
        if index < 0 || index > AKAudioUnitManager.maxInserts - 1 {
            return
        }

        for component in availableEffects {
            if component.name == name {
                let acd = component.audioComponentDescription

                AKLog("#\(index) \(name) -- \(acd)")

                createEffectAudioUnit(acd, completionHandler: { au in
                    guard let audioUnit = au else {
                        AKLog("Unable to create audioUnit")
                        return
                    }

                    if audioUnit.inputFormat(forBus: 0).channelCount == 1 {
                        // Dialog.showInformation(title: "Mono Effects aren't supported",
                        //                        text: "\(audioUnit.name) is a Mono effect. Please select a stereo version of it.")
                        // return
                        AKLog("Warning: \(audioUnit.name) is a Mono effect.")
                    }

                    AKLog("* \(audioUnit.name) : Audio Unit created")

                    self._effectsChain[index] = audioUnit
                    self.connectEffects()

                    if self.delegate != nil {
                        AKLog("effectsChanged: \(self._effectsChain)")
                        self.delegate!.handleEffectAdded(at: index)
                    }
                })
            }
        }
    }

    /// Create an instrument with a name and a completion handler
    public func createInstrument(name: String, completionHandler: ((AVAudioUnitMIDIInstrument?) -> Void)? = nil) {
        for component in availableInstruments {
            if component.name == name {
                let acd = component.audioComponentDescription

                AKLog("\(name) -- \(acd)")

                createInstrumentAudioUnit(acd, completionHandler: { au in
                    guard let audioUnit = au else {
                        AKLog("Unable to create audioUnit")
                        return
                    }

                    if completionHandler != nil {
                        completionHandler!( audioUnit )
                    }
                })
            }
        }
    }

    /// Reset all effects
    open func resetEffects() {
        for i in 0 ..< _effectsChain.count {
            if let au = _effectsChain[i] {
                AKLog("Detaching: \(au.name)")

                if au.engine != nil {
                    AudioKit.engine.disconnectNodeInput(au)
                    AudioKit.engine.detach(au)
                }

                _effectsChain[i] = nil
            }
        }

        for i in 0 ..< _effectsChain.count {
            _effectsChain[i] = nil
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
            AKLog("self.input is nil")
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
            AudioKit.engine.connect(inputAV, to: outputAV, format: processingFormat)
            return
        }
        var au = effects[0]

        if au.engine == nil {
            AudioKit.engine.attach(au)
        }
        let auInputFormat = au.inputFormat(forBus: 0)
        let auOutputFormat = au.outputFormat(forBus: 0)

        AKLog("Connecting input to \(au.name) with format \(processingFormat), AU input: \(auInputFormat), output: \(auOutputFormat)")
        AudioKit.engine.connect(inputAV, to: au, format: processingFormat)

        if effects.count > 1 {
            for i in 1 ..< effects.count {
                au = effects[i]
                let prevAU = effects[i - 1]

                if au.engine == nil {
                    AudioKit.engine.attach(au)
                }
                AudioKit.engine.connect(prevAU, to: au, format: processingFormat)

                AKLog("Connecting \(prevAU.name) to \(au.name)")
            }
        }

        AKLog("Connecting \(au.name) to output")
        AudioKit.engine.connect(au, to: outputAV, format: processingFormat)
    }

}

public protocol AKAudioUnitManagerDelegate: class {
    func handleAudioUnitNotification(type: AKAudioUnitManager.Notification, object: Any?)
    func handleEffectAdded(at auIndex: Int)
}
