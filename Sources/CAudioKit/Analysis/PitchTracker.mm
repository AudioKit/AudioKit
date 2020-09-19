// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "PitchTracker.h"

#include "soundpipe.h"

struct PitchTracker {

    sp_data *sp = nullptr;
    sp_ptrack *ptrack = nullptr;

    PitchTracker(size_t sampleRate, int hopSize, int peakCount) {
        sp_create(&sp);
        sp->sr = (int)sampleRate;
        sp->nchan = 1;

        sp_ptrack_create(&ptrack);
        sp_ptrack_init(sp, ptrack, hopSize, peakCount);
    }

    ~PitchTracker() {
        sp_ptrack_destroy(&ptrack);
        sp_destroy(&sp);
    }

    void analyze(float* frames, size_t count) {
        for(int i = 0; i < count; ++i) {
            sp_ptrack_compute(sp, ptrack, frames + i, &trackedFrequency, &trackedAmplitude);
        }
    }

    float trackedAmplitude = 0.0;
    float trackedFrequency = 0.0;
};

AK_API PitchTrackerRef akPitchTrackerCreate(unsigned int sampleRate, int hopSize, int peakCount) {
    return new PitchTracker(sampleRate, hopSize, peakCount);
}

AK_API void akPitchTrackerDestroy(PitchTrackerRef tracker) {
    delete tracker;
}

AK_API void akPitchTrackerAnalyze(PitchTrackerRef tracker, float* frames, unsigned int count) {
    tracker->analyze(frames, count);
}

AK_API void akPitchTrackerGetResults(PitchTrackerRef tracker, float* trackedAmplitude, float* trackedFrequency) {
    *trackedAmplitude = tracker->trackedAmplitude;
    *trackedFrequency = tracker->trackedFrequency;
}
