// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "AKInterop.h"

typedef NS_ENUM(AUParameterAddress, AKTubularBellsParameter) {
    AKTubularBellsParameterFrequency,
    AKTubularBellsParameterAmplitude,
    AKTubularBellsParameterRampDuration
};

AK_API AKDSPRef akTubularBellsCreateDSP(void);


