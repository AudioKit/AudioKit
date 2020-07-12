// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKShakerParameter) {
    AKShakerParameterType,
    AKShakerParameterAmplitude,
};

#ifndef __cplusplus

AKDSPRef createShakerDSP(void);

void triggerTypeShakerDSP(AKDSPRef dsp, AUValue type, AUValue amplitude);

#endif


