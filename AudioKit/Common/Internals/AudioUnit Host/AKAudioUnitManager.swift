// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

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
        case effectsAvailable(effects: [AVAudioUnitComponent])
        case instrumentsAvailable(instruments: [AVAudioUnitComponent])
        case midiProcessorsAvailable(midiProcessors: [AVAudioUnitComponent])
        case changed
        case crashed(audioUnit: AUAudioUnit?)
    }

    /// Callback definitions
    public typealias AKComponentListCallback = ([AVAudioUnitComponent]) -> Void
    public typealias AKEffectCallback = (AVAudioUnit?) -> Void
    public typealias AKInstrumentCallback = (AVAudioUnitMIDIInstrument?) -> Void
    public typealias AKMIDIProcessorCallback = (AVAudioUnit?) -> Void
    private typealias NotificationCallback = (Notification) -> Void

    /// Delegate that will be sent notifications
    public weak var delegate: AKAudioUnitManagerDelegate? {
        didSet {
            // only add/remove observors if there is a delegate set that wants to know about it
            delegate != nil ? addObservors() : removeObservors()
        }
    }

    /// first node in chain, generally a player or instrument
    public var input: AKNode?

    /// last node in chain, generally a mixer or some kind of output
    public var output: AKNode?

    /// if true, it will use AKSettings.audioFormat rather than the input source for the internal processing chain
    public var useSystemAVFormat: Bool = false

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

    // Serializes all access to `_availableMIDIProcessors`.
    private let availableMIDIProcessorsAccessQueue = DispatchQueue(label:
        "AKAudioUnitManager.availableMIDIProcessorsAccessQueue")

    // List of available audio unit components.
    private var _availableMIDIProcessors = [AVAudioUnitComponent]()

    // Defaults to a chain of 6 effects
    internal var _effectsChain = [AVAudioUnit?](repeating: nil, count: 6)

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
                        AKAudioUnitManager.createEffectAudioUnit(acd) { audioUnit in
                            unitsCreated += 1
                            self._effectsChain[i] = audioUnit
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

    /// A non nil variable length array of Audio Units that are in the chain
    public var linkedEffects: [AVAudioUnit] {
        return _effectsChain.compactMap { $0 }
    }

    /// How many effects are active
    public var effectsCount: Int {
        return linkedEffects.count
    }

    /// Return the longest tail time in the currently loaded effects.
    /// Not all audio units implement this property.
    public var tailTime: TimeInterval {
        linkedEffects.compactMap({ $0.auAudioUnit.tailTime }).sorted().last ?? 0
    }

    /// `availableEffects` is accessed from multiple thread contexts. Uses a dispatch queue for synchronization.
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

    /// `availableInstruments` is accessed from multiple thread contexts. Uses a dispatch queue for synchronization.
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

    /// `availableMIDIProcessors` is accessed from multiple thread contexts. Uses a dispatch queue for synchronization.
    public var availableMIDIProcessors: [AVAudioUnitComponent] {
        get {
            return availableMIDIProcessorsAccessQueue.sync {
                self._availableMIDIProcessors
            }
        }

        set {
            availableMIDIProcessorsAccessQueue.sync {
                self._availableMIDIProcessors = newValue
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
        AKAudioUnitManager.internalAudioUnits.sort()
    }

    // MARK: - Observation

    // Only add if there is a delegate to receive the messages

    private func addObservors() {
        // Sign up for a notification when the list of available components changes.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(componentRegistrationObservor),
                                               name: .ComponentRegistrationsChanged,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(componentInstanceObservor),
                                               name: .ComponentInstanceInvalidation,
                                               object: nil)
    }

    private func removeObservors() {
        NotificationCenter.default.removeObserver(componentRegistrationObservor)
        NotificationCenter.default.removeObserver(componentInstanceObservor)
    }

    @objc private func componentRegistrationObservor(notification: Foundation.Notification) {
        AKLog("* Audio Units available changed *")
        delegate?.handleAudioUnitManagerNotification(.changed, audioUnitManager: self)
    }

    @objc private func componentInstanceObservor(notification: Foundation.Notification) {
        let crashedAU = notification.object as? AUAudioUnit
        AKLog("* Audio Unit Crashed: \(crashedAU?.debugDescription ?? notification.debugDescription)")
        delegate?.handleAudioUnitManagerNotification(.crashed(audioUnit: crashedAU), audioUnitManager: self)
    }

    // MARK: - Requesting Effects and Instruments

    /// requests a list of Effects, and caches the results
    public func requestEffects(completionHandler: AKComponentListCallback? = nil) {
        AKAudioUnitManager.effectComponents { components in
            self.availableEffects = components

            DispatchQueue.main.async {
                self.delegate?.handleAudioUnitManagerNotification(.effectsAvailable(effects: self.availableEffects),
                                                                  audioUnitManager: self)
                completionHandler?(self.availableEffects)
            }
        }
    }

    /// request a list of Instruments and caches the results
    public func requestInstruments(completionHandler: AKComponentListCallback? = nil) {
        AKAudioUnitManager.instrumentComponents { components in
            self.availableInstruments = components

            DispatchQueue.main.async {
                // notify delegate
                self.delegate?.handleAudioUnitManagerNotification(
                    .instrumentsAvailable(instruments: self.availableInstruments),
                    audioUnitManager: self)
                completionHandler?(self.availableInstruments)
            }
        }
    }

    /// request a list of Instruments and caches the results
    public func requestMIDIProcessors(completionHandler: AKComponentListCallback? = nil) {
        AKAudioUnitManager.midiProcessorComponents { components in
            self.availableMIDIProcessors = components

            DispatchQueue.main.async {
                // notify delegate
                self.delegate?.handleAudioUnitManagerNotification(
                    .midiProcessorsAvailable(midiProcessors: self.availableMIDIProcessors),
                    audioUnitManager: self)
                completionHandler?(self.availableMIDIProcessors)
            }
        }
    }

    /// Create an instrument by name. The Audio Unit will be returned in the callback.
    public func createInstrument(name: String, completionHandler: @escaping AKInstrumentCallback) {
        guard let desc = (availableInstruments.first { $0.name == name })?.audioComponentDescription else { return }
        AKAudioUnitManager.createInstrumentAudioUnit(desc) { audioUnit in
            guard let audioUnit = audioUnit else {
                AKLog("Unable to create audioUnit")
                completionHandler(nil)
                return
            }
            completionHandler(audioUnit)
        }
    }

    /// Create an effect by name. The Audio Unit will be returned in the callback.
    public func createEffect(name: String, completionHandler: @escaping AKEffectCallback) {
        guard availableEffects.isNotEmpty else {
            AKLog("You must call requestEffects before using this function. availableEffects is empty")
            completionHandler(nil)
            return
        }

        if let component = (availableEffects.first { $0.name == name }) {
            let acd = component.audioComponentDescription

            AKAudioUnitManager.createEffectAudioUnit(acd) { audioUnit in
                guard let audioUnit = audioUnit else {
                    AKLog("Unable to create audioUnit")
                    return
                }
                completionHandler(audioUnit)
            }

        } else if let audioUnit = AKAudioUnitManager.createInternalEffect(name: name) {
            completionHandler(audioUnit)

        } else {
            AKLog("Error: Unable to find \(name) in availableEffects.")
            completionHandler(nil)
        }
    }

    /// Create a MIDI Processor by name. The Audio Unit will be returned in the callback.
    public func createMIDIProcessor(name: String, completionHandler: @escaping AKMIDIProcessorCallback) {
        guard let desc = (availableMIDIProcessors.first { $0.name == name })?.audioComponentDescription else { return }
        AKAudioUnitManager.createMIDIProcessorAudioUnit(desc) { audioUnit in
            guard let audioUnit = audioUnit else {
                AKLog("Unable to create audioUnit")
                completionHandler(nil)
                return
            }
            completionHandler(audioUnit)
        }
    }

    /// Clear all linked units previous processing state. IE, Panic button.
    public func reset() {
        for aunit in linkedEffects {
            aunit.reset()
        }
    }

    // MARK: - Dispose

    /// Should be called when done with this class to release references
    public func dispose() {
        // AKLog("disposing AKAudioUnitManager")
        removeEffects()
        _availableEffects.removeAll()
        _availableInstruments.removeAll()
        _effectsChain.removeAll()
        input = nil
        output = nil
        // this will also remove the observors if added
        delegate = nil
    }

    deinit {
        AKLog("* { AKAudioUnitManager }")
    }
}

public protocol AKAudioUnitManagerDelegate: AnyObject {
    func handleAudioUnitManagerNotification(_ notification: AKAudioUnitManager.Notification,
                                            audioUnitManager: AKAudioUnitManager)
    func audioUnitManager(_ audioUnitManager: AKAudioUnitManager, didAddEffectAtIndex index: Int)
    func audioUnitManager(_ audioUnitManager: AKAudioUnitManager, didRemoveEffectAtIndex index: Int)
}
