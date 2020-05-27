// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKPWMOscillatorDSP.hpp"
#import "ParameterRamper.hpp"

// "Constructor" function for interop with Swift

extern "C" AKDSPRef createPWMOscillatorDSP() {
    return new AKPWMOscillatorDSP();
}

struct AKPWMOscillatorDSP::InternalData {
    sp_blsquare *blsquare;
    ParameterRamper frequencyRamp;
    ParameterRamper amplitudeRamp;
    ParameterRamper pulseWidthRamp;
    ParameterRamper detuningOffsetRamp;
    ParameterRamper detuningMultiplierRamp;
};

AKPWMOscillatorDSP::AKPWMOscillatorDSP() : data(new InternalData) {
    parameters[AKPWMOscillatorParameterFrequency] = &data->frequencyRamp;
    parameters[AKPWMOscillatorParameterAmplitude] = &data->amplitudeRamp;
    parameters[AKPWMOscillatorParameterPulseWidth] = &data->pulseWidthRamp;
    parameters[AKPWMOscillatorParameterDetuningOffset] = &data->detuningOffsetRamp;
    parameters[AKPWMOscillatorParameterDetuningMultiplier] = &data->detuningMultiplierRamp;
}

void AKPWMOscillatorDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    isStarted = false;
    sp_blsquare_create(&data->blsquare);
    sp_blsquare_init(sp, data->blsquare);
}

void AKPWMOscillatorDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_blsquare_destroy(&data->blsquare);
}

void AKPWMOscillatorDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    isStarted = false;
    sp_blsquare_init(sp, data->blsquare);
}

void AKPWMOscillatorDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);
        
        float frequency = data->frequencyRamp.getAndStep();
        float amplitude = data->amplitudeRamp.getAndStep();
        float pulseWidth = data->pulseWidthRamp.getAndStep();
        float detuningOffset = data->detuningOffsetRamp.getAndStep();
        float detuningMultiplier = data->detuningMultiplierRamp.getAndStep();
        
        *data->blsquare->freq = frequency * detuningMultiplier + detuningOffset;
        *data->blsquare->amp = amplitude;
        *data->blsquare->width = pulseWidth;

        float temp = 0;
        for (int channel = 0; channel < channelCount; ++channel) {
            float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;

            if (isStarted) {
                if (channel == 0) {
                    sp_blsquare_compute(sp, data->blsquare, nil, &temp);
                }
                *out = temp;
            } else {
                *out = 0.0;
            }
        }
    }
}
