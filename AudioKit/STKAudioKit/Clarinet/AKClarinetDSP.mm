// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKClarinetDSP.hpp"
#import <AudioKit/AKLinearParameterRamp.hpp>

#include "Clarinet.h"

class AKClarinetDSP : public AKDSPBase {
private:
    float internalTrigger = 0;
    stk::Clarinet *clarinet;
    
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp amplitudeRamp;
    AKLinearParameterRamp detuningOffsetRamp;
    AKLinearParameterRamp detuningMultiplierRamp;
    
public:
    AKClarinetDSP() {
        frequencyRamp.setTarget(440, true);
        frequencyRamp.setDurationInSamples(10000);
        amplitudeRamp.setTarget(1, true);
        amplitudeRamp.setDurationInSamples(10000);
    }
    
    ~AKClarinetDSP() = default;
    
    
    /// Uses the ParameterAddress as a key
    void setParameter(AUParameterAddress address, float value, bool immediate)  {
        switch (address) {
            case AKClarinetParameterFrequency:
                frequencyRamp.setTarget(value, immediate);
                break;
            case AKClarinetParameterAmplitude:
                amplitudeRamp.setTarget(value, immediate);
                break;
            case AKClarinetParameterRampDuration:
                frequencyRamp.setRampDuration(value, sampleRate);
                amplitudeRamp.setRampDuration(value, sampleRate);
                break;
        }
    }
    
    /// Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address)  {
        switch (address) {
            case AKClarinetParameterFrequency:
                return frequencyRamp.getTarget();
            case AKClarinetParameterAmplitude:
                return amplitudeRamp.getTarget();
            case AKClarinetParameterRampDuration:
                return frequencyRamp.getRampDuration(sampleRate);
        }
        return 0;
    }
    
    void init(int channelCount, double sampleRate)  {
        AKDSPBase::init(channelCount, sampleRate);
        
        stk::Stk::setSampleRate(sampleRate);
        clarinet = new stk::Clarinet(100);
    }
    
    void trigger() {
        internalTrigger = 1;
    }
    
    void triggerFrequencyAmplitude(AUValue freq, AUValue amp)  {
        bool immediate = true;
        frequencyRamp.setTarget(freq, immediate);
        amplitudeRamp.setTarget(amp, immediate);
        trigger();
    }
    
    void deinit() {
        AKDSPBase::deinit();
        delete clarinet;
    }
    
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
        
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);
            
            // do ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                frequencyRamp.advanceTo(now + frameOffset);
                amplitudeRamp.advanceTo(now + frameOffset);
            }
            float frequency = frequencyRamp.getValue();
            float amplitude = amplitudeRamp.getValue();
            
            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;
                
                if (isStarted) {
                    if (internalTrigger == 1) {
                        clarinet->noteOn(frequency, amplitude);
                    }
                    *out = clarinet->tick();
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

extern "C" AKDSPRef createClarinetDSP() {
    return new AKClarinetDSP();
}

