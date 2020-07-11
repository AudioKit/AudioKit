// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKToneFilterParameter) {
    AKToneFilterParameterHalfPowerPoint,
};

#ifndef __cplusplus

AKDSPRef createToneFilterDSP(void);

#endif
