// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKPluckedStringDSP.hpp"
#include "ParameterRamper.hpp"

#import "AKSoundpipeDSPBase.hpp"

class AKPluckedStringDSP : public AKSoundpipeDSPBase {
private:
    sp_pluck *pluck;
    float internalTrigger = 0;
    ParameterRamper frequencyRamp;
    ParameterRamper amplitudeRamp;
    
public:
    AKPluckedStringDSP() {
        parameters[AKPluckedStringParameterFrequency] = &frequencyRamp;
        parameters[AKPluckedStringParameterAmplitude] = &amplitudeRamp;
    }
    
    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_pluck_create(&pluck);
        sp_pluck_init(sp, pluck, 110);
    }
    
    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_pluck_destroy(&pluck);
    }
    
    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_pluck_init(sp, pluck, 110);
    }
    
    void trigger() {
        internalTrigger = 1;
    }
    
    void triggerFrequencyAmplitude(AUValue freq, AUValue amp) {
        frequencyRamp.setImmediate(freq);
        amplitudeRamp.setImmediate(amp);
        trigger();
    }
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);
            
            pluck->freq = frequencyRamp.getAndStep();
            pluck->amp = amplitudeRamp.getAndStep();
            
            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;
                
                if (isStarted) {
                    if (channel == 0) {
                        sp_pluck_compute(sp, pluck, &internalTrigger, out);
                    }
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

extern "C" AKDSPRef createPluckedStringDSP() {
    return new AKPluckedStringDSP();
}
