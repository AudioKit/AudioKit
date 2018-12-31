//
//  AKHighPassButterworthFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKHighPassButterworthFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createHighPassButterworthFilterDSP(int nChannels, double sampleRate) {
    AKHighPassButterworthFilterDSP *dsp = new AKHighPassButterworthFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKHighPassButterworthFilterDSP::InternalData {
    sp_buthp *buthp0;
    sp_buthp *buthp1;
    AKLinearParameterRamp cutoffFrequencyRamp;
};

AKHighPassButterworthFilterDSP::AKHighPassButterworthFilterDSP() : data(new InternalData) {
    data->cutoffFrequencyRamp.setTarget(defaultCutoffFrequency, true);
    data->cutoffFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKHighPassButterworthFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKHighPassButterworthFilterParameterCutoffFrequency:
            data->cutoffFrequencyRamp.setTarget(clamp(value, cutoffFrequencyLowerBound, cutoffFrequencyUpperBound), immediate);
            break;
        case AKHighPassButterworthFilterParameterRampDuration:
            data->cutoffFrequencyRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKHighPassButterworthFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKHighPassButterworthFilterParameterCutoffFrequency:
            return data->cutoffFrequencyRamp.getTarget();
        case AKHighPassButterworthFilterParameterRampDuration:
            return data->cutoffFrequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKHighPassButterworthFilterDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_buthp_create(&data->buthp0);
    sp_buthp_init(_sp, data->buthp0);
    sp_buthp_create(&data->buthp1);
    sp_buthp_init(_sp, data->buthp1);
    data->buthp0->freq = defaultCutoffFrequency;
    data->buthp1->freq = defaultCutoffFrequency;
}

void AKHighPassButterworthFilterDSP::deinit() {
    sp_buthp_destroy(&data->buthp0);
    sp_buthp_destroy(&data->buthp1);
}

void AKHighPassButterworthFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->cutoffFrequencyRamp.advanceTo(_now + frameOffset);
        }

        data->buthp0->freq = data->cutoffFrequencyRamp.getValue();
        data->buthp1->freq = data->cutoffFrequencyRamp.getValue();

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < _nChannels; ++channel) {
            float *in  = (float *)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;
            if (channel < 2) {
                tmpin[channel] = in;
                tmpout[channel] = out;
            }
            if (!_playing) {
                *out = *in;
                continue;
            }

            if (channel == 0) {
                sp_buthp_compute(_sp, data->buthp0, in, out);
            } else {
                sp_buthp_compute(_sp, data->buthp1, in, out);
            }
        }
    }
}
