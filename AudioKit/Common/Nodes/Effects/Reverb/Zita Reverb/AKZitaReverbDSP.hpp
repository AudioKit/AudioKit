// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKZitaReverbParameter) {
    AKZitaReverbParameterPredelay,
    AKZitaReverbParameterCrossoverFrequency,
    AKZitaReverbParameterLowReleaseTime,
    AKZitaReverbParameterMidReleaseTime,
    AKZitaReverbParameterDampingFrequency,
    AKZitaReverbParameterEqualizerFrequency1,
    AKZitaReverbParameterEqualizerLevel1,
    AKZitaReverbParameterEqualizerFrequency2,
    AKZitaReverbParameterEqualizerLevel2,
    AKZitaReverbParameterDryWetMix,
};

#ifndef __cplusplus

AKDSPRef createZitaReverbDSP(void);

#endif
