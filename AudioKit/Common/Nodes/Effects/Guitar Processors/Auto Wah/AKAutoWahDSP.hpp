// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "AKInterop.hpp"

typedef NS_ENUM(AUParameterAddress, AKAutoWahParameter) {
    AKAutoWahParameterWah,
    AKAutoWahParameterMix,
    AKAutoWahParameterAmplitude,
};

AK_API AKDSPRef createAutoWahDSP(void);

