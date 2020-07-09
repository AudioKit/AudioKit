// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>
#import <AudioKit/AudioKit.h>

typedef NS_ENUM (AUParameterAddress, SDBoosterParameter) {
    SDBoosterParameterLeftGain,
    SDBoosterParameterRightGain
};

#ifndef __cplusplus

AKDSPRef createSDBoosterDSP();

#endif
