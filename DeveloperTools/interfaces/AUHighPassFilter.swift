// Parameters for the AUHipass unit

// Global, Hz, 10->(SampleRate/2), 6900
public var kHipassParam_CutoffFrequency: AudioUnitParameterID { get }

// Global, dB, -20->40, 0
public var kHipassParam_Resonance: AudioUnitParameterID { get }
