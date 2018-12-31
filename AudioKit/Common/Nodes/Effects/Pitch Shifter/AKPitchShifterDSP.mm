//
//  AKPitchShifterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKPitchShifterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createPitchShifterDSP(int nChannels, double sampleRate) {
    AKPitchShifterDSP *dsp = new AKPitchShifterDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

struct AKPitchShifterDSP::_Internal {
    sp_pshift *_pshift0;
    sp_pshift *_pshift1;
    AKLinearParameterRamp shiftRamp;
    AKLinearParameterRamp windowSizeRamp;
    AKLinearParameterRamp crossfadeRamp;
};

AKPitchShifterDSP::AKPitchShifterDSP() : data(new _Internal) {
    data->shiftRamp.setTarget(defaultShift, true);
    data->shiftRamp.setDurationInSamples(defaultRampDurationSamples);
    data->windowSizeRamp.setTarget(defaultWindowSize, true);
    data->windowSizeRamp.setDurationInSamples(defaultRampDurationSamples);
    data->crossfadeRamp.setTarget(defaultCrossfade, true);
    data->crossfadeRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKPitchShifterDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKPitchShifterParameterShift:
            data->shiftRamp.setTarget(clamp(value, shiftLowerBound, shiftUpperBound), immediate);
            break;
        case AKPitchShifterParameterWindowSize:
            data->windowSizeRamp.setTarget(clamp(value, windowSizeLowerBound, windowSizeUpperBound), immediate);
            break;
        case AKPitchShifterParameterCrossfade:
            data->crossfadeRamp.setTarget(clamp(value, crossfadeLowerBound, crossfadeUpperBound), immediate);
            break;
        case AKPitchShifterParameterRampDuration:
            data->shiftRamp.setRampDuration(value, _sampleRate);
            data->windowSizeRamp.setRampDuration(value, _sampleRate);
            data->crossfadeRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKPitchShifterDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKPitchShifterParameterShift:
            return data->shiftRamp.getTarget();
        case AKPitchShifterParameterWindowSize:
            return data->windowSizeRamp.getTarget();
        case AKPitchShifterParameterCrossfade:
            return data->crossfadeRamp.getTarget();
        case AKPitchShifterParameterRampDuration:
            return data->shiftRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKPitchShifterDSP::init(int _channels, double _sampleRate) {
    AKSoundpipeDSPBase::init(_channels, _sampleRate);
    sp_pshift_create(&data->_pshift0);
    sp_pshift_init(_sp, data->_pshift0);
    sp_pshift_create(&data->_pshift1);
    sp_pshift_init(_sp, data->_pshift1);
    *data->_pshift0->shift = defaultShift;
    *data->_pshift1->shift = defaultShift;
    *data->_pshift0->window = defaultWindowSize;
    *data->_pshift1->window = defaultWindowSize;
    *data->_pshift0->xfade = defaultCrossfade;
    *data->_pshift1->xfade = defaultCrossfade;
}

void AKPitchShifterDSP::deinit() {
    sp_pshift_destroy(&data->_pshift0);
    sp_pshift_destroy(&data->_pshift1);
}

void AKPitchShifterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->shiftRamp.advanceTo(_now + frameOffset);
            data->windowSizeRamp.advanceTo(_now + frameOffset);
            data->crossfadeRamp.advanceTo(_now + frameOffset);
        }

        *data->_pshift0->shift = data->shiftRamp.getValue();
        *data->_pshift1->shift = data->shiftRamp.getValue();
        *data->_pshift0->window = data->windowSizeRamp.getValue();
        *data->_pshift1->window = data->windowSizeRamp.getValue();
        *data->_pshift0->xfade = data->crossfadeRamp.getValue();
        *data->_pshift1->xfade = data->crossfadeRamp.getValue();

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
                sp_pshift_compute(_sp, data->_pshift0, in, out);
            } else {
                sp_pshift_compute(_sp, data->_pshift1, in, out);
            }
        }
    }
}
