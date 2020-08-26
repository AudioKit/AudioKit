// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKPitchTracker.h"

#include "soundpipe.h"
#include "soundpipeextension.h"

struct AKPitchTracker {

    sp_data *sp = nullptr;
    sp_ptrack *ptrack = nullptr;

    AKPitchTracker(size_t sampleRate) {
        sp_create(&sp);
        sp->sr = sampleRate;
        sp->nchan = 1;

        sp_ptrack_create(&ptrack);
        sp_ptrack_init(sp, ptrack, hopSize, peakCount);
    }

    ~AKPitchTracker() {
        sp_ptrack_destroy(&ptrack);
        sp_destroy(&sp);
    }

    void analyze(float* frames, size_t count) {
        for(int i=0;i<count;++i) {
            sp_ptrack_compute(sp,
                              ptrack,
                              frames+i,
                              &trackedFrequency,
                              &trackedAmplitude);
        }
    }

    float trackedAmplitude = 0.0;
    float trackedFrequency = 0.0;
    int hopSize = 4096;
    int peakCount = 20;
};

AK_API AKPitchTrackerRef akPitchTrackerCreate(unsigned int sampleRate, int hopSize, int peakCount) {
    return new AKPitchTracker(sampleRate);
}

AK_API void akPitchTrackerDestroy(AKPitchTrackerRef tracker) {
    delete tracker;
}

AK_API void akPitchTrackerAnalyze(AKPitchTrackerRef tracker, float* frames, unsigned int count) {
    tracker->analyze(frames, count);
}

AK_API void akPitchTrackerGetResults(AKPitchTrackerRef tracker, float* trackedAmplitude, float* trackedFrequency) {
    *trackedAmplitude = tracker->trackedAmplitude;
    *trackedFrequency = tracker->trackedFrequency;
}
