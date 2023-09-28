import AVFoundation

public extension AVAudioEnvironmentNode {
    /// Make a connection without breaking other connections.
    /// Makes sure the Mixer3D connects to the EnviromentalNode In **MONO**
    func connectMixer3D(_ input: AVAudioNode, format: AVAudioFormat) {
        if let engine = engine,
           let monoFormat = AVAudioFormat(
            standardFormatWithSampleRate: Settings.audioFormat.sampleRate,
            channels: 1) {
            var points = engine.outputConnectionPoints(for: input, outputBus: 0)
            if points.contains(where: { $0.node === self }) { return }
            points.append(AVAudioConnectionPoint(node: self, bus: nextAvailableInputBus))
            if points.count == 1 {
                // If we only have 1 connection point, use connect API
                // Workaround for a bug where specified format is not correctly applied
                // http://openradar.appspot.com/radar?id=5490575180562432
                engine.connect(input, to: self, format: monoFormat)
            } else {
                engine.connect(input, to: points, fromBus: 0, format: format)
            }
        }
    }
}

/**
 AudioKit wrapper of Apple's AVAudioEnvironmentNode Node.
 
 This is the object which does the rendering of 3D positional sound,
 and allow mamipulation of the listener position/orientation.
 All sound sources which you want rendered in 3D **MUST** connect to the EnvironmentalNode in MONO,
 otherwise the signal is just passed through.
 Enviromental Nodes can (and should) be connected to any downstream nodes (usually a mixer) in STEREO.
 This class exposes the  methods of AVAudioEnvironmentNode
 needed to position and manipulate propeties of the listener in 3D space,
 as well as the over-all reverb.
 
 - Example: [  Mixer3D -> EnvironmentalNode -> MainMixer]
 
 */
public class EnvironmentalNode: Node, NamedNode {
    /// The internal avAudioEnvironmentNode node
    public private(set) var avAudioEnvironmentNode = AVAudioEnvironmentNode()
    var inputs: [Node] = []
    public var connections: [Node] { inputs }
    public var avAudioNode: AVAudioNode {
        avAudioEnvironmentNode
    }
    open var name = "(unset)"
    /// The listener’s position in the 3D environment.
    public var listenerPosition: AVAudio3DPoint {
        get {
            avAudioEnvironmentNode.listenerPosition
        }
        set {
            avAudioEnvironmentNode.listenerPosition = newValue
        }
    }
    /// The listener’s angular orientation in the environment.
    public var listenerAngularOrientation: AVAudio3DAngularOrientation {
        get {
            avAudioEnvironmentNode.listenerAngularOrientation
        }
        set {
            avAudioEnvironmentNode.listenerAngularOrientation = newValue
        }
    }
    /// The listener’s angular orientation in the environment.
    public var listenerVectorOrientation: AVAudio3DVectorOrientation {
        get {
            avAudioEnvironmentNode.listenerVectorOrientation
        }
        set {
            avAudioEnvironmentNode.listenerVectorOrientation = newValue
        }
    }
    /// The distance attenuation parameters for the environment (read only)
    public var distanceAttenuationParameters: AVAudioEnvironmentDistanceAttenuationParameters {
        {
            return avAudioEnvironmentNode.distanceAttenuationParameters
        }()
    }
    /// The reverb parameters for the environment. (get only)
    public var reverbParameters: AVAudioEnvironmentReverbParameters {
        {
            return avAudioEnvironmentNode.reverbParameters
        }()
    }
    /// The  blend of reverb-processed (also called dry and wet) audio for playback of the audio source.
    public var reverbBlend: Float {
        get {
            avAudioEnvironmentNode.reverbBlend
        }
        set {
            avAudioEnvironmentNode.reverbBlend = newValue
        }
    }
    /// The mixer’s output volume.
    public var outputVolume: Float {
        get {
            avAudioEnvironmentNode.outputVolume
        }
        set {
            avAudioEnvironmentNode.outputVolume = newValue
        }
    }
    /// The type of output hardware.
    public var outputType: AVAudioEnvironmentOutputType {
        get {
            avAudioEnvironmentNode.outputType
        }
        set {
            avAudioEnvironmentNode.outputType = newValue
        }
    }
    /// An array of rendering algorithms applicable to the environment node. (read only)
    public var applicableRenderingAlgorithms: [NSNumber] {
        {
            return avAudioEnvironmentNode.applicableRenderingAlgorithms
        }()
    }
    /// The type of rendering algorithm the mixer uses.
    public var renderingAlgorithm: AVAudio3DMixingRenderingAlgorithm {
        get {
            avAudioEnvironmentNode.renderingAlgorithm
        }
        set {
            avAudioEnvironmentNode.renderingAlgorithm = newValue
        }
    }
    /// An unused input bus.
    public var nextAvailableInputBus: AVAudioNodeBus {
        {
            return avAudioEnvironmentNode.nextAvailableInputBus
        }()
    }
    public init() {	}
    /**
     In order to control the source's 3D properties the single going into the avAudioEnvironmentNode
     must conform to AVAudioMixing (specifically AVAudio3DMixing).
     
     To simplify keeping thing AudioKit easy, you can only connect Mixer3D
     object to EnvironmentalNode with this function.
     Therefore to connect any non-mixer3D object,
     you must first connect the object to a Mixer3D instance,
     and then that instance to the EnvironmentalNode.
     
     - Attention: Each object you want to poition in 3D Space must have its own Mixer3D instance.
     
     - Parameter mixer3D: Mixer3D
     */
    public func connect(mixer3D: Mixer3D) {
        inputs.append(mixer3D)
    }
    /// Remove all inputs from the EnvironmentalNode
    public func removeInputs() {
        guard connections.isNotEmpty else { return }
        inputs.removeAll()
    }
}
