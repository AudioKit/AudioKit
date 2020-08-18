// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"

enum AKPitchShifterParameter : AUParameterAddress {
    AKPitchShifterParameterShift,
    AKPitchShifterParameterWindowSize,
    AKPitchShifterParameterCrossfade,
};

class AKPitchShifterDSP : public AKSoundpipeDSPBase {
private:
    sp_pshift *pshift0;
    sp_pshift *pshift1;
    ParameterRamper shiftRamp;
    ParameterRamper windowSizeRamp;
    ParameterRamper crossfadeRamp;

public:
    AKPitchShifterDSP() {
        parameters[AKPitchShifterParameterShift] = &shiftRamp;
        parameters[AKPitchShifterParameterWindowSize] = &windowSizeRamp;
        parameters[AKPitchShifterParameterCrossfade] = &crossfadeRamp;
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_pshift_create(&pshift0);
        sp_pshift_init(sp, pshift0);
        sp_pshift_create(&pshift1);
        sp_pshift_init(sp, pshift1);
    }

    void deinit() override {
        AKSoundpipeDSPBase::deinit();
        sp_pshift_destroy(&pshift0);
        sp_pshift_destroy(&pshift1);
    }

    void reset() override {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_pshift_init(sp, pshift0);
        sp_pshift_init(sp, pshift1);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float shift = shiftRamp.getAndStep();
            float windowSize = windowSizeRamp.getAndStep();
            float crossfade = crossfadeRamp.getAndStep();

            *pshift0->shift = shift;
            *pshift1->shift = shift;
            *pshift0->window = windowSize;
            *pshift1->window = windowSize;
            *pshift0->xfade = crossfade;
            *pshift1->xfade = crossfade;

            float *tmpin[2];
            float *tmpout[2];
            for (int channel = 0; channel < channelCount; ++channel) {
                float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;
                if (channel < 2) {
                    tmpin[channel] = in;
                    tmpout[channel] = out;
                }
                if (!isStarted) {
                    *out = *in;
                    continue;
                }

                if (channel == 0) {
                    sp_pshift_compute(sp, pshift0, in, out);
                } else {
                    sp_pshift_compute(sp, pshift1, in, out);
                }
            }
        }
    }
};

AK_REGISTER_DSP(AKPitchShifterDSP)
AK_REGISTER_PARAMETER(AKPitchShifterParameterShift)
AK_REGISTER_PARAMETER(AKPitchShifterParameterWindowSize)
AK_REGISTER_PARAMETER(AKPitchShifterParameterCrossfade)
