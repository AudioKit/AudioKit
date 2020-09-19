// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#include "Interop.h"
#import "TPCircularBuffer.h"

typedef struct TapNodeDSP *TapNodeDSPRef;

AK_API TPCircularBuffer* akTapNodeGetLeftBuffer(DSPRef dsp);
AK_API TPCircularBuffer* akTapNodeGetRightBuffer(DSPRef dsp);
