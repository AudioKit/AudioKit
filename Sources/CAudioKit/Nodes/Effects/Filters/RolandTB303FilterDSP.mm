// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "soundpipe.h"

enum RolandTB303FilterParameter : AUParameterAddress {
    RolandTB303FilterParameterCutoffFrequency,
    RolandTB303FilterParameterResonance,
    RolandTB303FilterParameterDistortion,
    RolandTB303FilterParameterResonanceAsymmetry,
};

class RolandTB303FilterDSP : public SoundpipeDSPBase {
private:
    sp_tbvcf *tbvcf0;
    sp_tbvcf *tbvcf1;
    ParameterRamper cutoffFrequencyRamp;
    ParameterRamper resonanceRamp;
    ParameterRamper distortionRamp;
    ParameterRamper resonanceAsymmetryRamp;

public:
    RolandTB303FilterDSP() {
        parameters[RolandTB303FilterParameterCutoffFrequency] = &cutoffFrequencyRamp;
        parameters[RolandTB303FilterParameterResonance] = &resonanceRamp;
        parameters[RolandTB303FilterParameterDistortion] = &distortionRamp;
        parameters[RolandTB303FilterParameterResonanceAsymmetry] = &resonanceAsymmetryRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_tbvcf_create(&tbvcf0);
        sp_tbvcf_init(sp, tbvcf0);
        sp_tbvcf_create(&tbvcf1);
        sp_tbvcf_init(sp, tbvcf1);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_tbvcf_destroy(&tbvcf0);
        sp_tbvcf_destroy(&tbvcf1);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_tbvcf_init(sp, tbvcf0);
        sp_tbvcf_init(sp, tbvcf1);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            float cutoffFrequency = cutoffFrequencyRamp.getAndStep();
            tbvcf0->fco = cutoffFrequency;
            tbvcf1->fco = cutoffFrequency;

            float resonance = resonanceRamp.getAndStep();
            tbvcf0->res = resonance;
            tbvcf1->res = resonance;

            float distortion = distortionRamp.getAndStep();
            tbvcf0->dist = distortion;
            tbvcf1->dist = distortion;

            float resonanceAsymmetry = resonanceAsymmetryRamp.getAndStep();
            tbvcf0->asym = resonanceAsymmetry;
            tbvcf1->asym = resonanceAsymmetry;

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
                    sp_tbvcf_compute(sp, tbvcf0, in, out);
                } else {
                    sp_tbvcf_compute(sp, tbvcf1, in, out);
                }
            }
        }
    }
};

AK_REGISTER_DSP(RolandTB303FilterDSP, "tb3f")
AK_REGISTER_PARAMETER(RolandTB303FilterParameterCutoffFrequency)
AK_REGISTER_PARAMETER(RolandTB303FilterParameterResonance)
AK_REGISTER_PARAMETER(RolandTB303FilterParameterDistortion)
AK_REGISTER_PARAMETER(RolandTB303FilterParameterResonanceAsymmetry)
