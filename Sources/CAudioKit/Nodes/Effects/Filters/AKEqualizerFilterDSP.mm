// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKSoundpipeDSPBase.hpp"
#include "ParameterRamper.hpp"
#include "soundpipe.h"

enum AKEqualizerFilterParameter : AUParameterAddress {
    AKEqualizerFilterParameterCenterFrequency,
    AKEqualizerFilterParameterBandwidth,
    AKEqualizerFilterParameterGain,
};

class AKEqualizerFilterDSP : public AKSoundpipeDSPBase {
private:
    sp_eqfil *eqfil0;
    sp_eqfil *eqfil1;
    ParameterRamper centerFrequencyRamp;
    ParameterRamper bandwidthRamp;
    ParameterRamper gainRamp;

public:
    AKEqualizerFilterDSP() {
        parameters[AKEqualizerFilterParameterCenterFrequency] = &centerFrequencyRamp;
        parameters[AKEqualizerFilterParameterBandwidth] = &bandwidthRamp;
        parameters[AKEqualizerFilterParameterGain] = &gainRamp;
    }

    void init(int channelCount, double sampleRate) override {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_eqfil_create(&eqfil0);
        sp_eqfil_init(sp, eqfil0);
        sp_eqfil_create(&eqfil1);
        sp_eqfil_init(sp, eqfil1);
    }

    void deinit() override {
        AKSoundpipeDSPBase::deinit();
        sp_eqfil_destroy(&eqfil0);
        sp_eqfil_destroy(&eqfil1);
    }

    void reset() override {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_eqfil_init(sp, eqfil0);
        sp_eqfil_init(sp, eqfil1);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float centerFrequency = centerFrequencyRamp.getAndStep();
            eqfil0->freq = centerFrequency;
            eqfil1->freq = centerFrequency;

            float bandwidth = bandwidthRamp.getAndStep();
            eqfil0->bw = bandwidth;
            eqfil1->bw = bandwidth;

            float gain = gainRamp.getAndStep();
            eqfil0->gain = gain;
            eqfil1->gain = gain;

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
                    sp_eqfil_compute(sp, eqfil0, in, out);
                } else {
                    sp_eqfil_compute(sp, eqfil1, in, out);
                }
            }
        }
    }
};

AK_REGISTER_DSP(AKEqualizerFilterDSP)
AK_REGISTER_PARAMETER(AKEqualizerFilterParameterCenterFrequency)
AK_REGISTER_PARAMETER(AKEqualizerFilterParameterBandwidth)
AK_REGISTER_PARAMETER(AKEqualizerFilterParameterGain)
