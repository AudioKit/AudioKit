// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

// Avoid needing to expose AKSettings to ObjC.
// Note that eventually we shouldn't have these globals.

#ifdef __cplusplus

extern "C" float __akDefaultSampleRate;
extern "C" int __akDefaultChannelCount;
extern "C" double __akRampDuration;
extern "C" bool __akEnableEchoCancellation;

#else

extern float __akDefaultSampleRate;
extern int __akDefaultChannelCount;
extern double __akRampDuration;
extern bool __akEnableEchoCancellation;

#endif
