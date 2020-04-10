// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(AUParameterAddress, AKTremoloParameter) {
    AKTremoloParameterFrequency,
    AKTremoloParameterDepth,
    AKTremoloParameterRampDuration
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

AKDSPRef createTremoloDSP(void);

#else

#import "AKSoundpipeDSPBase.hpp"
#import <vector>

class AKTremoloDSP : public AKSoundpipeDSPBase {

    sp_osc *trem;
    sp_ftbl *tbl;
    std::vector<float> wavetable;

private:
    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp depthRamp;
   
public:
    AKTremoloDSP() {
        frequencyRamp.setTarget(10.0, true);
        frequencyRamp.setDurationInSamples(10000);
        depthRamp.setTarget(1.0, true);
        depthRamp.setDurationInSamples(10000);
    }

    /// Uses the ParameterAddress as a key
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKTremoloParameterFrequency:
                frequencyRamp.setTarget(value, immediate);
                break;
            case AKTremoloParameterDepth:
                depthRamp.setTarget(value, immediate);
                break;
            case AKTremoloParameterRampDuration:
                frequencyRamp.setRampDuration(value, sampleRate);
                depthRamp.setRampDuration(value, sampleRate);
                break;
        }
    }

    /// Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKTremoloParameterFrequency:
                return frequencyRamp.getTarget();
            case AKTremoloParameterDepth:
                return depthRamp.getTarget();
            case AKTremoloParameterRampDuration:
                return frequencyRamp.getRampDuration(sampleRate);
                return depthRamp.getRampDuration(sampleRate);
        }
        return 0;
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_ftbl_create(sp, &tbl, wavetable.size());
        std::copy(wavetable.cbegin(), wavetable.cend(), tbl->tbl);
        sp_osc_create(&trem);
        sp_osc_init(sp, trem, tbl, 0);
        trem->freq = 10.0;
        trem->amp = 1.0;
    }

    void setupWaveform(uint32_t size) override {
        wavetable.resize(size);
    }

    void setWaveformValue(uint32_t index, float value) override {
        wavetable[index] = value;
    }

    void deinit() override {
        AKSoundpipeDSPBase::deinit();
        sp_osc_destroy(&trem);
        sp_ftbl_destroy(&tbl);
    }

    void process(uint32_t frameCount, uint32_t bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                frequencyRamp.advanceTo(now + frameOffset);
                depthRamp.advanceTo(now + frameOffset);
            }
            trem->freq = frequencyRamp.getValue()  * 0.5; //Divide by two for stereo
            trem->amp = depthRamp.getValue();

            float temp = 0;
            for (int channel = 0; channel < channelCount; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (isStarted) {
                    sp_osc_compute(sp, trem, NULL, &temp);
                    *out = *in * (1.0 - temp);
                } else {
                    *out = *in;
                }
            }
        }
    }
};

#endif
