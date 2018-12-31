//
//  AKLowPassButterworthFilterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKLowPassButterworthFilterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createLowPassButterworthFilterDSP(int nChannels, double sampleRate) {
    AKLowPassButterworthFilterDSP *dsp = new AKLowPassButterworthFilterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKLowPassButterworthFilterDSP::_Internal {
    sp_butlp *_butlp0;
    sp_butlp *_butlp1;
    AKLinearParameterRamp cutoffFrequencyRamp;
};

AKLowPassButterworthFilterDSP::AKLowPassButterworthFilterDSP() : data(new _Internal) {
    data->cutoffFrequencyRamp.setTarget(defaultCutoffFrequency, true);
    data->cutoffFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKLowPassButterworthFilterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKLowPassButterworthFilterParameterCutoffFrequency:
            data->cutoffFrequencyRamp.setTarget(clamp(value, cutoffFrequencyLowerBound, cutoffFrequencyUpperBound), immediate);
            break;
        case AKLowPassButterworthFilterParameterRampDuration:
            data->cutoffFrequencyRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKLowPassButterworthFilterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKLowPassButterworthFilterParameterCutoffFrequency:
            return data->cutoffFrequencyRamp.getTarget();
        case AKLowPassButterworthFilterParameterRampDuration:
            return data->cutoffFrequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKLowPassButterworthFilterDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_butlp_create(&data->_butlp0);
    sp_butlp_init(_sp, data->_butlp0);
    sp_butlp_create(&data->_butlp1);
    sp_butlp_init(_sp, data->_butlp1);
    data->_butlp0->freq = defaultCutoffFrequency;
    data->_butlp1->freq = defaultCutoffFrequency;
}

void AKLowPassButterworthFilterDSP::deinit() {
    sp_butlp_destroy(&data->_butlp0);
    sp_butlp_destroy(&data->_butlp1);
}

void AKLowPassButterworthFilterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->cutoffFrequencyRamp.advanceTo(_now + frameOffset);
        }

        data->_butlp0->freq = data->cutoffFrequencyRamp.getValue();
        data->_butlp1->freq = data->cutoffFrequencyRamp.getValue();

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
                sp_butlp_compute(_sp, data->_butlp0, in, out);
            } else {
                sp_butlp_compute(_sp, data->_butlp1, in, out);
            }
        }
    }
}
