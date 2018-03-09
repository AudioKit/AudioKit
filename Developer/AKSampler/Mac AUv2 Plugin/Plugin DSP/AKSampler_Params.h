//
//  AKSampler_Params.h
//  AKSampler AUv2 Plugin
//
//  Created by Shane Dunne on 2018-03-03.
//

// Declare an enumeration of parameter-indices, which can be #include'd by both DSP (.cpp)
// and GUI (Objective-C) code.

#pragma once

// Parameters
enum
{
    kMasterVolumeFraction = 0,
    kPitchOffsetSemitones,
    kVibratoDepthSemitones,
    kFilterEnable,
    kFilterCutoffHarmonic,
    kFilterResonanceDb,
    
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

// Custom Properties
enum {
    // Apple reserves property IDs from 0 -> 63999. Developers are free to use property IDs
    // above this range.
    kPresetNameProperty = 64000
};

// Download http://getdunne.com/download/ROMPlayer_Instruments.zip and unzip in your Downloads folder.
// Then change "shane" below to your user name.
#define PRESETS_DIR_PATH "/Users/shane/Downloads/ROMPlayer Instruments"
