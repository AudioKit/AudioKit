//
//  EnvelopeGeneratorBase.hpp
//  AudioKit Core
//
//  Created by Shane Dunne, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//
#pragma once
#include <vector>

namespace AudioKitCore
{

    // Iterative-exponential envelope generator, as described by Will Pirkle's synthesizer book
    // (Designing Software Synthesizer Plug-Ins in C++, Focal Press, 2014, ISBN 978-1-138-78707-0)
    // and Nigel Redmon (http://www.earlevel.com/main/2013/06/02/envelope-generators-adsr-part-2/).

    // Additions/adaptations by Shane Dunne to support
    // * arbitrary number of segments, not just "ADSR"
    // * horizontal segments, both fixed-length ("hold time") and indefinite length ("sustain")
    // * linear segments (e.g. for fast shutoff)

    class ExponentialSegmentGenerator
    {
    public:
        void reset(double initialValue, double targetValue, double tco, int segmentLengthSamples);

        inline float getValue()
        {
            return float(isHorizontal ? target : output);
        }

        inline bool getSample(float& out)
        {
            if (isHorizontal)
            {
                out = float(target);
                if (segLength < 0) return false;        // non-timed "sustain"segment
                else return (++tcount >= segLength);    // timed "hold" segment
            }
            else
            {
                if (isLinear)
                    output += coefficient;
                else
                    output = offset + coefficient * output;
                bool overshoot = isRising ? (output >= target) : (output <= target);
                if (overshoot) output = target;
                out = float(output);
                return overshoot;
            }
        }

    protected:
        double output, target, offset, coefficient;
        bool isRising;
        bool isHorizontal;
        int tcount, segLength;
        bool isLinear;
    };

    class MultiSegmentEnvelopeGenerator : public ExponentialSegmentGenerator
    {
    public:
        struct SegmentDescriptor
        {
            double initialValue;
            double finalValue;
            double tco;
            int lengthSamples;
        };
        typedef std::vector<SegmentDescriptor> Descriptor;

        void reset(Descriptor* pDesc, int initialSegmentIndex = 0);
        void advanceToSegment(int segIndex);

        inline bool getSample(float& out)
        {
            if (ExponentialSegmentGenerator::getSample(out))
            {
                if (++curSegIndex >= int(segments->size()))
                {
                    reset(segments);
                    return true;
                }
                else
                {
                    setupCurSeg();
                }
            }
            return false;
        }

        int getCurrentSegmentIndex() { return curSegIndex; }

    protected:
        Descriptor* segments;
        int curSegIndex;

        void setupCurSeg();
        void setupCurSeg(double initValue);
    };

}
