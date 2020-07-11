// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKTremoloParameter) {
    AKTremoloParameterFrequency,
    AKTremoloParameterDepth,
};

#ifndef __cplusplus

AKDSPRef createTremoloDSP(void);

#endif
