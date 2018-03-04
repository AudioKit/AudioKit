//
//  AKSampler_Params.h
//  AKSampler AUv2 Plugin
//
//  Created by Shane Dunne on 2018-03-03.
//

// Declare an enumeration of parameter-indices, which can be #include'd by both DSP (.cpp)
// and GUI (Objective-C) code.

#pragma once

enum {
    kMasterVolumeFraction = 0,
    kPitchOffsetSemitones,
    kVibratoDepthSemitones,
    kFilterEnable,
    kFilterCutoffHarmonic,
    
    kAmpEgAttackTimeSeconds,
    kAmpEgDecayTimeSeconds,
    kAmpEgSustainFraction,
    kAmpEgReleaseTimeSeconds,
    
    kFilterEgAttackTimeSeconds,
    kFilterEgDecayTimeSeconds,
    kFilterEgSustainFraction,
    kFilterEgReleaseTimeSeconds,

    kNumberOfParams
};
