import AVFoundation

/**
 AudioKit's wrapper for AVAudioEngine

 Audio3DEngine is based on the AudioEngine design as much as possible.
 */
public class Audio3DEngine {

	/// Internal AVAudioEngine
	public let avEngine = AVAudioEngine()

	// maximum number of frames the engine will be asked to render in any single render call
	let maximumFrameCount: AVAudioFrameCount = 1024

	// The object that simulates a 3D audio environment.
	public private(set) var avAudioEnvironmentNode: AVAudioEnvironmentNode? {
		didSet {
			print("AVAudioEnvironmentNode New Set")
		}
	}

	/// Main mixer at the end of the signal chain
	public private(set) var main3DMixerNode: Mixer3D? {
		didSet {
			print("Mixer3D New Set")
		}
	}

	/// Input node mixer
	public class InputNode: Mixer3D {
		var isNotConnected = true

		func connect(to engine: Audio3DEngine) {
			engine.avEngine.attach(avAudioNode)
			engine.avEngine.connect(engine.avEngine.inputNode, to: avAudioNode, format: nil)
		}
	}

	let _input = InputNode()

	/// Input for microphone or other device is created when this is accessed
	/// If adjusting AudioKit.Settings, do so before setting up the microphone.
	/// Setting the .defaultToSpeaker option in AudioKit.Settings.session.setCategory after setting up your mic
	/// can cause the AVAudioEngine to stop running.
	public var input: InputNode? {
		if #available(macOS 10.14, *) {
			guard avEngine.isInManualRenderingMode || Bundle.main.object(forInfoDictionaryKey: "NSMicrophoneUsageDescription") != nil else {
				Log("To use the microphone, you must include the NSMicrophoneUsageDescription in your Info.plist", type: .error)
				return nil
			}
		}
		if _input.isNotConnected {
			_input.connect(to: self)
			_input.isNotConnected = false
		}
		return _input
	}

	/// Empty initializer
	public init() {}

	/// Output node
	public var output: Node? {
		didSet {
			// AVAudioEngine doesn't allow the outputNode to be changed while the engine is running
			let wasRunning = avEngine.isRunning
			if wasRunning { stop() }

			// remove the existing node if it is present
			if let node = oldValue {
				main3DMixerNode?.removeInput(node)
				node.detach()
				avEngine.outputNode.disconnect(input: node.avAudioNode, format: node.outputFormat)
			}

			// if non nil, set the main output now
			if let node = output {
				avEngine.attach(node.avAudioNode)

				// has the sample rate changed?
				if let currentSampleRate = main3DMixerNode?.avAudioNode.outputFormat(forBus: 0).sampleRate,
				   currentSampleRate != Settings.sampleRate
				{
				Log("Sample Rate has changed, creating new mainMixerNode at", Settings.sampleRate)
				removeEngineMixer()
				}

				// create the on demand mixer if needed
				createEngineMixer()
				attachEnvironmentNode()
				main3DMixerNode?.addInput(node)
				main3DMixerNode?.makeAVConnections()
			}

			if wasRunning { try? start() }
		}
	}

	// simulate the AVAudioEngine.mainMixerNode, but create it ourselves to ensure the
	// correct sample rate is used from Settings.audioFormat
	private func createEngineMixer() {
		guard main3DMixerNode == nil else { return }

		let mixer3D = Mixer3D(name: "AudioKit Engine Mixer")
		avEngine.attach(mixer3D.avAudioNode)
		avEngine.connect(mixer3D.avAudioNode,
						 to: avEngine.outputNode,
						 format: Settings.getStereoFormatFrom(format: Settings.audioFormat))
		main3DMixerNode = mixer3D
	}

	private func removeEngineMixer() {
		guard let mixer = main3DMixerNode else { return }
		avEngine.outputNode.disconnect(input: mixer.avAudioNode, format: mixer.outputFormat)
		mixer.removeAllInputs()
		mixer.detach()
		main3DMixerNode = nil
	}

	private func attachEnvironmentNode() {
		guard let mixer3D = main3DMixerNode else { return }
		let avAudioEnvironmentNode = AVAudioEnvironmentNode()
		avEngine.attach(avAudioEnvironmentNode)
		avEngine.connect(avAudioEnvironmentNode,
						 to: mixer3D.avAudioNode,
						 format: Settings.getStereoFormatFrom(format: mixer3D.outputFormat))
		self.avAudioEnvironmentNode = avAudioEnvironmentNode
	}


	/// Disconnect and reconnect every node
	/// Use this for instance after you change AK sample rate
	public func rebuildGraph() {
		// save the old output
		let out = output

		// disconnect everything
		out?.disconnectAV()

		// reset the output to the saved one, triggering the re-connect functions
		output = out
	}

	/// Start the engine
	public func start() throws {
		if output == nil {
			Log("🛑 Error: Attempt to start engine with no output.")
			return
		}
		try avEngine.start()
	}

	/// Stop the engine
	public func stop() {
		avEngine.stop()
	}

	/// Pause the engine
	public func pause() {
		avEngine.pause()
	}

	/// Start testing for a specified total duration
	/// - Parameter duration: Total duration of the entire test
	/// - Returns: A buffer which you can append to
	public func startTest(totalDuration duration: Double) -> AVAudioPCMBuffer {
		let samples = Int(duration * Settings.sampleRate)

		do {
			avEngine.reset()
			try avEngine.enableManualRenderingMode(.offline,
												   format: Settings.audioFormat,
												   maximumFrameCount: maximumFrameCount)
			try start()
		} catch let err {
			Log("🛑 Start Test Error: \(err)")
		}

		// Work around AVAudioEngine bug.
		output?.initLastRenderTime()

		return AVAudioPCMBuffer(
			pcmFormat: avEngine.manualRenderingFormat,
			frameCapacity: AVAudioFrameCount(samples)
		)!
	}

	/// Render audio for a specific duration
	/// - Parameter duration: Length of time to render for
	/// - Returns: Buffer of rendered audio
	public func render(duration: Double) -> AVAudioPCMBuffer {
		let sampleCount = Int(duration * Settings.sampleRate)
		let startSampleCount = Int(avEngine.manualRenderingSampleTime)

		let buffer = AVAudioPCMBuffer(
			pcmFormat: avEngine.manualRenderingFormat,
			frameCapacity: AVAudioFrameCount(sampleCount)
		)!

		let tempBuffer = AVAudioPCMBuffer(
			pcmFormat: avEngine.manualRenderingFormat,
			frameCapacity: AVAudioFrameCount(maximumFrameCount)
		)!

		do {
			while avEngine.manualRenderingSampleTime < sampleCount + startSampleCount {
				let currentSampleCount = Int(avEngine.manualRenderingSampleTime)
				let framesToRender = min(UInt32(sampleCount + startSampleCount - currentSampleCount), maximumFrameCount)
				try avEngine.renderOffline(AVAudioFrameCount(framesToRender), to: tempBuffer)
				buffer.append(tempBuffer)
			}
		} catch let err {
			Log("🛑 Could not render offline \(err)")
		}
		return buffer
	}

	/// Find an Audio Unit on the system by name and load it.
	/// Make sure to do this before the engine is running to avoid blocking.
	/// - Parameter named: Display name of the Audio Unit
	/// - Returns: The Audio Unit's AVAudioUnit
	public func findAudioUnit(named: String) -> AVAudioUnit? {
		var foundAU: AVAudioUnit?
		let allComponents = AVAudioUnitComponentManager().components(matching: AudioComponentDescription())
		for component in allComponents where component.name == named {
			AVAudioUnit.instantiate(with: component.audioComponentDescription) { theAudioUnit, _ in
				if let newAU = theAudioUnit {
					foundAU = newAU
				} else {
					Log("🛑 Failed to load Audio Unit named: \(named)")
				}
			}
		}
		if foundAU == nil { Log("🛑 Failed to find Audio Unit named: \(named)") }
		return foundAU
	}

	/// Enumerate the list of available input devices.
	public static var inputDevices: [Device] {
#if os(macOS)
		return AudioDeviceUtils.devices().compactMap { (id: AudioDeviceID) -> Device? in
			if AudioDeviceUtils.inputChannels(id) > 0 {
				return Device(deviceID: id)
			}
			return nil
		}
#else
		var returnDevices = [Device]()
		if let devices = AVAudioSession.sharedInstance().availableInputs {
			for device in devices {
				if device.dataSources == nil || device.dataSources?.isEmpty == true {
					returnDevices.append(Device(portDescription: device))

				} else if let dataSources = device.dataSources {
					for dataSource in dataSources {
						returnDevices.append(Device(name: device.portName,
													deviceID: "\(device.uid) \(dataSource.dataSourceName)"))
					}
				}
			}
			return returnDevices
		}
		return []
#endif
	}

	/// Enumerate the list of available output devices.
	public static var outputDevices: [Device] {
#if os(macOS)
		return AudioDeviceUtils.devices().compactMap { (id: AudioDeviceID) -> Device? in
			if AudioDeviceUtils.outputChannels(id) > 0 {
				return Device(deviceID: id)
			}
			return nil
		}
#else
		let devs = AVAudioSession.sharedInstance().currentRoute.outputs
		return devs.map { Device(name: $0.portName, deviceID: $0.uid) }
#endif
	}

#if os(macOS)
	/// Enumerate the list of available devices.
	public static var devices: [Device] {
		return AudioDeviceUtils.devices().map { id in
			Device(deviceID: id)
		}
	}

	/// One device for both input and output. Use aggregate devices to choose different inputs and outputs
	public var device: Device {
		Device(deviceID: avEngine.getDevice())
	}

	/// Change the preferred output device, giving it one of the names from the list of available output.
	/// - Parameter output: Output device
	/// - Throws: Error if the device cannot be set
	public func setDevice(_ output: Device) throws {
		avEngine.setDevice(id: output.deviceID)
	}

#else
	/// Change the preferred input device, giving it one of the names from the list of available inputs.
	public static func setInputDevice(_ input: Device) throws {
		// Set the port description first eg iPhone Microphone / Headset Microphone etc
		guard let portDescription = input.portDescription else {
			throw CommonError.deviceNotFound
		}
		try AVAudioSession.sharedInstance().setPreferredInput(portDescription)

		// Set the data source (if any) eg. Back/Bottom/Front microphone
		guard let dataSourceDescription = input.dataSource else {
			return
		}
		try AVAudioSession.sharedInstance().setInputDataSource(dataSourceDescription)
	}

	/// The current input device, if available.
	public var inputDevice: Device? {
		let session = AVAudioSession.sharedInstance()
		if let portDescription = session.preferredInput ?? session.currentRoute.inputs.first {
			return Device(portDescription: portDescription)
		}
		return nil
	}

	/// The current output device, if available.
	public var outputDevice: Device? {
		let devs = AVAudioSession.sharedInstance().currentRoute.outputs
		return devs.first.map { Device(name: $0.portName, deviceID: $0.uid) }
	}
#endif

	/// Render output to an AVAudioFile for a duration.
	///
	/// NOTE: This will NOT render sequencer content;
	/// MIDI content will need to be recorded in real time
	///
	/// - Parameters:
	///   - audioFile: A file initialized for writing
	///   - maximumFrameCount: Highest frame count to render, defaults to 4096
	///   - duration: Duration to render, in seconds
	///   - prerender: Closure called before rendering starts, used to start players, set initial parameters, etc.
	///   - progress: Closure called while rendering, use this to fetch render progress
	/// - Throws: Error if render failed
	@available(iOS 11, macOS 10.13, tvOS 11, *)
	public func renderToFile(_ audioFile: AVAudioFile,
							 maximumFrameCount: AVAudioFrameCount = 4096,
							 duration: Double,
							 prerender: (() -> Void)? = nil,
							 progress: ((Double) -> Void)? = nil) throws
	{
	try avEngine.render(to: audioFile,
						maximumFrameCount: maximumFrameCount,
						duration: duration,
						prerender: prerender,
						progress: progress)
	}
}
