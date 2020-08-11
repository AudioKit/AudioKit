// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "AKInterop.h"

typedef NS_ENUM(AUParameterAddress, AKClarinetParameter) {
    AKClarinetParameterFrequency,
    AKClarinetParameterAmplitude,
    AKClarinetParameterRampDuration
};

AK_API AKDSPRef akClarinetCreateDSP(void);

