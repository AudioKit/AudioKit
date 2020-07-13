// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKClarinetParameter) {
    AKClarinetParameterFrequency,
    AKClarinetParameterAmplitude,
    AKClarinetParameterRampDuration
};

#ifndef __cplusplus

AKDSPRef createClarinetDSP(void);

#endif

