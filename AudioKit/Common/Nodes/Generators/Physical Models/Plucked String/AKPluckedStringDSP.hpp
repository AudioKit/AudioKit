// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKPluckedStringParameter) {
    AKPluckedStringParameterFrequency,
    AKPluckedStringParameterAmplitude,
};

#ifndef __cplusplus

AKDSPRef createPluckedStringDSP(void);


#endif
