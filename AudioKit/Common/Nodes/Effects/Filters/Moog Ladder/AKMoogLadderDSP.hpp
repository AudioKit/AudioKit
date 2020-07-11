// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKMoogLadderParameter) {
    AKMoogLadderParameterCutoffFrequency,
    AKMoogLadderParameterResonance,
};

#ifndef __cplusplus

AKDSPRef createMoogLadderDSP(void);

#endif
