//
//  AKPitchShifterDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKPitchShifterDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createPitchShifterDSP(int channelCount, double sampleRate) {
    AKPitchShifterDSP *dsp = new AKPitchShifterDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKPitchShifterDSP::InternalData {
    sp_pshift *pshift0;
    sp_pshift *pshift1;
    AKLinearParameterRamp shiftRamp;
    AKLinearParameterRamp windowSizeRamp;
    AKLinearParameterRamp crossfadeRamp;
};

AKPitchShifterDSP::AKPitchShifterDSP() : data(new InternalData) {
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
            data->shiftRamp.setRampDuration(value, sampleRate);
            data->windowSizeRamp.setRampDuration(value, sampleRate);
            data->crossfadeRamp.setRampDuration(value, sampleRate);
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
            return data->shiftRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKPitchShifterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_pshift_create(&data->pshift0);
    sp_pshift_init(sp, data->pshift0);
    sp_pshift_create(&data->pshift1);
    sp_pshift_init(sp, data->pshift1);
    *data->pshift0->shift = defaultShift;
    *data->pshift1->shift = defaultShift;
    *data->pshift0->window = defaultWindowSize;
    *data->pshift1->window = defaultWindowSize;
    *data->pshift0->xfade = defaultCrossfade;
    *data->pshift1->xfade = defaultCrossfade;
}

void AKPitchShifterDSP::deinit() {
    sp_pshift_destroy(&data->pshift0);
    sp_pshift_destroy(&data->pshift1);
}

void AKPitchShifterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->shiftRamp.advanceTo(now + frameOffset);
            data->windowSizeRamp.advanceTo(now + frameOffset);
            data->crossfadeRamp.advanceTo(now + frameOffset);
        }

        *data->pshift0->shift = data->shiftRamp.getValue();
        *data->pshift1->shift = data->shiftRamp.getValue();
        *data->pshift0->window = data->windowSizeRamp.getValue();
        *data->pshift1->window = data->windowSizeRamp.getValue();
        *data->pshift0->xfade = data->crossfadeRamp.getValue();
        *data->pshift1->xfade = data->crossfadeRamp.getValue();

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < channelCount; ++channel) {
            float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
            if (channel < 2) {
                tmpin[channel] = in;
                tmpout[channel] = out;
            }
            if (!isStarted) {
                *out = *in;
                continue;
            }

            if (channel == 0) {
                sp_pshift_compute(sp, data->pshift0, in, out);
            } else {
                sp_pshift_compute(sp, data->pshift1, in, out);
            }
        }
    }
}
