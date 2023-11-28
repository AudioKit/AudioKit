// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

/**
 AudioKit version of Apple's Mixer Node. Mixes a variadic list of Nodes.

 Mixer3D is based on AudioKit's Mixer class as much as possible.
 You **MUST** use an instances of this class as endpoint of any larger
 AudioKit Chains you construct to connect to an EnvironmentalNode in MONO.
 This class exposes the 3D methods of AVAudio3DMixing
 needed to position and manipulate propeties of the sound source in 3D space,
 as well as occlusion.

 - Example: [ YourSoundChain -> Mixer3D -> EnvironmentalNode ]

 */
public class Mixer3D: Mixer {

	fileprivate let mixerAU = AVAudioMixerNode()

	override init(volume: AUValue = 1.0, name: String? = nil) {
        super.init(volume: volume, name: name)

		outputFormat = AVAudioFormat(
			standardFormatWithSampleRate: Settings.audioFormat.sampleRate,
			channels: 1
		) ?? Settings.audioFormat
    }

	// MARK: - 3D Mixing Properties

	/**
	 A value that simulates filtering of the direct path of sound due to an obstacle.
	 */
	public var obstruction: Float {
		get {
			mixerAU.obstruction
		}
		set {
			mixerAU.obstruction = newValue
		}
	}

	/**
	 A value that simulates filtering of the direct and reverb paths of sound due to an obstacle.
	 */
	public var occlusion: Float {
		get {
			mixerAU.occlusion
		}
		set {
			mixerAU.occlusion = newValue
		}
	}

	/**
	 The location of the source in the 3D environment.
	 */
	public var position: AVAudio3DPoint {
		get {
			mixerAU.position
		}
		set {
			mixerAU.position = newValue
		}
	}

	/**
	 A value that changes the playback rate of the input signal.
	 */
	public var rate: Float {
		get {
			mixerAU.rate
		}
		set {
			mixerAU.rate = newValue
		}
	}

	/**
	 A value that changes the playback rate of the input signal.
	 */
	public var pointSourceInHeadMode: AVAudio3DMixingPointSourceInHeadMode {
		get {
			mixerAU.pointSourceInHeadMode
		}
		set {
			mixerAU.pointSourceInHeadMode = newValue
		}
	}

	/**
	 A value that controls the blend of dry and reverb processed audio.
	 */
	public var reverbBlend: Float {
		get {
			mixerAU.reverbBlend
		}
		set {
			mixerAU.reverbBlend = newValue
		}
	}

	/**
	 A value that controls the blend of dry and reverb processed audio.
	 */
	public var sourceMode: AVAudio3DMixingSourceMode {
		get {
			mixerAU.sourceMode
		}
		set {
			mixerAU.sourceMode = newValue
		}
	}

	/**
	 A value that controls the blend of dry and reverb processed audio.
	 */
	public var renderingAlgorithm: AVAudio3DMixingRenderingAlgorithm {
		get {
			mixerAU.renderingAlgorithm
		}
		set {
			mixerAU.renderingAlgorithm = newValue
		}
	}

}
