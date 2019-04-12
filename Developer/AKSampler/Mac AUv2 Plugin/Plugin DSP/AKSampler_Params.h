//
//  AKSampler_Params.h
//  AKSampler AUv2 Plugin
//
//  Created by Shane Dunne, revision history on Githbub.
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
    kFilterCutoffEgStrength,
    kFilterResonanceDb,
    
    kAmpEgAttackTimeSeconds,
    kAmpEgDecayTimeSeconds,
    kAmpEgSustainFraction,
    kAmpEgReleaseTimeSeconds,
    
    kFilterEgAttackTimeSeconds,
    kFilterEgDecayTimeSeconds,
    kFilterEgSustainFraction,
    kFilterEgReleaseTimeSeconds,

    kLoopThruRelease,
    kMonophonic,
    kLegato,
    kGlideRate,

    kNumberOfParams
};

// Custom Properties
enum {
    // Apple reserves property IDs from 0 -> 63999. Developers are free to use property IDs
    // above this range.
    kPresetFolderPathProperty = 64000,
    kPresetNameProperty
};

// Download http://audiokit.io/downloads/ROMPlayerInstruments.zip and unzip in your Downloads folder.
// Then change "shane" below to your user name.
#define PRESETS_DIR_PATH "/Users/shane/Desktop/ROMPlayer Instruments"
