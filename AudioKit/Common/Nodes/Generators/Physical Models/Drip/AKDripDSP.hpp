// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKDripParameter) {
    AKDripParameterIntensity,
    AKDripParameterDampingFactor,
    AKDripParameterEnergyReturn,
    AKDripParameterMainResonantFrequency,
    AKDripParameterFirstResonantFrequency,
    AKDripParameterSecondResonantFrequency,
    AKDripParameterAmplitude,
};

#ifndef __cplusplus

AKDSPRef createDripDSP(void);

#endif
