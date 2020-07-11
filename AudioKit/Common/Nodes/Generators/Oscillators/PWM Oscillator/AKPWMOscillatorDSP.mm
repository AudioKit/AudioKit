// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKPWMOscillatorDSP.hpp"
#import "ParameterRamper.hpp"

#import "AKSoundpipeDSPBase.hpp"

class AKPWMOscillatorDSP : public AKSoundpipeDSPBase {
private:
    sp_blsquare *blsquare;
    ParameterRamper frequencyRamp;
    ParameterRamper amplitudeRamp;
    ParameterRamper pulseWidthRamp;
    ParameterRamper detuningOffsetRamp;
    ParameterRamper detuningMultiplierRamp;

public:
    AKPWMOscillatorDSP() {
        parameters[AKPWMOscillatorParameterFrequency] = &frequencyRamp;
        parameters[AKPWMOscillatorParameterAmplitude] = &amplitudeRamp;
        parameters[AKPWMOscillatorParameterPulseWidth] = &pulseWidthRamp;
        parameters[AKPWMOscillatorParameterDetuningOffset] = &detuningOffsetRamp;
        parameters[AKPWMOscillatorParameterDetuningMultiplier] = &detuningMultiplierRamp;
    }

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        isStarted = false;
        sp_blsquare_create(&blsquare);
        sp_blsquare_init(sp, blsquare);
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_blsquare_destroy(&blsquare);
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        isStarted = false;
        sp_blsquare_init(sp, blsquare);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float frequency = frequencyRamp.getAndStep();
            float amplitude = amplitudeRamp.getAndStep();
            float pulseWidth = pulseWidthRamp.getAndStep();
            float detuningOffset = detuningOffsetRamp.getAndStep();
            float detuningMultiplier = detuningMultiplierRamp.getAndStep();

            *blsquare->freq = frequency * detuningMultiplier + detuningOffset;
            *blsquare->amp = amplitude;
            *blsquare->width = pulseWidth;

            float temp = 0;
            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

                if (isStarted) {
                    if (channel == 0) {
                        sp_blsquare_compute(sp, blsquare, nil, &temp);
                    }
                    *out = temp;
                } else {
                    *out = 0.0;
                }
            }
        }
    }

};

extern "C" AKDSPRef createPWMOscillatorDSP() {
    return new AKPWMOscillatorDSP();
}
