// Parameters for the AULowpass unit

// Global, Hz, 10->(SampleRate/2), 6900
public var kLowPassParam_CutoffFrequency: AudioUnitParameterID { get }

// Global, dB, -20->40, 0
public var kLowPassParam_Resonance: AudioUnitParameterID { get }
