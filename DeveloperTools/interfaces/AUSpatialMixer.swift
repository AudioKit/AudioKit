// Parameters for the AUSpatialMixer unit

// Input, Degrees, -180->180, 0
public var kSpatialMixerParam_Azimuth: AudioUnitParameterID { get }

// Input, Degrees, -90->90, 0
public var kSpatialMixerParam_Elevation: AudioUnitParameterID { get }

// Input, Metres, 0->10000, 0
public var kSpatialMixerParam_Distance: AudioUnitParameterID { get }

// Input/Output, dB, -120->20, 0
public var kSpatialMixerParam_Gain: AudioUnitParameterID { get }

// Input, rate scaler   0.5 -> 2.0
public var kSpatialMixerParam_PlaybackRate: AudioUnitParameterID { get }

// bus enable : 0.0 or 1.0
public var kSpatialMixerParam_Enable: AudioUnitParameterID { get }

// Minimum input gain constraint : 0.0 -> 1.0
public var kSpatialMixerParam_MinGain: AudioUnitParameterID { get }

// Maximum input gain constraint : 0.0 -> 1.0
public var kSpatialMixerParam_MaxGain: AudioUnitParameterID { get }

// Input, Dry/Wet equal-power blend, %    0.0 -> 100.0
public var kSpatialMixerParam_ReverbBlend: AudioUnitParameterID { get }

// Global, dB,      -40.0 -> +40.0
public var kSpatialMixerParam_GlobalReverbGain: AudioUnitParameterID { get }

// Input, Lowpass filter attenuation at 5KHz :      decibels -100.0dB -> 0.0dB
// smaller values make both direct and reverb sound more muffled; a value of 0.0 indicates no filtering
// Occlusion is a filter applied to the sound prior to the reverb send
public var kSpatialMixerParam_OcclusionAttenuation: AudioUnitParameterID { get }

// Input, Lowpass filter attenuation at 5KHz :      decibels -100.0dB -> 0.0dB
// smaller values make direct sound more muffled; a value of 0.0 indicates no filtering
// Obstruction is a filter applied to the "direct" part of the sound (so is post reverb send)
public var kSpatialMixerParam_ObstructionAttenuation: AudioUnitParameterID { get }
