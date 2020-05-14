// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKPluckedStringDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createPluckedStringDSP() {
    return new AKPluckedStringDSP();
}

struct AKPluckedStringDSP::InternalData {
    sp_pluck *pluck;
    float internalTrigger = 0;
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp amplitudeRamp;
};

AKPluckedStringDSP::AKPluckedStringDSP() : data(new InternalData) {
    parameters[AKPluckedStringParameterFrequency] = &data->frequencyRamp;
    parameters[AKPluckedStringParameterAmplitude] = &data->amplitudeRamp;
}

void AKPluckedStringDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_pluck_create(&data->pluck);
    sp_pluck_init(sp, data->pluck, 110);
}

void AKPluckedStringDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_pluck_destroy(&data->pluck);
}

void AKPluckedStringDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_pluck_init(sp, data->pluck, 110);
}

void AKPluckedStringDSP::trigger() {
    data->internalTrigger = 1;
}

void AKPluckedStringDSP::triggerFrequencyAmplitude(AUValue freq, AUValue amp) {
    data->frequencyRamp.setTarget(freq, true);
    data->amplitudeRamp.setTarget(amp, true);
    trigger();
}

void AKPluckedStringDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->frequencyRamp.advanceTo(now + frameOffset);
            data->amplitudeRamp.advanceTo(now + frameOffset);
        }

        data->pluck->freq = data->frequencyRamp.getValue();
        data->pluck->amp = data->amplitudeRamp.getValue();

        for (int channel = 0; channel < channelCount; ++channel) {
            float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

            if (isStarted) {
                if (channel == 0) {
                    sp_pluck_compute(sp, data->pluck, &data->internalTrigger, out);
                }
            } else {
                *out = 0.0;
            }
        }
    }
    if (data->internalTrigger == 1) {
        data->internalTrigger = 0;
    }
}
