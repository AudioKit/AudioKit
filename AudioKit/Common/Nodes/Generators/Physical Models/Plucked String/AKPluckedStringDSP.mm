// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKPluckedStringDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createPluckedStringDSP() {
    return new AKPluckedStringDSP();
}

struct AKPluckedStringDSP::InternalData {
    sp_pluck *pluck;
    float internalTrigger = 0;
    ParameterRamper frequencyRamp;
    ParameterRamper amplitudeRamp;
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
    data->frequencyRamp.setImmediate(freq);
    data->amplitudeRamp.setImmediate(amp);
    trigger();
}

void AKPluckedStringDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        data->pluck->freq = data->frequencyRamp.getAndStep();
        data->pluck->amp = data->amplitudeRamp.getAndStep();

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
