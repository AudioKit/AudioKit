//
//  AKSampleBuffer.mm
//  ExtendingAudioKit
//
//  Created by Shane Dunne on 2018-02-21.
//  Copyright © 2018 Shane Dunne & Associates. All rights reserved.
//

#include "AKSampleBuffer.hpp"

AKSampleBuffer::AKSampleBuffer()
: pSamples(0)
, nChannelCount(0)
, nSampleCount(0)
, fStart(0.0f)
, fEnd(0.0f)
, bLoop(false)
, fLoopStart(0.0f)
, fLoopEnd(0.0f)
{
}

AKSampleBuffer::~AKSampleBuffer()
{
    deinit();
}

void AKSampleBuffer::init(int nChannelCount, int nSampleCount)
{
    this->nSampleCount = nSampleCount;
    this->nChannelCount = nChannelCount;
    if (pSamples) delete[] pSamples;
    pSamples = new float[nChannelCount * nSampleCount];
    fLoopStart = fStart = 0.0f;
    fLoopEnd = fEnd = nSampleCount;
}

void AKSampleBuffer::deinit()
{
    if (pSamples) delete[] pSamples;
    pSamples = 0;
}

void AKSampleBuffer::setData(unsigned nIndex, float data)
{
    if (nIndex < nChannelCount * nSampleCount)
    {
        pSamples[nIndex] = data;
    }
}

