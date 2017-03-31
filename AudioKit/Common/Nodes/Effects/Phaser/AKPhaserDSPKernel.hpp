//
//  AKPhaserDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 Aurelius Prochazka. All rights reserved.
//

#pragma once

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}

enum {
    notchMinimumFrequencyAddress = 0,
    notchMaximumFrequencyAddress = 1,
    notchWidthAddress = 2,
    notchFrequencyAddress = 3,
    vibratoModeAddress = 4,
    depthAddress = 5,
    feedbackAddress = 6,
    invertedAddress = 7,
    lfoBPMAddress = 8
};

class AKPhaserDSPKernel : public AKSoundpipeKernel, public AKBuffered {
public:
    // MARK: Member Functions

    AKPhaserDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);

        sp_phaser_create(&phaser0);
        sp_phaser_init(sp, phaser0);
        *phaser0->MinNotch1Freq = 100;
        *phaser0->MaxNotch1Freq = 800;
        *phaser0->Notch_width = 1000;
        *phaser0->NotchFreq = 1.5;
        *phaser0->VibratoMode = 1;
        *phaser0->depth = 1;
        *phaser0->feedback_gain = 0;
        *phaser0->invert = 0;
        *phaser0->lfobpm = 30;

        notchMinimumFrequencyRamper.init();
        notchMaximumFrequencyRamper.init();
        notchWidthRamper.init();
        notchFrequencyRamper.init();
        vibratoModeRamper.init();
        depthRamper.init();
        feedbackRamper.init();
        invertedRamper.init();
        lfoBPMRamper.init();
    }

    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void destroy() {
        sp_phaser_destroy(&phaser0);
        AKSoundpipeKernel::destroy();
    }

    void reset() {
        resetted = true;
        notchMinimumFrequencyRamper.reset();
        notchMaximumFrequencyRamper.reset();
        notchWidthRamper.reset();
        notchFrequencyRamper.reset();
        vibratoModeRamper.reset();
        depthRamper.reset();
        feedbackRamper.reset();
        invertedRamper.reset();
        lfoBPMRamper.reset();
    }

    void setNotchMinimumFrequency(float value) {
        notchMinimumFrequency = clamp(value, 20.0f, 5000.0f);
        notchMinimumFrequencyRamper.setImmediate(notchMinimumFrequency);
    }

    void setNotchMaximumFrequency(float value) {
        notchMaximumFrequency = clamp(value, 20.0f, 10000.0f);
        notchMaximumFrequencyRamper.setImmediate(notchMaximumFrequency);
    }

    void setNotchWidth(float value) {
        notchWidth = clamp(value, 10.0f, 5000.0f);
        notchWidthRamper.setImmediate(notchWidth);
    }

    void setNotchFrequency(float value) {
        notchFrequency = clamp(value, 1.1f, 4.0f);
        notchFrequencyRamper.setImmediate(notchFrequency);
    }

    void setVibratoMode(float value) {
        vibratoMode = clamp(value, 0.0f, 1.0f);
        vibratoModeRamper.setImmediate(vibratoMode);
    }

    void setDepth(float value) {
        depth = clamp(value, 0.0f, 1.0f);
        depthRamper.setImmediate(depth);
    }

    void setFeedback(float value) {
        feedback = clamp(value, 0.0f, 1.0f);
        feedbackRamper.setImmediate(feedback);
    }

    void setInverted(float value) {
        inverted = clamp(value, 0.0f, 1.0f);
        invertedRamper.setImmediate(inverted);
    }

    void setLfoBPM(float value) {
        lfoBPM = clamp(value, 24.0f, 360.0f);
        lfoBPMRamper.setImmediate(lfoBPM);
    }


    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case notchMinimumFrequencyAddress:
                notchMinimumFrequencyRamper.setUIValue(clamp(value, 20.0f, 5000.0f));
                break;

            case notchMaximumFrequencyAddress:
                notchMaximumFrequencyRamper.setUIValue(clamp(value, 20.0f, 10000.0f));
                break;

            case notchWidthAddress:
                notchWidthRamper.setUIValue(clamp(value, 10.0f, 5000.0f));
                break;

            case notchFrequencyAddress:
                notchFrequencyRamper.setUIValue(clamp(value, 1.1f, 4.0f));
                break;

            case vibratoModeAddress:
                vibratoModeRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

            case depthAddress:
                depthRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

            case feedbackAddress:
                feedbackRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

            case invertedAddress:
                invertedRamper.setUIValue(clamp(value, 0.0f, 1.0f));
                break;

            case lfoBPMAddress:
                lfoBPMRamper.setUIValue(clamp(value, 24.0f, 360.0f));
                break;

        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case notchMinimumFrequencyAddress:
                return notchMinimumFrequencyRamper.getUIValue();

            case notchMaximumFrequencyAddress:
                return notchMaximumFrequencyRamper.getUIValue();

            case notchWidthAddress:
                return notchWidthRamper.getUIValue();

            case notchFrequencyAddress:
                return notchFrequencyRamper.getUIValue();

            case vibratoModeAddress:
                return vibratoModeRamper.getUIValue();

            case depthAddress:
                return depthRamper.getUIValue();

            case feedbackAddress:
                return feedbackRamper.getUIValue();

            case invertedAddress:
                return invertedRamper.getUIValue();

            case lfoBPMAddress:
                return lfoBPMRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case notchMinimumFrequencyAddress:
                notchMinimumFrequencyRamper.startRamp(clamp(value, 20.0f, 5000.0f), duration);
                break;

            case notchMaximumFrequencyAddress:
                notchMaximumFrequencyRamper.startRamp(clamp(value, 20.0f, 10000.0f), duration);
                break;

            case notchWidthAddress:
                notchWidthRamper.startRamp(clamp(value, 10.0f, 5000.0f), duration);
                break;

            case notchFrequencyAddress:
                notchFrequencyRamper.startRamp(clamp(value, 1.1f, 4.0f), duration);
                break;

            case vibratoModeAddress:
                vibratoModeRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

            case depthAddress:
                depthRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

            case feedbackAddress:
                feedbackRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

            case invertedAddress:
                invertedRamper.startRamp(clamp(value, 0.0f, 1.0f), duration);
                break;

            case lfoBPMAddress:
                lfoBPMRamper.startRamp(clamp(value, 24.0f, 360.0f), duration);
                break;

        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            notchMinimumFrequency = notchMinimumFrequencyRamper.getAndStep();
            *phaser0->MinNotch1Freq = (float)notchMinimumFrequency;
            notchMaximumFrequency = notchMaximumFrequencyRamper.getAndStep();
            *phaser0->MaxNotch1Freq = (float)notchMaximumFrequency;
            notchWidth = notchWidthRamper.getAndStep();
            *phaser0->Notch_width = (float)notchWidth;
            notchFrequency = notchFrequencyRamper.getAndStep();
            *phaser0->NotchFreq = (float)notchFrequency;
            vibratoMode = vibratoModeRamper.getAndStep();
            *phaser0->VibratoMode = (float)vibratoMode;
            depth = depthRamper.getAndStep();
            *phaser0->depth = (float)depth;
            feedback = feedbackRamper.getAndStep();
            *phaser0->feedback_gain = (float)feedback;
            inverted = invertedRamper.getAndStep();
            *phaser0->invert = (float)inverted;
            lfoBPM = lfoBPMRamper.getAndStep();
            *phaser0->lfobpm = (float)lfoBPM;

            float *tmpin[2];
            float *tmpout[2];
            for (int channel = 0; channel < channels; ++channel) {
                float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (channel < 2) {
                    tmpin[channel] = in;
                    tmpout[channel] = out;
                }
            }
            if (started) {
                sp_phaser_compute(sp, phaser0, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);
            } else {
                tmpout[0] = tmpin[0];
                tmpout[1] = tmpin[1];
            }

        }
    }

    // MARK: Member Variables

private:

    sp_phaser *phaser0;

    float notchMinimumFrequency = 100;
    float notchMaximumFrequency = 800;
    float notchWidth = 1000;
    float notchFrequency = 1.5;
    float vibratoMode = 1;
    float depth = 1;
    float feedback = 0;
    float inverted = 0;
    float lfoBPM = 30;

public:
    bool started = true;
    bool resetted = false;
    ParameterRamper notchMinimumFrequencyRamper = 100;
    ParameterRamper notchMaximumFrequencyRamper = 800;
    ParameterRamper notchWidthRamper = 1000;
    ParameterRamper notchFrequencyRamper = 1.5;
    ParameterRamper vibratoModeRamper = 1;
    ParameterRamper depthRamper = 1;
    ParameterRamper feedbackRamper = 0;
    ParameterRamper invertedRamper = 0;
    ParameterRamper lfoBPMRamper = 30;
};
