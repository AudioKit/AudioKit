//
//  AKVariableDelayDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKVariableDelayDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createVariableDelayDSP(int nChannels, double sampleRate) {
    AKVariableDelayDSP *dsp = new AKVariableDelayDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKVariableDelayDSP::_Internal {
    sp_vdelay *_vdelay0;
    sp_vdelay *_vdelay1;
    AKLinearParameterRamp timeRamp;
    AKLinearParameterRamp feedbackRamp;
};

AKVariableDelayDSP::AKVariableDelayDSP() : data(new _Internal) {
    data->timeRamp.setTarget(defaultTime, true);
    data->timeRamp.setDurationInSamples(defaultRampDurationSamples);
    data->feedbackRamp.setTarget(defaultFeedback, true);
    data->feedbackRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKVariableDelayDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKVariableDelayParameterTime:
            data->timeRamp.setTarget(clamp(value, timeLowerBound, timeUpperBound), immediate);
            break;
        case AKVariableDelayParameterFeedback:
            data->feedbackRamp.setTarget(clamp(value, feedbackLowerBound, feedbackUpperBound), immediate);
            break;
        case AKVariableDelayParameterRampDuration:
            data->timeRamp.setRampDuration(value, _sampleRate);
            data->feedbackRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKVariableDelayDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKVariableDelayParameterTime:
            return data->timeRamp.getTarget();
        case AKVariableDelayParameterFeedback:
            return data->feedbackRamp.getTarget();
        case AKVariableDelayParameterRampDuration:
            return data->timeRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKVariableDelayDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_vdelay_create(&data->_vdelay0);
    sp_vdelay_init(_sp, data->_vdelay0, 10);
    sp_vdelay_create(&data->_vdelay1);
    sp_vdelay_init(_sp, data->_vdelay1, 10);
    data->_vdelay0->del = defaultTime;
    data->_vdelay1->del = defaultTime;
    data->_vdelay0->feedback = defaultFeedback;
    data->_vdelay1->feedback = defaultFeedback;
}

void AKVariableDelayDSP::deinit() {
    sp_vdelay_destroy(&data->_vdelay0);
    sp_vdelay_destroy(&data->_vdelay1);
}

void AKVariableDelayDSP::clear() {
    sp_vdelay_reset(_sp, data->_vdelay0);
    sp_vdelay_reset(_sp, data->_vdelay1);
}

void AKVariableDelayDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->timeRamp.advanceTo(_now + frameOffset);
            data->feedbackRamp.advanceTo(_now + frameOffset);
        }

        data->_vdelay0->del = data->timeRamp.getValue();
        data->_vdelay1->del = data->timeRamp.getValue();
        data->_vdelay0->feedback = data->feedbackRamp.getValue();
        data->_vdelay1->feedback = data->feedbackRamp.getValue();

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
                sp_vdelay_compute(_sp, data->_vdelay0, in, out);
            } else {
                sp_vdelay_compute(_sp, data->_vdelay1, in, out);
            }
        }
    }
}
