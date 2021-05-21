// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

import AVFoundation

let twoPi = 2 * Float.pi

/// Pure Swift oscillator
@available(macOS 10.15, iOS 13.0, tvOS 13.0, *)
public class PlaygroundOscillator: Node {
    fileprivate lazy var sourceNode = AVAudioSourceNode { [self] _, _, frameCount, audioBufferList in
        let ablPointer = UnsafeMutableAudioBufferListPointer(audioBufferList)
                
        let phaseIncrement = (twoPi / Float(Settings.sampleRate)) * self.frequency
        for frame in 0..<Int(frameCount) {
            // Get signal value for this frame at time.
            let index = Int(self.currentPhase / twoPi * Float(self.waveform!.count))
            let value = self.waveform![index] * self.amplitude

            // Advance the phase for the next frame.
            currentPhase += phaseIncrement
            if self.currentPhase >= twoPi { self.currentPhase -= twoPi }
            if self.currentPhase < 0.0 { self.currentPhase += twoPi }
            // Set the same value on all channels (due to the inputFormat we have only 1 channel though).
            for buffer in ablPointer {
                let buf: UnsafeMutableBufferPointer<Float> = UnsafeMutableBufferPointer(buffer)
                buf[frame] = value
            }
        }
        return noErr
    }

    /// Connected nodes
    public var connections: [Node] { [] }

    /// Underlying AVAudioNode
    public var avAudioNode: AVAudioNode { sourceNode }
    
    private var currentPhase: Float = 0
    
    fileprivate var waveform: Table?
    
    /// Specification details for frequency
    public static let frequencyDef = NodeParameterDef(
        identifier: "frequency",
        name: "Frequency (Hz)",
        address: 0,
        defaultValue: 440.0,
        range: 0.0 ... 20_000.0,
        unit: .hertz)

    /// Frequency in cycles per second
    @Parameter(frequencyDef) public var frequency: AUValue

    /// Specification details for amplitude
    public static let amplitudeDef = NodeParameterDef(
        identifier: "amplitude",
        name: "Amplitude",
        address: 1,
        defaultValue: 1.0,
        range: 0.0 ... 10.0,
        unit: .generic)

    /// Output Amplitude.
    @Parameter(amplitudeDef) public var amplitude: AUValue
    
    public init(
        waveform: Table = Table(.sine),
        frequency: AUValue = frequencyDef.defaultValue,
        amplitude: AUValue = amplitudeDef.defaultValue) {
        
        setupParameters()
        
        self.waveform = waveform
        self.frequency = frequency
        self.amplitude = amplitude
    }
}
