// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKAmplitudeEnvelopeParameter) {
    AKAmplitudeEnvelopeParameterAttackDuration,
    AKAmplitudeEnvelopeParameterDecayDuration,
    AKAmplitudeEnvelopeParameterSustainLevel,
    AKAmplitudeEnvelopeParameterReleaseDuration,
};

#ifndef __cplusplus

AKDSPRef createAmplitudeEnvelopeDSP(void);

#endif
