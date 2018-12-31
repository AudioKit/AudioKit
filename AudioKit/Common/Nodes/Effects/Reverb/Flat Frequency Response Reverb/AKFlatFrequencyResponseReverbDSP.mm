//
//  AKFlatFrequencyResponseReverbDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKFlatFrequencyResponseReverbDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createFlatFrequencyResponseReverbDSP(int nChannels, double sampleRate) {
    AKFlatFrequencyResponseReverbDSP *dsp = new AKFlatFrequencyResponseReverbDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKFlatFrequencyResponseReverbDSP::InternalData {
    sp_allpass *_allpass0;
    sp_allpass *_allpass1;
    float _loopDuration = 0.1;
    AKLinearParameterRamp reverbDurationRamp;
};

void AKFlatFrequencyResponseReverbDSP::initializeConstant(float duration) {
    data->_loopDuration = duration;
}


AKFlatFrequencyResponseReverbDSP::AKFlatFrequencyResponseReverbDSP() : data(new InternalData) {
    data->reverbDurationRamp.setTarget(defaultReverbDuration, true);
    data->reverbDurationRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKFlatFrequencyResponseReverbDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKFlatFrequencyResponseReverbParameterReverbDuration:
            data->reverbDurationRamp.setTarget(clamp(value, reverbDurationLowerBound, reverbDurationUpperBound), immediate);
            break;
        case AKFlatFrequencyResponseReverbParameterRampDuration:
            data->reverbDurationRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKFlatFrequencyResponseReverbDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKFlatFrequencyResponseReverbParameterReverbDuration:
            return data->reverbDurationRamp.getTarget();
        case AKFlatFrequencyResponseReverbParameterRampDuration:
            return data->reverbDurationRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKFlatFrequencyResponseReverbDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_allpass_create(&data->_allpass0);
    sp_allpass_create(&data->_allpass1);
    sp_allpass_init(_sp, data->_allpass0, data->_loopDuration);
    sp_allpass_init(_sp, data->_allpass1, data->_loopDuration);
    data->_allpass0->revtime = defaultReverbDuration;
    data->_allpass1->revtime = defaultReverbDuration;

}

void AKFlatFrequencyResponseReverbDSP::deinit() {
    sp_allpass_destroy(&data->_allpass0);
    sp_allpass_destroy(&data->_allpass1);
}

void AKFlatFrequencyResponseReverbDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->reverbDurationRamp.advanceTo(_now + frameOffset);
        }

        data->_allpass0->revtime = data->reverbDurationRamp.getValue();
        data->_allpass1->revtime = data->reverbDurationRamp.getValue();

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
                sp_allpass_compute(_sp, data->_allpass0, in, out);
            } else {
                sp_allpass_compute(_sp, data->_allpass1, in, out);
            }
        }

    }
}
