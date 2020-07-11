// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKGlobals.hpp"

// Avoid needing to expose AKSettings to ObjC.
// Note that eventually we shouldn't have these globals.
extern "C" float __akDefaultSampleRate = 44100;
extern "C" int __akDefaultChannelCount = 2;
