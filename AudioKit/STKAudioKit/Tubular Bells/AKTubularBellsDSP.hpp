// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKTubularBellsParameter) {
    AKTubularBellsParameterFrequency,
    AKTubularBellsParameterAmplitude,
    AKTubularBellsParameterRampDuration
};

#ifndef __cplusplus

AKDSPRef createTubularBellsDSP(void);

#endif


