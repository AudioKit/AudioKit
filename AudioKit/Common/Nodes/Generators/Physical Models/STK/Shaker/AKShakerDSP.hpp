// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "AKInterop.h"

AK_API void triggerTypeShakerDSP(AKDSPRef dsp, AUValue type, AUValue amplitude);

/// For testing, set the random seed so we have deterministic results.
AK_API void akShakerSetSeed(unsigned int seed);

