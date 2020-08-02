// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "AKInterop.h"

typedef NS_ENUM(AUParameterAddress, AKShakerParameter) {
    AKShakerParameterType,
    AKShakerParameterAmplitude,
};

AK_API AKDSPRef akShakerCreateDSP(void);

AK_API void triggerTypeShakerDSP(AKDSPRef dsp, AUValue type, AUValue amplitude);


