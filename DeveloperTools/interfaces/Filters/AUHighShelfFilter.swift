// Parameters for the AUHighShelfFilter unit

// Global, Hz, 10000->(SampleRate/2), 10000
public var kHighShelfParam_CutOffFrequency: AudioUnitParameterID { get }

// Global, dB, -40->40, 0
public var kHighShelfParam_Gain: AudioUnitParameterID { get }
