//
//  AKSampler_Params.h
//  AKSampler AUv2 Plugin
//
//  Created by Shane Dunne on 2018-03-03.
//

#pragma once

enum {
    kMasterVolumeFraction = 0,
    kPitchOffsetSemitones,
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
