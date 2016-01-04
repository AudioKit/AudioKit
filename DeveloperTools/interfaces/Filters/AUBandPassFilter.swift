// Parameters for the AUBandpass unit

// Global, Hz, 20->(SampleRate/2), 5000
public var kBandpassParam_CenterFrequency: AudioUnitParameterID { get }

// Global, Cents, 100->12000, 600
public var kBandpassParam_Bandwidth: AudioUnitParameterID { get }