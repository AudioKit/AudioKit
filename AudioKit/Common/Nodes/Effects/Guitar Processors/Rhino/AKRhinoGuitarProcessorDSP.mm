// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKRhinoGuitarProcessorDSP.hpp"

#include "RageProcessor.h"
#include "Filter.h"
#include "Equalisator.h"
#include "AKLinearParameterRamp.hpp"
#include <math.h>
#include <iostream>

extern "C" AKDSPRef createRhinoGuitarProcessorDSP() {
    return new AKRhinoGuitarProcessorDSP();
}

struct AKRhinoGuitarProcessorDSP::InternalData {
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

    AKLinearParameterRamp preGainRamper;
    AKLinearParameterRamp postGainRamper;
    AKLinearParameterRamp lowGainRamper;
    AKLinearParameterRamp midGainRamper;
    AKLinearParameterRamp highGainRamper;
    AKLinearParameterRamp distortionRamper;
};

AKRhinoGuitarProcessorDSP::AKRhinoGuitarProcessorDSP() : data(new InternalData) {
    parameters[AKRhinoGuitarProcessorParameterPreGain] = &data->preGainRamper;
    parameters[AKRhinoGuitarProcessorParameterPostGain] = &data->postGainRamper;
    parameters[AKRhinoGuitarProcessorParameterLowGain] = &data->lowGainRamper;
    parameters[AKRhinoGuitarProcessorParameterMidGain] = &data->midGainRamper;
    parameters[AKRhinoGuitarProcessorParameterHighGain] = &data->highGainRamper;
    parameters[AKRhinoGuitarProcessorParameterDistortion] = &data->distortionRamper;
}

void AKRhinoGuitarProcessorDSP::init(int channelCount, double sampleRate) {
    AKDSPBase::init(channelCount, sampleRate);

    data->leftEqLo = new Equalisator();
    data->rightEqLo = new Equalisator();
    data->leftEqGtr = new Equalisator();
    data->rightEqGtr = new Equalisator();
    data->leftEqMi = new Equalisator();
    data->rightEqMi = new Equalisator();
    data->leftEqHi = new Equalisator();
    data->rightEqHi = new Equalisator();
    data->mikeFilterL = new MikeFilter();
    data->mikeFilterR = new MikeFilter();

    data->leftRageProcessor = new RageProcessor((int)sampleRate);
    data->rightRageProcessor = new RageProcessor((int)sampleRate);

    data->mikeFilterL->calc_filter_coeffs(2500.f, sampleRate);
    data->mikeFilterR->calc_filter_coeffs(2500.f, sampleRate);
}

void AKRhinoGuitarProcessorDSP::deinit() {
    AKDSPBase::deinit();
    
    delete data->leftEqLo;
    delete data->rightEqLo;
    delete data->leftEqGtr;
    delete data->rightEqGtr;
    delete data->leftEqMi;
    delete data->rightEqMi;
    delete data->leftEqHi;
    delete data->rightEqHi;
    delete data->mikeFilterL;
    delete data->mikeFilterR;

    delete data->leftRageProcessor;
    delete data->rightRageProcessor;
}

void AKRhinoGuitarProcessorDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);
        
        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->preGainRamper.advanceTo(now + frameOffset);
            data->postGainRamper.advanceTo(now + frameOffset);
            data->lowGainRamper.advanceTo(now + frameOffset);
            data->midGainRamper.advanceTo(now + frameOffset);
            data->highGainRamper.advanceTo(now + frameOffset);
            data->distortionRamper.advanceTo(now + frameOffset);
        }
        
        float preGain = data->preGainRamper.getValue();
        float postGain = data->postGainRamper.getValue();
        float lowGain = data->lowGainRamper.getValue();
        float midGain = data->midGainRamper.getValue();
        float highGain = data->highGainRamper.getValue();
        float distortion = data->distortionRamper.getValue();

        data->leftEqLo->calc_filter_coeffs(7, 120, sampleRate, 0.75, -2 * -lowGain, false);
        data->rightEqLo->calc_filter_coeffs(7, 120, sampleRate, 0.75, -2 * -lowGain, false);

        data->leftEqMi->calc_filter_coeffs(6, 2450, sampleRate, 1.7, 2.5 * midGain, true);
        data->rightEqMi->calc_filter_coeffs(6, 2450, sampleRate, 1.7, 2.5 * midGain, true);

        data->leftEqHi->calc_filter_coeffs(8, 6100, sampleRate, 1.6, -15 * -highGain, false);
        data->rightEqHi->calc_filter_coeffs(8, 6100, sampleRate, 1.6, -15 * -highGain, false);

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
            const float r_Sig = data->leftRageProcessor->doRage(*in, distortion * 2, distortion * 2);
            const float e_Sig = data->leftEqLo->filter(data->leftEqMi->filter(data->leftEqHi->filter(r_Sig))) *
            (1 / (distortion*0.8));
            *out = e_Sig * postGain;
        }
    }
}
