// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#include "AKInterop.h"

typedef struct AKPitchTracker *AKPitchTrackerRef;

AK_API AKPitchTrackerRef akPitchTrackerCreate(unsigned int sampleRate, int hopSize, int peakCount);
AK_API void akPitchTrackerDestroy(AKPitchTrackerRef);

AK_API void akPitchTrackerAnalyze(AKPitchTrackerRef tracker, float* frames, unsigned int count);
AK_API void akPitchTrackerGetResults(AKPitchTrackerRef tracker, float* trackedAmplitude, float* trackedFrequency);
