// Parameters for the AUParametricEQ unit

// Global, Hz, 20->(SampleRate/2), 2000
public var kParametricEQParam_CenterFreq: AudioUnitParameterID { get }

// Global, Hz, 0.1->20, 1.0
public var kParametricEQParam_Q: AudioUnitParameterID { get }

// Global, dB, -20->20, 0
public var kParametricEQParam_Gain: AudioUnitParameterID { get }
