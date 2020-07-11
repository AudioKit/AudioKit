// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKModalResonanceFilterParameter) {
    AKModalResonanceFilterParameterFrequency,
    AKModalResonanceFilterParameterQualityFactor,
};

#ifndef __cplusplus

AKDSPRef createModalResonanceFilterDSP(void);

#endif
