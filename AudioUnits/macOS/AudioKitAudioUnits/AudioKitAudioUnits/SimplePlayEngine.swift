/*
	Copyright (C) 2016 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information

	Abstract:
	Illustrates use of AVAudioUnitComponentManager, AVAudioEngine, AVAudioUnit and AUAudioUnit to play an audio file through a selected Audio Unit.
*/

import AVFoundation

/*
	This class implements a small engine to play an audio file in a loop using
	`AVAudioEngine`. An audio unit can be selected from those located by
	`AVAudioUnitComponentManager`. The engine supports choosing from the audio unit's
	presets.
*/
public class SimplePlayEngine: NSObject {

    // MARK: Properties

	private var componentType: UInt32 {
		willSet {
			stopPlaying()

            // Destroy any pre-existing unit.
            if testUnitNode != nil {
                if isEffect() {
                    // Break player -> effect connection.
                    engine.disconnectNodeInput(testUnitNode!)
                }

                // Break testUnitNode -> mixer connection
                engine.disconnectNodeInput(engine.mainMixerNode)

                // We're done with the unit; release all references.
                engine.detach(testUnitNode!)

                instrumentPlayer = nil

                testUnitNode = nil
                testAudioUnit = nil
                presetList = [AUAudioUnitPreset]()
            }
		}
		didSet {
			if componentType != kAudioUnitType_Effect && componentType != kAudioUnitType_MusicDevice {
				componentType = kAudioUnitType_Effect
			}

            if isEffect() {
                // Connect player -> mixer.
                engine.connect(player, to: engine.mainMixerNode, format: file!.processingFormat)
            }

			if componentsFoundCallback != nil {
				updateAudioUnitList()
			}
		}
	}

	/// The currently selected `AUAudioUnit`, if any.
	public var testAudioUnit: AUAudioUnit?

	/// The audio unit's presets.
	var presetList = [AUAudioUnitPreset]()

	/// Synchronizes starting/stopping the engine and scheduling file segments.
	private let stateChangeQueue = DispatchQueue(label: "SimplePlayEngine.stateChangeQueue")

    /// Playback engine.
	private let engine = AVAudioEngine()

    /// Engine's player node.
	private let player = AVAudioPlayerNode()

    private var instrumentPlayer: InstrumentPlayer?

    /// Engine's test unit node.
	private var testUnitNode: AVAudioUnit?

	/// File to play.
	private var file: AVAudioFile?

	/// Whether we are playing.
	private var isPlaying = false

	/// Callback to tell UI when new components are found.
    private let componentsFoundCallback: (() -> Void)?

    /// Serializes all access to `availableAudioUnits`.
	private let availableAudioUnitsAccessQueue = DispatchQueue(label: "SimplePlayEngine.availableAudioUnitsAccessQueue")

	/// List of available audio unit components.
	private var _availableAudioUnits = [AVAudioUnitComponent]()

	func isEffect() -> Bool { return componentType == kAudioUnitType_Effect }
	func isInstrument() -> Bool { return componentType == kAudioUnitType_MusicDevice }

    func setInstrument() {
        componentType = kAudioUnitType_MusicDevice
    }

    func setEffect() {
        componentType = kAudioUnitType_Effect
    }

    /**
        `self._availableAudioUnits` is accessed from multiple thread contexts. Use
        a dispatch queue for synchronization.
    */
    var availableAudioUnits: [AVAudioUnitComponent] {
        get {
            var result: [AVAudioUnitComponent]!

            availableAudioUnitsAccessQueue.sync {
                result = self._availableAudioUnits
            }

            return result
        }

        set {
            availableAudioUnitsAccessQueue.sync {
                self._availableAudioUnits = newValue
            }
        }
    }

    // MARK: Initialization

	public init(componentType inComponentType: UInt32, componentsFoundCallback inComponentsFoundCallback: (() -> Void)? = nil) {

		if inComponentType != kAudioUnitType_Effect && inComponentType != kAudioUnitType_MusicDevice {
			componentType = kAudioUnitType_Effect // alternatively, could fail here.
		} else {
			componentType = inComponentType
		}
		componentsFoundCallback = inComponentsFoundCallback
		super.init()

        engine.attach(player)

		if isEffect() {
			guard let fileURL = Bundle.main.url(forResource: "drumLoop", withExtension: "caf") else {
				fatalError("\"drumLoop.caf\" file not found.")
			}

			setPlayerFile(fileURL)
		}

		if componentsFoundCallback != nil {
			// Only bother to look up components if the client provided a callback.
			updateAudioUnitList()

			// Sign up for a notification when the list of available components changes.
			NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: kAudioComponentRegistrationsChangedNotification as String as String), object: nil, queue: nil) { [weak self] _ in
				self?.updateAudioUnitList()
			}
		}

        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            fatalError("Can't set Audio Session category.")
        }
		#endif

        /*
            Sign up for a notification when an audio unit crashes. Note that we
            handle this on the main queue for thread-safety.
        */
		NotificationCenter.default.addObserver(forName: NSNotification.Name(String(kAudioComponentInstanceInvalidationNotification)), object: nil, queue: nil) { [weak self] notification in
            guard let strongSelf = self else { return }
			/*
				If the crashed audio unit was that of our type, remove it from
                the signal chain. Note: we should notify the UI at this point.
			*/
            let crashedAU = notification.object as? AUAudioUnit
			if strongSelf.testAudioUnit === crashedAU {
                strongSelf.selectAudioUnitWithComponentDescription(nil, completionHandler: {})
			}
		}
	}

	/**
        This is called from init and when we get a notification that the list of
        available components has changed.
    */
	private func updateAudioUnitList() {
        DispatchQueue.global(qos: .default).async {
			/*
				Locating components can be a little slow, especially the first time.
				Do this work on a separate dispatch thread.

				Make a component description matching any AU of the type.
			*/
			var componentDescription = AudioComponentDescription()
            componentDescription.componentType = self.componentType
            componentDescription.componentSubType = 0
            componentDescription.componentManufacturer = 0
            componentDescription.componentFlags = 0
            componentDescription.componentFlagsMask = 0

			self.availableAudioUnits = AVAudioUnitComponentManager.shared().components(matching: componentDescription)

			// Let the UI know that we have an updated list of units.
			DispatchQueue.main.async {
				self.componentsFoundCallback!()
			}
		}
	}

	private func setPlayerFile(_ fileURL: URL) {
		do {
			let file = try AVAudioFile(forReading: fileURL)

            self.file = file

            engine.connect(player, to: engine.mainMixerNode, format: file.processingFormat)
		} catch {
			fatalError("Could not create AVAudioFile instance. error: \(error).")
		}
	}

	private func setSessionActive(_ active: Bool) {
		#if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setActive(active)
        } catch {
            fatalError("Could not set Audio Session active \(active). error: \(error).")
        }
		#endif
	}

    // MARK: Playback State

    public func startPlaying() {
        stateChangeQueue.sync {
            guard !self.isPlaying else { return }
            self.startPlayingInternal()
        }
    }

    public func stopPlaying() {
        stateChangeQueue.sync {
            guard self.isPlaying else { return }
            self.stopPlayingInternal()
        }
    }

	public func togglePlay() -> Bool {
		stateChangeQueue.sync {
			if self.isPlaying {
				self.stopPlayingInternal()
			} else {
				self.startPlayingInternal()
			}
		}

        return isPlaying
	}

	private func startPlayingInternal() {
		// assumptions: we are protected by stateChangeQueue. we are not playing.
		setSessionActive(true)

		if isEffect() {
			// Schedule buffers on the player.
			scheduleEffectLoop()
			scheduleEffectLoop()
		}

        let hardwareFormat = self.engine.outputNode.outputFormat(forBus: 0)
        self.engine.connect(self.engine.mainMixerNode, to: self.engine.outputNode, format: hardwareFormat)

		// Start the engine.
		do {
			try engine.start()
		} catch {
			fatalError("Could not start engine. error: \(error).")
		}

		if isEffect() {
			// Start the player.
			player.play()
		} else if isInstrument() {
            instrumentPlayer = InstrumentPlayer(audioUnit: testAudioUnit)
            instrumentPlayer?.play()
		}
		isPlaying = true
	}

	private func stopPlayingInternal() {
		// assumptions: we are protected by stateChangeQueue. we are playing.
        if isEffect() {
            player.stop()
        } else if isInstrument() {
            instrumentPlayer?.stop()
        }
		engine.stop()
		isPlaying = false

		setSessionActive(false)
	}

	private func scheduleEffectLoop() {
        guard let file = file else {
            fatalError("`file` must not be nil in \(#function).")
        }

		player.scheduleFile(file, at: nil) {
			self.stateChangeQueue.async {
				if self.isPlaying {
					self.scheduleEffectLoop()
				}
			}
		}
	}

    // MARK: Preset Selection

	public func selectPresetIndex(_ presetIndex: Int) {
        guard testAudioUnit != nil else { return }

        testAudioUnit!.currentPreset = presetList[presetIndex]
	}

    // MARK: AudioUnit Selection

	public func selectAudioUnitComponent(_ component: AVAudioUnitComponent?, completionHandler: @escaping () -> Void) {
        selectAudioUnitWithComponentDescription(component?.audioComponentDescription, completionHandler: completionHandler)
	}

    public func selectAudioUnitWithComponentDescription2(_ componentDescription: AudioComponentDescription, completionHandler: @escaping (() -> Void)) {
		self.selectAudioUnitWithComponentDescription(componentDescription, completionHandler: completionHandler)
	}

	/*
		Asynchronously begin changing the engine's installed unit, and call the
        supplied completion handler when the operation is complete.
	*/
    public func selectAudioUnitWithComponentDescription(_ componentDescription: AudioComponentDescription?, completionHandler: @escaping (() -> Void)) {
		NSLog("Internal function to resume playing and call the completion handler.")
		func done() {
            NSLog("Done")
			if isEffect() && isPlaying {
				player.play()
            } else if isInstrument() && isPlaying {
                instrumentPlayer = InstrumentPlayer(audioUnit: testAudioUnit)
                instrumentPlayer?.play()
            }
            NSLog("Call Completion Handler")
			completionHandler()
		}

		let hardwareFormat = self.engine.outputNode.outputFormat(forBus: 0)

		self.engine.connect(self.engine.mainMixerNode, to: self.engine.outputNode, format: hardwareFormat)

		/*
			Pause the player before re-wiring it. (It is not simple to keep it
            playing across an insertion or deletion.)
		*/
		if isEffect() && isPlaying {
			player.pause()
        } else if isInstrument() && isPlaying {
            instrumentPlayer?.stop()
            instrumentPlayer = nil
        }

		// Destroy any pre-existing unit.
		if testUnitNode != nil {
			if isEffect() {
				// Break player -> effect connection.
				engine.disconnectNodeInput(testUnitNode!)
			}

			// Break testUnitNode -> mixer connection
			engine.disconnectNodeInput(engine.mainMixerNode)

			if isEffect() {
				// Connect player -> mixer.
				engine.connect(player, to: engine.mainMixerNode, format: file!.processingFormat)
			}

			// We're done with the unit; release all references.
			engine.detach(testUnitNode!)

			testUnitNode = nil
			testAudioUnit = nil
			presetList = [AUAudioUnitPreset]()
		}

		// Insert the audio unit, if any.
		if let componentDescription = componentDescription {
            NSLog("AURE1 \(componentDescription)")
			AVAudioUnit.instantiate(with: componentDescription, options: []) { avAudioUnit, _ in
                NSLog("AURE2")
                guard let avAudioUnit = avAudioUnit else { return }

                self.testUnitNode = avAudioUnit
				self.engine.attach(avAudioUnit)

				if self.isEffect() {
					// Disconnect player -> mixer.
					self.engine.disconnectNodeInput(self.engine.mainMixerNode)

					// Connect player -> effect -> mixer.
					self.engine.connect(self.player, to: avAudioUnit, format: self.file!.processingFormat)
					self.engine.connect(avAudioUnit, to: self.engine.mainMixerNode, format: self.file!.processingFormat)
				} else {
					let stereoFormat = AVAudioFormat(standardFormatWithSampleRate: hardwareFormat.sampleRate, channels: 2)
	                self.engine.connect(avAudioUnit, to: self.engine.mainMixerNode, format: stereoFormat)
				}

				self.testAudioUnit = avAudioUnit.auAudioUnit
                self.presetList = avAudioUnit.auAudioUnit.factoryPresets ?? []
                avAudioUnit.auAudioUnit.contextName = "running in AUv3Host"

				done()
			}
            NSLog("AURE3")
		} else {
			done()
		}
        NSLog("AURE Infinity")
	}
}

/*
	This class implements a basic player for our instrument sample au,
    sending some MIDI events on a concurrent thread until stopped.
 */
internal class InstrumentPlayer: NSObject {

    internal init?(audioUnit: AUAudioUnit?) {
        guard audioUnit != nil else { return nil }
        guard let theNoteBlock = audioUnit!.scheduleMIDIEventBlock else { return nil }

        noteBlock = theNoteBlock
        super.init()
    }

    internal func play() {
        if (false == isPlaying) {
            isDone = false
            scheduleInstrumentLoop()
        }
    }

    @discardableResult
    internal func stop() -> Bool {
        self.isPlaying = false
            synced(self.isDone as AnyObject) {}
        return isDone
    }

    private var isPlaying = false
    private var isDone = false
    private var noteBlock: AUScheduleMIDIEventBlock

    private func synced(_ lock: AnyObject, closure: () -> Void) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }

    private func scheduleInstrumentLoop() {
        isPlaying = true

        let cbytes = UnsafeMutablePointer<UInt8>.allocate(capacity: 3)

        DispatchQueue.global(qos: .default).async {
            cbytes[0] = 0xB0
            cbytes[1] = 123
            cbytes[2] = 0
            self.noteBlock(AUEventSampleTimeImmediate, 0, 3, cbytes)
            usleep(useconds_t(0.1 * 1e6))

            var releaseTime: Float = 0.05

            usleep(useconds_t(0.1 * 1e6))

            var i = 0
            self.synced(self.isDone as AnyObject) {
                while self.isPlaying {
                    // lengthen the releaseTime by 5% each time up to 10 seconds.
                    if releaseTime < 10.0 {
                        releaseTime = min(releaseTime * 1.05, 10.0)
                    }

                    cbytes[0] = 0x90
                    cbytes[1] = UInt8(60 + i)
                    cbytes[2] = 127
                    self.noteBlock(AUEventSampleTimeImmediate, 0, 3, cbytes)

                    usleep(useconds_t(0.2 * 1e6))

                    cbytes[2] = 0    // note off
                    self.noteBlock(AUEventSampleTimeImmediate, 0, 3, cbytes)

                    i += 2
                    if i >= 24 {
                        i = -12
                    }
                } // while isPlaying

                cbytes[0] = 0xB0
                cbytes[1] = 123
                cbytes[2] = 0
                self.noteBlock(AUEventSampleTimeImmediate, 0, 3, cbytes)

                self.isDone = true
            } // synced
        } // dispached
    } // scheduleInstrumentLoop
}
