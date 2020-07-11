// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKPeakingParametricEqualizerFilterParameter) {
    AKPeakingParametricEqualizerFilterParameterCenterFrequency,
    AKPeakingParametricEqualizerFilterParameterGain,
    AKPeakingParametricEqualizerFilterParameterQ,
};

#ifndef __cplusplus

AKDSPRef createPeakingParametricEqualizerFilterDSP(void);

#endif
