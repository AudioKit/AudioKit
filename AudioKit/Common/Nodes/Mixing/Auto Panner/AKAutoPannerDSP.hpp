// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKAutoPannerParameter) {
    AKAutoPannerParameterFrequency,
    AKAutoPannerParameterDepth,
};

#ifndef __cplusplus

AKDSPRef createAutoPannerDSP(void);

#endif
