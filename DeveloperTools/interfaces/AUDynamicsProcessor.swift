// Parameters for the AUDynamicsProcessor unit

// Global, dB, -40->20, -20
public var kDynamicsProcessorParam_Threshold: AudioUnitParameterID { get }

// Global, dB, 0.1->40.0, 5
public var kDynamicsProcessorParam_HeadRoom: AudioUnitParameterID { get }

// Global, rate, 1->50.0, 2
public var kDynamicsProcessorParam_ExpansionRatio: AudioUnitParameterID { get }

// Global, dB
public var kDynamicsProcessorParam_ExpansionThreshold: AudioUnitParameterID { get }

// Global, secs, 0.0001->0.2, 0.001
public var kDynamicsProcessorParam_AttackTime: AudioUnitParameterID { get }

// Global, secs, 0.01->3, 0.05
public var kDynamicsProcessorParam_ReleaseTime: AudioUnitParameterID { get }

// Global, dB, -40->40, 0
public var kDynamicsProcessorParam_MasterGain: AudioUnitParameterID { get }

// Global, dB, read-only parameter
public var kDynamicsProcessorParam_CompressionAmount: AudioUnitParameterID { get }
public var kDynamicsProcessorParam_InputAmplitude: AudioUnitParameterID { get }
public var kDynamicsProcessorParam_OutputAmplitude: AudioUnitParameterID { get }
