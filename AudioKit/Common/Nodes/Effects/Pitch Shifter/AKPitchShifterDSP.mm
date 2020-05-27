// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKPitchShifterDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createPitchShifterDSP() {
    return new AKPitchShifterDSP();
}

struct AKPitchShifterDSP::InternalData {
    sp_pshift *pshift0;
    sp_pshift *pshift1;
    ParameterRamper shiftRamp;
    ParameterRamper windowSizeRamp;
    ParameterRamper crossfadeRamp;
};

AKPitchShifterDSP::AKPitchShifterDSP() : data(new InternalData) {
    parameters[AKPitchShifterParameterShift] = &data->shiftRamp;
    parameters[AKPitchShifterParameterWindowSize] = &data->windowSizeRamp;
    parameters[AKPitchShifterParameterCrossfade] = &data->crossfadeRamp;
}

void AKPitchShifterDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_pshift_create(&data->pshift0);
    sp_pshift_init(sp, data->pshift0);
    sp_pshift_create(&data->pshift1);
    sp_pshift_init(sp, data->pshift1);
}

void AKPitchShifterDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_pshift_destroy(&data->pshift0);
    sp_pshift_destroy(&data->pshift1);
}

void AKPitchShifterDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_pshift_init(sp, data->pshift0);
    sp_pshift_init(sp, data->pshift1);
}

void AKPitchShifterDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        float shift = data->shiftRamp.getAndStep();
        float windowSize = data->windowSizeRamp.getAndStep();
        float crossfade = data->crossfadeRamp.getAndStep();
        *data->pshift0->shift = shift;
        *data->pshift1->shift = shift;
        *data->pshift0->window = windowSize;
        *data->pshift1->window = windowSize;
        *data->pshift0->xfade = crossfade;
        *data->pshift1->xfade = crossfade;

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < channelCount; ++channel) {
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

            if (channel == 0) {
                sp_pshift_compute(sp, data->pshift0, in, out);
            } else {
                sp_pshift_compute(sp, data->pshift1, in, out);
            }
        }
    }
}
