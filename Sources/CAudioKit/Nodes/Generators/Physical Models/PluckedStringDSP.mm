// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

enum PluckedStringParameter : AUParameterAddress {
    PluckedStringParameterFrequency,
    PluckedStringParameterAmplitude,
};

class PluckedStringDSP : public SoundpipeDSPBase {
private:
    sp_pluck *pluck;
    float internalTrigger = 0;
    ParameterRamper frequencyRamp;
    ParameterRamper amplitudeRamp;

public:
    PluckedStringDSP() : SoundpipeDSPBase(/*inputBusCount*/0) {
        parameters[PluckedStringParameterFrequency] = &frequencyRamp;
        parameters[PluckedStringParameterAmplitude] = &amplitudeRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_pluck_create(&pluck);
        sp_pluck_init(sp, pluck, 110);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_pluck_destroy(&pluck);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_pluck_init(sp, pluck, 110);
    }

    void trigger() override {
        internalTrigger = 1;
    }

    void triggerFrequencyAmplitude(float frequency, float amplitude) override {
        internalTrigger = 1;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            pluck->freq = frequencyRamp.getAndStep();
            pluck->amp = amplitudeRamp.getAndStep();

            float temp = 0;
            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;

                if (isStarted) {
                    if (channel == 0) {
                        sp_pluck_compute(sp, pluck, &internalTrigger, &temp);
                    }
                    *out = temp;
                } else {
                    *out = 0.0;
                }
            }
        }
        if (internalTrigger == 1) {
            internalTrigger = 0;
        }
    }
};

AK_REGISTER_DSP(PluckedStringDSP)
AK_REGISTER_PARAMETER(PluckedStringParameterFrequency)
AK_REGISTER_PARAMETER(PluckedStringParameterAmplitude)
