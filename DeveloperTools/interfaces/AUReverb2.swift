// Parameters for the iOS reverb unit

// Global, CrossFade, 0->100, 100
public var kReverb2Param_DryWetMix: AudioUnitParameterID { get }
// Global, Decibels, -20->20, 0
public var kReverb2Param_Gain: AudioUnitParameterID { get }

// Global, Secs, 0.0001->1.0, 0.008
public var kReverb2Param_MinDelayTime: AudioUnitParameterID { get }
// Global, Secs, 0.0001->1.0, 0.050
public var kReverb2Param_MaxDelayTime: AudioUnitParameterID { get }
// Global, Secs, 0.001->20.0, 1.0
public var kReverb2Param_DecayTimeAt0Hz: AudioUnitParameterID { get }
// Global, Secs, 0.001->20.0, 0.5
public var kReverb2Param_DecayTimeAtNyquist: AudioUnitParameterID { get }
// Global, Integer, 1->1000, 1
public var kReverb2Param_RandomizeReflections: AudioUnitParameterID { get }
