// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKRhinoGuitarProcessorDSP.hpp"
#import <AudioKit/AKDSPBase.hpp>

#include "RageProcessor.h"
#include "Filter.h"
#include "Equalisator.h"
#include "ParameterRamper.hpp"
#include <math.h>
#include <iostream>

class AKRhinoGuitarProcessorDSP : public AKDSPBase {
private:
    RageProcessor *leftRageProcessor;
    RageProcessor *rightRageProcessor;
    Equalisator *leftEqLo;
    Equalisator *rightEqLo;
    Equalisator *leftEqGtr;
    Equalisator *rightEqGtr;
    Equalisator *leftEqMi;
    Equalisator *rightEqMi;
    Equalisator *leftEqHi;
    Equalisator *rightEqHi;
    MikeFilter *mikeFilterL;
    MikeFilter *mikeFilterR;

    ParameterRamper preGainRamper;
    ParameterRamper postGainRamper;
    ParameterRamper lowGainRamper;
    ParameterRamper midGainRamper;
    ParameterRamper highGainRamper;
    ParameterRamper distortionRamper;

public:
    AKRhinoGuitarProcessorDSP() {
        parameters[AKRhinoGuitarProcessorParameterPreGain] = &preGainRamper;
        parameters[AKRhinoGuitarProcessorParameterPostGain] = &postGainRamper;
        parameters[AKRhinoGuitarProcessorParameterLowGain] = &lowGainRamper;
        parameters[AKRhinoGuitarProcessorParameterMidGain] = &midGainRamper;
        parameters[AKRhinoGuitarProcessorParameterHighGain] = &highGainRamper;
        parameters[AKRhinoGuitarProcessorParameterDistortion] = &distortionRamper;
    }

    void init(int channelCount, double sampleRate) {
        AKDSPBase::init(channelCount, sampleRate);

        leftEqLo = new Equalisator();
        rightEqLo = new Equalisator();
        leftEqGtr = new Equalisator();
        rightEqGtr = new Equalisator();
        leftEqMi = new Equalisator();
        rightEqMi = new Equalisator();
        leftEqHi = new Equalisator();
        rightEqHi = new Equalisator();
        mikeFilterL = new MikeFilter();
        mikeFilterR = new MikeFilter();

        leftRageProcessor = new RageProcessor((int)sampleRate);
        rightRageProcessor = new RageProcessor((int)sampleRate);

        mikeFilterL->calc_filter_coeffs(2500.f, sampleRate);
        mikeFilterR->calc_filter_coeffs(2500.f, sampleRate);
    }

    void deinit() {
        AKDSPBase::deinit();

        delete leftEqLo;
        delete rightEqLo;
        delete leftEqGtr;
        delete rightEqGtr;
        delete leftEqMi;
        delete rightEqMi;
        delete leftEqHi;
        delete rightEqHi;
        delete mikeFilterL;
        delete mikeFilterR;

        delete leftRageProcessor;
        delete rightRageProcessor;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float preGain = preGainRamper.getAndStep();
            float postGain = postGainRamper.getAndStep();
            float lowGain = lowGainRamper.getAndStep();
            float midGain = midGainRamper.getAndStep();
            float highGain = highGainRamper.getAndStep();
            float distortion = distortionRamper.getAndStep();

            leftEqLo->calc_filter_coeffs(7, 120, sampleRate, 0.75, -2 * -lowGain, false);
            rightEqLo->calc_filter_coeffs(7, 120, sampleRate, 0.75, -2 * -lowGain, false);

            leftEqMi->calc_filter_coeffs(6, 2450, sampleRate, 1.7, 2.5 * midGain, true);
            rightEqMi->calc_filter_coeffs(6, 2450, sampleRate, 1.7, 2.5 * midGain, true);

            leftEqHi->calc_filter_coeffs(8, 6100, sampleRate, 1.6, -15 * -highGain, false);
            rightEqHi->calc_filter_coeffs(8, 6100, sampleRate, 1.6, -15 * -highGain, false);

            float *tmpin[2];
            float *tmpout[2];
            for (int channel = 0; channel < 2; ++channel) {
                float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;
                if (channel < 2) {
                    tmpin[channel] = in;
                    tmpout[channel] = out;
                }
                if (!isStarted) {
                    *out = *in;
                    continue;
                }

                *in = *in * preGain;
                const float r_Sig = leftRageProcessor->doRage(*in, distortion * 2, distortion * 2);
                const float e_Sig = leftEqLo->filter(leftEqMi->filter(leftEqHi->filter(r_Sig))) *
                (1 / (distortion*0.8));
                *out = e_Sig * postGain;
            }
        }
    }

};

extern "C" AKDSPRef createRhinoGuitarProcessorDSP() {
    return new AKRhinoGuitarProcessorDSP();
}
