// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKFluteDSP.hpp"
#import <AudioKit/AKLinearParameterRamp.hpp>

#include "Flute.h"

class AKFluteDSP : public AKDSPBase {
private:
    float internalTrigger = 0;
    stk::Flute *flute;

    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp amplitudeRamp;
    AKLinearParameterRamp detuningOffsetRamp;
    AKLinearParameterRamp detuningMultiplierRamp;

public:
    AKFluteDSP() {
        frequencyRamp.setTarget(440, true);
        frequencyRamp.setDurationInSamples(10000);
        amplitudeRamp.setTarget(1, true);
        amplitudeRamp.setDurationInSamples(10000);
    }

    ~AKFluteDSP() = default;

    /// Uses the ParameterAddress as a key
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKFluteParameterFrequency:
                frequencyRamp.setTarget(value, immediate);
                break;
            case AKFluteParameterAmplitude:
                amplitudeRamp.setTarget(value, immediate);
                break;
            case AKFluteParameterRampDuration:
                frequencyRamp.setRampDuration(value, sampleRate);
                amplitudeRamp.setRampDuration(value, sampleRate);
                break;
        }
    }

    /// Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKFluteParameterFrequency:
                return frequencyRamp.getTarget();
            case AKFluteParameterAmplitude:
                return amplitudeRamp.getTarget();
            case AKFluteParameterRampDuration:
                return frequencyRamp.getRampDuration(sampleRate);
        }
        return 0;
    }

    void init(int channelCount, double sampleRate) override {
        AKDSPBase::init(channelCount, sampleRate);

        stk::Stk::setSampleRate(sampleRate);
        flute = new stk::Flute(100);
    }

    void trigger() override {
        internalTrigger = 1;
    }

    void triggerFrequencyAmplitude(AUValue freq, AUValue amp) override {
        bool immediate = true;
        frequencyRamp.setTarget(freq, immediate);
        amplitudeRamp.setTarget(amp, immediate);
        trigger();
    }

    void deinit() override {
        AKDSPBase::deinit();
        delete flute;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        float frequency = frequencyRamp.getValue();
        float amplitude = amplitudeRamp.getValue();

        if (internalTrigger == 1) {
            flute->noteOn(frequency, amplitude);
            internalTrigger = 0;
        }

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                frequencyRamp.advanceTo(now + frameOffset);
                amplitudeRamp.advanceTo(now + frameOffset);
            }

            float outputSample = 0.0;
            if(isStarted) {
                outputSample = flute->tick();
            }

            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;
                *out = outputSample;
            }
        }
    }

};

AK_REGISTER_DSP(AKFluteDSP);

