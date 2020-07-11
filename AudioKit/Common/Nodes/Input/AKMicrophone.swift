// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

/// Audio from the standard input
@objc open class AKMicrophone: AKNode, AKToggleable {

    internal let mixer = AVAudioMixerNode()

    /// Output Volume (Default 1)
    @objc open dynamic var volume: AUValue = 1.0 {
        didSet {
            volume = max(volume, 0)
            mixer.outputVolume = volume
        }
    }

    /// Set the actual microphone device
    public func setDevice(_ device: AKDevice) throws {
        do {
            try AKManager.setInputDevice(device)
        } catch {
            AKLog("Could not set input device")
        }
    }

    fileprivate var lastKnownVolume: AUValue = 1.0

    /// Determine if the microphone is currently on.
    @objc open dynamic var isStarted: Bool {
        return volume != 0.0
    }

    /// Initialize the microphone
	@objc public init?(with format: AVAudioFormat? = nil) {
		super.init(avAudioNode: AVAudioNode())
		guard let formatForDevice = getFormatForDevice() else {
			AKLog("Error! Cannot unwrap format for device. Can't init the mic.")
			return nil
		}
		self.avAudioNode = mixer
		AKSettings.audioInputEnabled = true

		#if os(iOS)
		AKManager.engine.attach(avAudioUnitOrNode)
		AKManager.engine.connect(AKManager.engine.inputNode, to: self.avAudioNode, format: format ?? formatForDevice)
		#elseif !os(tvOS)
		AKManager.engine.inputNode.connect(to: self.avAudioNode)
		#endif
	}

	// Making this throw as whenever we have sample rate mismatches, it often crashes.
	private func setAVSessionSampleRate(sampleRate: Double) throws {
        #if !os(macOS)
        do {
            try AVAudioSession.sharedInstance().setPreferredSampleRate(sampleRate)
        } catch {
            AKLog(error.localizedDescription)
			throw error
        }
        #endif
    }

    /// Function to start, play, or activate the node, all do the same thing
    open func start() {
        if isStopped {
            volume = lastKnownVolume
        }
    }

    /// Function to stop or bypass the node, both are equivalent
    open func stop() {
        if isPlaying {
            lastKnownVolume = volume
            volume = 0
        }
    }

    // Here is where we actually check the device type and make the settings, if needed
    private func getFormatForDevice() -> AVAudioFormat? {
        let audioFormat: AVAudioFormat?
        #if os(iOS) && !targetEnvironment(simulator)
        let currentFormat = AKManager.engine.inputNode.inputFormat(forBus: 0)
        let desiredFS = AVAudioSession.sharedInstance().sampleRate
        if let layout = currentFormat.channelLayout {
            audioFormat = AVAudioFormat(commonFormat: currentFormat.commonFormat,
                                        sampleRate: desiredFS,
                                        interleaved: currentFormat.isInterleaved,
                                        channelLayout: layout)
        } else {
            audioFormat = AVAudioFormat(standardFormatWithSampleRate: desiredFS, channels: 2)
        }
        #else
        let desiredFS = AKSettings.sampleRate
        audioFormat = AVAudioFormat(standardFormatWithSampleRate: desiredFS, channels: 2)
        #endif
        return audioFormat
    }
}
