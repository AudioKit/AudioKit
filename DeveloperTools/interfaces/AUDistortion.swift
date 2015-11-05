// Parameters for the Distortion unit

// Global, Milliseconds, 0.1 -> 500, 0.1
public var kDistortionParam_Delay: AudioUnitParameterID { get }
// Global, Rate, 0.1 -> 50, 1.0
public var kDistortionParam_Decay: AudioUnitParameterID { get }
// Global, Percent, 0 -> 100, 50
public var kDistortionParam_DelayMix: AudioUnitParameterID { get }

// Global, Percent, 0 -> 100
public var kDistortionParam_Decimation: AudioUnitParameterID { get }
// Global, Percent, 0 -> 100, 0
public var kDistortionParam_Rounding: AudioUnitParameterID { get }
// Global, Percent, 0 -> 100, 50
public var kDistortionParam_DecimationMix: AudioUnitParameterID { get }

// Global, Linear Gain, 0 -> 1, 1
public var kDistortionParam_LinearTerm: AudioUnitParameterID { get }
// Global, Linear Gain, 0 -> 20, 0
public var kDistortionParam_SquaredTerm: AudioUnitParameterID { get }
// Global, Linear Gain, 0 -> 20, 0
public var kDistortionParam_CubicTerm: AudioUnitParameterID { get }
// Global, Percent, 0 -> 100, 50
public var kDistortionParam_PolynomialMix: AudioUnitParameterID { get }

// Global, Hertz, 0.5 -> 8000, 100
public var kDistortionParam_RingModFreq1: AudioUnitParameterID { get }
// Global, Hertz, 0.5 -> 8000, 100
public var kDistortionParam_RingModFreq2: AudioUnitParameterID { get }
// Global, Percent, 0 -> 100, 50
public var kDistortionParam_RingModBalance: AudioUnitParameterID { get }
// Global, Percent, 0 -> 100, 0
public var kDistortionParam_RingModMix: AudioUnitParameterID { get }

// Global, dB, -80 -> 20, -6
public var kDistortionParam_SoftClipGain: AudioUnitParameterID { get }

// Global, Percent, 0 -> 100, 50
public var kDistortionParam_FinalMix: AudioUnitParameterID { get }