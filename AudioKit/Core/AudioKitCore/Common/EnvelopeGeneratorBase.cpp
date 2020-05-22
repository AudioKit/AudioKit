//
//  EnvelopeGeneratorBase.cpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//
#include "EnvelopeGeneratorBase.hpp"
#include <cmath>

namespace AudioKitCore
{

    void ExponentialSegmentGenerator::reset(double initialValue, double targetValue, double tco, int segmentLengthSamples)
    {
        output = segmentLengthSamples > 0 ? initialValue : targetValue;
        target = targetValue;
        isHorizontal = targetValue == initialValue;
        isLinear = tco <= 0.0;
        isRising = targetValue > initialValue;

        printf("initVal %f targetVal %f output %f target %f  len %i\n\n", initialValue, targetValue, output, target, segmentLengthSamples);
        if (isHorizontal)
        {
            tcount = 0;
            segLength = segmentLengthSamples;
        }
        else if (isLinear)
        {
            if (segmentLengthSamples <= 0)
                coefficient = target - output;
            else
                coefficient = (targetValue - initialValue) / segmentLengthSamples;
        }
        else
        {
            if (segmentLengthSamples == 0)
            {
                coefficient = 0.0;
                offset = target;
            }
            else
            {
                // Correction to Pirkle (who uses delta = 1.0 always)
                // According to Redmon (who only discusses the delta = 1.0 case), delta should be defined thus
                double delta = abs(targetValue - initialValue);
                coefficient = exp(-log((delta + tco) / tco) / segmentLengthSamples);
                if (isRising)
                    offset = (target + tco) * (1.0 - coefficient);
                else
                    offset = (target - tco) * (1.0 - coefficient);
            }
        }
    }

    void MultiSegmentEnvelopeGenerator::setupCurSeg()
    {
        SegmentDescriptor& seg = (*segments)[curSegIndex];
        double initValue = output;
        double targetValue = seg.finalValue;
        bool isHorizontal = seg.initialValue == seg.finalValue;
        if (seg.lengthSamples == 0) {
            initValue = output;
            targetValue = output;
        }
        if (!isHorizontal) {
            targetValue = seg.finalValue;
        }
//        if (seg.lengthSamples > -1) {
            printf("auto advance seg: %i : len: %i, init: %f final %f\n", curSegIndex, seg.lengthSamples, seg.initialValue, seg.finalValue);
//        }
        ExponentialSegmentGenerator::reset(initValue, targetValue, seg.tco, seg.lengthSamples);
    }

    void MultiSegmentEnvelopeGenerator::setupCurSeg(double initValue)
    {
        SegmentDescriptor& seg = (*segments)[curSegIndex];
        double initVal = initValue;
        double targetValue = seg.finalValue;
        bool isHorizontal = seg.initialValue == seg.finalValue;
        if (seg.lengthSamples == 0) {
            initVal = output;
            targetValue = output;
        }
        if (!isHorizontal) {
            targetValue = seg.finalValue;
        }
        if (seg.lengthSamples > -1) {
            printf("manual advance seg: %i: len: %i, init: %f final %f target %f\n", curSegIndex, seg.lengthSamples, seg.initialValue, seg.finalValue, targetValue);
//            printf("manual advance: current seg is %i, target set %f\n", curSegIndex, targetValue);
        }
        ExponentialSegmentGenerator::reset(initVal, targetValue, seg.tco, seg.lengthSamples);
    }

    void MultiSegmentEnvelopeGenerator::reset(Descriptor* pDesc, int initialSegmentIndex)
    {
        segments = pDesc;
        curSegIndex = initialSegmentIndex;
        setupCurSeg();
    }

    void MultiSegmentEnvelopeGenerator::advanceToSegment(int segIndex)
    {
        curSegIndex = segIndex;
        setupCurSeg(output);
    }

}
