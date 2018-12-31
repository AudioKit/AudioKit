//
//  AKBitCrusherDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKBitCrusherDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createBitCrusherDSP(int nChannels, double sampleRate) {
    AKBitCrusherDSP *dsp = new AKBitCrusherDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKBitCrusherDSP::InternalData {
    sp_bitcrush *_bitcrush0;
    sp_bitcrush *_bitcrush1;
    AKLinearParameterRamp bitDepthRamp;
    AKLinearParameterRamp sampleRateRamp;
};

AKBitCrusherDSP::AKBitCrusherDSP() : data(new InternalData) {
    data->bitDepthRamp.setTarget(defaultBitDepth, true);
    data->bitDepthRamp.setDurationInSamples(defaultRampDurationSamples);
    data->sampleRateRamp.setTarget(defaultSampleRate, true);
    data->sampleRateRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKBitCrusherDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKBitCrusherParameterBitDepth:
            data->bitDepthRamp.setTarget(clamp(value, bitDepthLowerBound, bitDepthUpperBound), immediate);
            break;
        case AKBitCrusherParameterSampleRate:
            data->sampleRateRamp.setTarget(clamp(value, sampleRateLowerBound, sampleRateUpperBound), immediate);
            break;
        case AKBitCrusherParameterRampDuration:
            data->bitDepthRamp.setRampDuration(value, _sampleRate);
            data->sampleRateRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKBitCrusherDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKBitCrusherParameterBitDepth:
            return data->bitDepthRamp.getTarget();
        case AKBitCrusherParameterSampleRate:
            return data->sampleRateRamp.getTarget();
        case AKBitCrusherParameterRampDuration:
            return data->bitDepthRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKBitCrusherDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_bitcrush_create(&data->_bitcrush0);
    sp_bitcrush_init(_sp, data->_bitcrush0);
    sp_bitcrush_create(&data->_bitcrush1);
    sp_bitcrush_init(_sp, data->_bitcrush1);
    data->_bitcrush0->bitdepth = defaultBitDepth;
    data->_bitcrush1->bitdepth = defaultBitDepth;
    data->_bitcrush0->srate = defaultSampleRate;
    data->_bitcrush1->srate = defaultSampleRate;
}

void AKBitCrusherDSP::deinit() {
    sp_bitcrush_destroy(&data->_bitcrush0);
    sp_bitcrush_destroy(&data->_bitcrush1);
}

void AKBitCrusherDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->bitDepthRamp.advanceTo(_now + frameOffset);
            data->sampleRateRamp.advanceTo(_now + frameOffset);
        }

        data->_bitcrush0->bitdepth = data->bitDepthRamp.getValue();
        data->_bitcrush1->bitdepth = data->bitDepthRamp.getValue();
        data->_bitcrush0->srate = data->sampleRateRamp.getValue();
        data->_bitcrush1->srate = data->sampleRateRamp.getValue();

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
                sp_bitcrush_compute(_sp, data->_bitcrush0, in, out);
            } else {
                sp_bitcrush_compute(_sp, data->_bitcrush1, in, out);
            }
        }
    }
}
