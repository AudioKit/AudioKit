// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

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
        SegmentDescriptor seg = (*segments)[curSegIndex];
        ExponentialSegmentGenerator::reset(seg.initialValue, seg.finalValue, seg.tco, seg.lengthSamples);
    }

    void MultiSegmentEnvelopeGenerator::setupCurSeg(double initValue)
    {
        SegmentDescriptor seg = (*segments)[curSegIndex];
        double targetValue = seg.finalValue;
        bool isHorizontal = seg.initialValue == seg.finalValue;
        if (isHorizontal) { // if flat (hold) then use same value, prevents fades from currentVal to hold val
            targetValue = initValue;
        }
        ExponentialSegmentGenerator::reset(initValue, targetValue, seg.tco, seg.lengthSamples);
    }

    void MultiSegmentEnvelopeGenerator::reset(Descriptor* pDesc, int initialSegmentIndex)
    {
        segments = pDesc;
        curSegIndex = initialSegmentIndex;
        setupCurSeg();
    }

    void MultiSegmentEnvelopeGenerator::startAtSegment(int segIndex) //puts the envelope in a 'fresh' state, allows sudden jumps to first segment
    {
        curSegIndex = segIndex;
        if (skipEmptySegments()) {
            SegmentDescriptor& seg = (*segments)[curSegIndex];
            setupCurSeg(seg.initialValue); // we are restarting, not advancing, so  always start from the first vlaue we get to
        };
    }

    void MultiSegmentEnvelopeGenerator::advanceToSegment(int segIndex) //advances w/ awareness of state, so as to not make sudden jumps
    {
        curSegIndex = segIndex;
        if (skipEmptySegments()) {
            setupCurSeg(output); //we are advancing, not restarting, so always start from the value we are currently at
        };
    }

    bool MultiSegmentEnvelopeGenerator::skipEmptySegments() //skips over any segment w/ length 0, so as to not influence the state of the envelope
    {
        SegmentDescriptor seg = (*segments)[curSegIndex];
        int length = seg.lengthSamples;
        while (length == 0) { //skip any segments that are 0-length
            curSegIndex++;
            seg = (*segments)[curSegIndex];
            length = seg.lengthSamples;
        }
        if (curSegIndex >= int(segments->size())) // if at end of the envelope, reset
        {
            reset(segments);
            return false;
        }
        return true;
    }

}
