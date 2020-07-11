// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKMetalBarParameter) {
    AKMetalBarParameterLeftBoundaryCondition,
    AKMetalBarParameterRightBoundaryCondition,
    AKMetalBarParameterDecayDuration,
    AKMetalBarParameterScanSpeed,
    AKMetalBarParameterPosition,
    AKMetalBarParameterStrikeVelocity,
    AKMetalBarParameterStrikeWidth,
};

#ifndef __cplusplus

AKDSPRef createMetalBarDSP(void);

#endif
