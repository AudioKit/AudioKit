// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKDSPKernel.hpp"

extern "C" float __akDefaultSampleRate = 44100;
extern "C" int __akDefaultChannelCount = 2;

AKDSPKernel::AKDSPKernel() : AKDSPKernel(__akDefaultChannelCount, __akDefaultSampleRate) { }

