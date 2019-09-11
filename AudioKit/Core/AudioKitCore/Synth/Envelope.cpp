//
//  Envelope.cpp
//  AudioKit
//
//  Created by Shane Dunne on 2018-04-06.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "Envelope.hpp"

namespace AudioKitCore
{

    EnvelopeParameters::EnvelopeParameters()
    : sampleRateHz(44100.0f) // a guess, will be overridden later by a call to init(,,,,)
    , nSegments(0)
    , pSeg(0)
    {
    }

    void EnvelopeParameters::init(float newSampleRateHz,
                                  int nSegs,
                                  EnvelopeSegmentParameters *pSegParameters,
                                  int susSegIndex,
                                  int attackSegIndex,
                                  int releaseSegIndex)
    {
        sampleRateHz = newSampleRateHz;
        nSegments = nSegs;
        pSeg = pSegParameters;
        sustainSegmentIndex = susSegIndex;
        attackSegmentIndex = attackSegIndex;
        releaseSegmentIndex = (releaseSegIndex < 0) ? nSegs - 1 : releaseSegIndex;
    }

    void EnvelopeParameters::updateSampleRate(float newSampleRateHz)
    {
        sampleRateHz = newSampleRateHz;
    }

    void Envelope::init(EnvelopeParameters *pParams)
    {
        pParameters = pParams;
        reset();
    }

    void Envelope::reset()
    {
        currentSegmentIndex = -1;   // no segment active; we're idle
        ramper.init(pParameters->pSeg[pParameters->attackSegmentIndex].initialLevel);
    }

    void Envelope::start()
    {
        int asi = pParameters->attackSegmentIndex;
        currentSegmentIndex = asi;
        float initialLevel = pParameters->pSeg[asi].initialLevel;
        float finalLevel = pParameters->pSeg[asi].finalLevel;
        int normalizedInterval = int(pParameters->pSeg[asi].seconds * pParameters->sampleRateHz);
        ramper.init(initialLevel, finalLevel, normalizedInterval);
    }

    void Envelope::release()
    {
        int rsi = pParameters->releaseSegmentIndex;
        currentSegmentIndex = rsi;
        float finalLevel = pParameters->pSeg[rsi].finalLevel;
        int normalizedInterval = int(pParameters->pSeg[rsi].seconds * pParameters->sampleRateHz);
        ramper.reinit(finalLevel, normalizedInterval);
    }

    void Envelope::restart()
    {
        // segment 0 may be defined as a quick note-dampening segment before attack segment
        currentSegmentIndex = 0;
        float finalLevel = pParameters->pSeg[0].finalLevel;
        int normalizedInterval = int(pParameters->pSeg[0].seconds * pParameters->sampleRateHz);
        ramper.reinit(finalLevel, normalizedInterval);
    }

    float Envelope::getSample()
    {
        // idle state?
        if (currentSegmentIndex < 0) return pParameters->pSeg[pParameters->attackSegmentIndex].initialLevel;

        // within a segment?
        if (ramper.isRamping()) return float(ramper.getNextValue());

        // end of last segment?
        if (currentSegmentIndex == (pParameters->nSegments - 1))
        {
            float finalLevel = pParameters->pSeg[currentSegmentIndex].finalLevel;
            reset();
            return finalLevel;
        }

        // end of last segment of looped sustain region?
        if (pParameters->sustainSegmentIndex >= 0 && currentSegmentIndex == (pParameters->releaseSegmentIndex - 1))
        {
            int ssi = pParameters->sustainSegmentIndex;
            currentSegmentIndex = ssi;
            float initialLevel = pParameters->pSeg[ssi].initialLevel;
            float finalLevel = pParameters->pSeg[ssi].finalLevel;
            int normalizedInterval = int(pParameters->pSeg[ssi].seconds * pParameters->sampleRateHz);
            ramper.init(initialLevel, finalLevel, normalizedInterval);
            return initialLevel;
        }

        // advance to next segment
        currentSegmentIndex++;
        float initialLevel = pParameters->pSeg[currentSegmentIndex].initialLevel;
        float finalLevel = pParameters->pSeg[currentSegmentIndex].finalLevel;
        int normalizedInterval = int(pParameters->pSeg[currentSegmentIndex].seconds * pParameters->sampleRateHz);
        ramper.init(initialLevel, finalLevel, normalizedInterval);
        return initialLevel;
    }
}
