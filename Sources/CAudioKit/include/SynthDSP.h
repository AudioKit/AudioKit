// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "Interop.h"

typedef NS_ENUM(AUParameterAddress, SynthParameter)
{
    // ramped parameters
    
    SynthParameterMasterVolume,
    SynthParameterPitchBend,
    SynthParameterVibratoDepth,
    SynthParameterFilterCutoff,
    SynthParameterFilterStrength,
    SynthParameterFilterResonance,

    // simple parameters

    SynthParameterAttackDuration,
    SynthParameterDecayDuration,
    SynthParameterSustainLevel,
    SynthParameterReleaseDuration,
    SynthParameterFilterAttackDuration,
    SynthParameterFilterDecayDuration,
    SynthParameterFilterSustainLevel,
    SynthParameterFilterReleaseDuration,

    // ensure this is always last in the list, to simplify parameter addressing
    SynthParameterRampDuration,
};

AK_API DSPRef akSynthCreateDSP(void);
