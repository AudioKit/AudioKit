// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

#ifndef __cplusplus

AKDSPRef createConvolutionDSP(void);

void setPartitionLengthConvolutionDSP(AKDSPRef dsp, int length);

#endif
