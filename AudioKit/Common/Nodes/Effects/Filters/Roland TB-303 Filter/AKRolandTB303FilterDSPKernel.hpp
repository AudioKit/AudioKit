//
//  AKRolandTB303FilterDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "AKSoundpipeKernel.hpp"

enum {
    cutoffFrequencyAddress = 0,
    resonanceAddress = 1,
    distortionAddress = 2,
    resonanceAsymmetryAddress = 3
};

class AKRolandTB303FilterDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKRolandTB303FilterDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        sp_tbvcf_create(&tbvcf0);
        sp_tbvcf_create(&tbvcf1);
        sp_tbvcf_init(sp, tbvcf0);
        sp_tbvcf_init(sp, tbvcf1);
        tbvcf0->fco = 500;
        tbvcf1->fco = 500;
        tbvcf0->res = 0.5;
        tbvcf1->res = 0.5;
        tbvcf0->dist = 2.0;
        tbvcf1->dist = 2.0;
        tbvcf0->asym = 0.5;
        tbvcf1->asym = 0.5;

        cutoffFrequencyRamper.init();
        resonanceRamper.init();
        distortionRamper.init();
        resonanceAsymmetryRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_tbvcf_destroy(&tbvcf0);
        sp_tbvcf_destroy(&tbvcf1);
        AKSoundpipeKernel::destroy();
    }

    void reset() {
        resetted = true;
        cutoffFrequencyRamper.reset();
        resonanceRamper.reset();
        distortionRamper.reset();
        resonanceAsymmetryRamper.reset();
    }

    void setCutoffFrequency(float value) {
        cutoffFrequency = clamp(value, 12.0f, 20000.0f);
        cutoffFrequencyRamper.setImmediate(cutoffFrequency);
    }

    void setResonance(float value) {
        resonance = clamp(value, 0.0f, 2.0f);
        resonanceRamper.setImmediate(resonance);
    }

    void setDistortion(float value) {
        distortion = clamp(value, 0.0f, 4.0f);
        distortionRamper.setImmediate(distortion);
    }

    void setResonanceAsymmetry(float value) {
        resonanceAsymmetry = clamp(value, 0.0f, 1.0f);
        resonanceAsymmetryRamper.setImmediate(resonanceAsymmetry);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case cutoffFrequencyAddress:
                cutoffFrequencyRamper.setUIValue(clamp(value, 12.0f, 20000.0f));
                break;

            case resonanceAddress:
                resonanceRamper.setUIValue(clamp(value, 0.0f, 2.0f));
                break;

            case distortionAddress:
                distortionRamper.setUIValue(clamp(value, 0.0f, 4.0f));
                break;

            case resonanceAsymmetryAddress:
                resonanceAsymmetryRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case cutoffFrequencyAddress:
                return cutoffFrequencyRamper.getUIValue();

            case resonanceAddress:
                return resonanceRamper.getUIValue();

            case distortionAddress:
                return distortionRamper.getUIValue();

            case resonanceAsymmetryAddress:
                return resonanceAsymmetryRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case cutoffFrequencyAddress:
                cutoffFrequencyRamper.startRamp(clamp(value, 12.0f, 20000.0f), duration);
                break;

            case resonanceAddress:
                resonanceRamper.startRamp(clamp(value, 0.0f, 2.0f), duration);
                break;

            case distortionAddress:
                distortionRamper.startRamp(clamp(value, 0.0f, 4.0f), duration);
                break;

            case resonanceAsymmetryAddress:
                resonanceAsymmetryRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            cutoffFrequency = cutoffFrequencyRamper.getAndStep();
            tbvcf0->fco = (float)cutoffFrequency;
            tbvcf1->fco = (float)cutoffFrequency;
            resonance = resonanceRamper.getAndStep();
            tbvcf0->res = (float)resonance;
            tbvcf1->res = (float)resonance;
            distortion = distortionRamper.getAndStep();
            tbvcf0->dist = (float)distortion;
            tbvcf1->dist = (float)distortion;
            resonanceAsymmetry = resonanceAsymmetryRamper.getAndStep();
            tbvcf0->asym = (float)resonanceAsymmetry;
            tbvcf1->asym = (float)resonanceAsymmetry;

            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (started) {
                    if (channel == 0) {
                        sp_tbvcf_compute(sp, tbvcf0, in, out);
                    } else {
                        sp_tbvcf_compute(sp, tbvcf1, in, out);
                    }
                } else {
                    *out = *in;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    sp_tbvcf *tbvcf0;
    sp_tbvcf *tbvcf1;

    float cutoffFrequency = 500;
    float resonance = 0.5;
    float distortion = 2.0;
    float resonanceAsymmetry = 0.5;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper cutoffFrequencyRamper = 500;
    ParameterRamper resonanceRamper = 0.5;
    ParameterRamper distortionRamper = 2.0;
    ParameterRamper resonanceAsymmetryRamper = 0.5;
};
