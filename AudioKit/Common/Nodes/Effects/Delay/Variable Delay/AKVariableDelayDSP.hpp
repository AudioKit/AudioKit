// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKVariableDelayParameter) {
    AKVariableDelayParameterTime,
    AKVariableDelayParameterFeedback,
};

#ifndef __cplusplus

AKDSPRef createVariableDelayDSP(void);

#endif
