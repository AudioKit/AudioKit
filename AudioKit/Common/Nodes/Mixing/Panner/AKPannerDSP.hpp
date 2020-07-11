// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKPannerParameter) {
    AKPannerParameterPan,
};

#ifndef __cplusplus

AKDSPRef createPannerDSP(void);

#endif
