//
//  AKStringResonatorDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKStringResonatorDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createStringResonatorDSP(int nChannels, double sampleRate) {
    AKStringResonatorDSP *dsp = new AKStringResonatorDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKStringResonatorDSP::InternalData {
    sp_streson *_streson0;
    sp_streson *_streson1;
    AKLinearParameterRamp fundamentalFrequencyRamp;
    AKLinearParameterRamp feedbackRamp;
};

AKStringResonatorDSP::AKStringResonatorDSP() : data(new InternalData) {
    data->fundamentalFrequencyRamp.setTarget(defaultFundamentalFrequency, true);
    data->fundamentalFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->feedbackRamp.setTarget(defaultFeedback, true);
    data->feedbackRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKStringResonatorDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKStringResonatorParameterFundamentalFrequency:
            data->fundamentalFrequencyRamp.setTarget(clamp(value, fundamentalFrequencyLowerBound, fundamentalFrequencyUpperBound), immediate);
            break;
        case AKStringResonatorParameterFeedback:
            data->feedbackRamp.setTarget(clamp(value, feedbackLowerBound, feedbackUpperBound), immediate);
            break;
        case AKStringResonatorParameterRampDuration:
            data->fundamentalFrequencyRamp.setRampDuration(value, _sampleRate);
            data->feedbackRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKStringResonatorDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKStringResonatorParameterFundamentalFrequency:
            return data->fundamentalFrequencyRamp.getTarget();
        case AKStringResonatorParameterFeedback:
            return data->feedbackRamp.getTarget();
        case AKStringResonatorParameterRampDuration:
            return data->fundamentalFrequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKStringResonatorDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_streson_create(&data->_streson0);
    sp_streson_init(_sp, data->_streson0);
    sp_streson_create(&data->_streson1);
    sp_streson_init(_sp, data->_streson1);
    data->_streson0->freq = defaultFundamentalFrequency;
    data->_streson1->freq = defaultFundamentalFrequency;
    data->_streson0->fdbgain = defaultFeedback;
    data->_streson1->fdbgain = defaultFeedback;
}

void AKStringResonatorDSP::deinit() {
    sp_streson_destroy(&data->_streson0);
    sp_streson_destroy(&data->_streson1);
}

void AKStringResonatorDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->fundamentalFrequencyRamp.advanceTo(_now + frameOffset);
            data->feedbackRamp.advanceTo(_now + frameOffset);
        }

        data->_streson0->freq = data->fundamentalFrequencyRamp.getValue();
        data->_streson1->freq = data->fundamentalFrequencyRamp.getValue();
        data->_streson0->fdbgain = data->feedbackRamp.getValue();
        data->_streson1->fdbgain = data->feedbackRamp.getValue();

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
                sp_streson_compute(_sp, data->_streson0, in, out);
            } else {
                sp_streson_compute(_sp, data->_streson1, in, out);
            }
        }
    }
}
