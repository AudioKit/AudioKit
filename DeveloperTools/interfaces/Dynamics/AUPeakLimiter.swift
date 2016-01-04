// Parameters for the AUPeakLimiter unit

// Global, Secs, 0.001->0.03, 0.012
public var kLimiterParam_AttackTime: AudioUnitParameterID { get }

// Global, Secs, 0.001->0.06, 0.024
public var kLimiterParam_DecayTime: AudioUnitParameterID { get }

// Global, dB, -40->40, 0
public var kLimiterParam_PreGain: AudioUnitParameterID { get }
