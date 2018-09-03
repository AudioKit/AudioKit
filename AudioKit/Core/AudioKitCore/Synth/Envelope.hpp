//
//  Envelope.hpp
//  AudioKit
//
//  Created by Shane Dunne on 2018-04-06.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#include "LinearRamper.hpp"
#include "FunctionTable.hpp"

namespace AudioKitCore
{

    struct EnvelopeSegmentParameters
    {
        float initialLevel;             // where this segment starts
        float finalLevel;               // where it ends
        float seconds;                  // how long it takes to get there
    };

    struct EnvelopeParameters
    {
        float sampleRateHz;

        int nSegments;                  // number of segments
        EnvelopeSegmentParameters *pSeg;    // points to an array of nSegments elements

        int attackSegmentIndex;         // start() begins at this segment
        int sustainSegmentIndex;        // index of first sustain segment (-1 if none)
        int releaseSegmentIndex;        // release() jumps to this segment

        EnvelopeParameters();
        void init(float newSampleRateHz, int nSegs, EnvelopeSegmentParameters *pSegParameters,
                  int susSegIndex=-1, int attackSegIndex=0, int releaseSegIndex=-1);
        void updateSampleRate(float newSampleRateHz);
    };

    struct Envelope
    {
        EnvelopeParameters *pParameters;
        LinearRamper ramper;
        int currentSegmentIndex;

        void init(EnvelopeParameters *pParameters);

        void start();       // begin attack segment
        void restart();     // go to segment 0
        void release();     // go to release segment
        void reset();       // reset to idle state
        bool isIdle() { return currentSegmentIndex < 0; }
        bool isReleasing() { return currentSegmentIndex >= pParameters->releaseSegmentIndex; }

        float getSample();
    };
}
