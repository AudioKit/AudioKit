// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#include "Interop.h"

typedef struct PitchTracker *PitchTrackerRef;

AK_API PitchTrackerRef akPitchTrackerCreate(unsigned int sampleRate, int hopSize, int peakCount);
AK_API void akPitchTrackerDestroy(PitchTrackerRef);

AK_API void akPitchTrackerAnalyze(PitchTrackerRef tracker, float* frames, unsigned int count);
AK_API void akPitchTrackerGetResults(PitchTrackerRef tracker, float* trackedAmplitude, float* trackedFrequency);
