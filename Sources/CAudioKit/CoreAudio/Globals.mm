// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "Globals.h"

// Avoid needing to expose Settings to ObjC.
// Note that eventually we shouldn't have these globals.
extern "C" float __akDefaultSampleRate = 44100;
extern "C" int __akDefaultChannelCount = 2;
