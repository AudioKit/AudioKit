// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKStringResonatorParameter) {
    AKStringResonatorParameterFundamentalFrequency,
    AKStringResonatorParameterFeedback,
};

#ifndef __cplusplus

AKDSPRef createStringResonatorDSP(void);

#endif
