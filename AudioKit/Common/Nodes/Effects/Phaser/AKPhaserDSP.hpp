//
//  AKPhaserDSP.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once

#import <Foundation/Foundation.h>

typedef NS_ENUM(int64_t, AKPhaserParameter) {
    AKPhaserParameterNotchMinimumFrequency,
    AKPhaserParameterNotchMaximumFrequency,
    AKPhaserParameterNotchWidth,
    AKPhaserParameterNotchFrequency,
    AKPhaserParameterVibratoMode,
    AKPhaserParameterDepth,
    AKPhaserParameterFeedback,
    AKPhaserParameterInverted,
    AKPhaserParameterLfoBPM,
    AKPhaserParameterRampTime
};

#import "AKLinearParameterRamp.hpp"  // have to put this here to get it included in umbrella header

#ifndef __cplusplus

void* createPhaserDSP(int nChannels, double sampleRate);

#else

#import "AKSoundpipeDSPBase.hpp"

class AKPhaserDSP : public AKSoundpipeDSPBase {

    sp_phaser *_phaser;


private:
    AKLinearParameterRamp notchMinimumFrequencyRamp;
    AKLinearParameterRamp notchMaximumFrequencyRamp;
    AKLinearParameterRamp notchWidthRamp;
    AKLinearParameterRamp notchFrequencyRamp;
    AKLinearParameterRamp vibratoModeRamp;
    AKLinearParameterRamp depthRamp;
    AKLinearParameterRamp feedbackRamp;
    AKLinearParameterRamp invertedRamp;
    AKLinearParameterRamp lfoBPMRamp;
   
public:
    AKPhaserDSP() {
        notchMinimumFrequencyRamp.setTarget(100, true);
        notchMinimumFrequencyRamp.setDurationInSamples(10000);
        notchMaximumFrequencyRamp.setTarget(800, true);
        notchMaximumFrequencyRamp.setDurationInSamples(10000);
        notchWidthRamp.setTarget(1000, true);
        notchWidthRamp.setDurationInSamples(10000);
        notchFrequencyRamp.setTarget(1.5, true);
        notchFrequencyRamp.setDurationInSamples(10000);
        vibratoModeRamp.setTarget(1, true);
        vibratoModeRamp.setDurationInSamples(10000);
        depthRamp.setTarget(1, true);
        depthRamp.setDurationInSamples(10000);
        feedbackRamp.setTarget(0, true);
        feedbackRamp.setDurationInSamples(10000);
        invertedRamp.setTarget(0, true);
        invertedRamp.setDurationInSamples(10000);
        lfoBPMRamp.setTarget(30, true);
        lfoBPMRamp.setDurationInSamples(10000);
    }

    /** Uses the ParameterAddress as a key */
    void setParameter(uint64_t address, float value, bool immediate) override {
        switch (address) {
            case AKPhaserParameterNotchMinimumFrequency:
                notchMinimumFrequencyRamp.setTarget(value, immediate);
                break;
            case AKPhaserParameterNotchMaximumFrequency:
                notchMaximumFrequencyRamp.setTarget(value, immediate);
                break;
            case AKPhaserParameterNotchWidth:
                notchWidthRamp.setTarget(value, immediate);
                break;
            case AKPhaserParameterNotchFrequency:
                notchFrequencyRamp.setTarget(value, immediate);
                break;
            case AKPhaserParameterVibratoMode:
                vibratoModeRamp.setTarget(value, immediate);
                break;
            case AKPhaserParameterDepth:
                depthRamp.setTarget(value, immediate);
                break;
            case AKPhaserParameterFeedback:
                feedbackRamp.setTarget(value, immediate);
                break;
            case AKPhaserParameterInverted:
                invertedRamp.setTarget(value, immediate);
                break;
            case AKPhaserParameterLfoBPM:
                lfoBPMRamp.setTarget(value, immediate);
                break;
            case AKPhaserParameterRampTime:
                notchMinimumFrequencyRamp.setRampTime(value, _sampleRate);
                notchMaximumFrequencyRamp.setRampTime(value, _sampleRate);
                notchWidthRamp.setRampTime(value, _sampleRate);
                notchFrequencyRamp.setRampTime(value, _sampleRate);
                vibratoModeRamp.setRampTime(value, _sampleRate);
                depthRamp.setRampTime(value, _sampleRate);
                feedbackRamp.setRampTime(value, _sampleRate);
                invertedRamp.setRampTime(value, _sampleRate);
                lfoBPMRamp.setRampTime(value, _sampleRate);
                break;
        }
    }

    /** Uses the ParameterAddress as a key */
    float getParameter(uint64_t address) override {
        switch (address) {
            case AKPhaserParameterNotchMinimumFrequency:
                return notchMinimumFrequencyRamp.getTarget();
            case AKPhaserParameterNotchMaximumFrequency:
                return notchMaximumFrequencyRamp.getTarget();
            case AKPhaserParameterNotchWidth:
                return notchWidthRamp.getTarget();
            case AKPhaserParameterNotchFrequency:
                return notchFrequencyRamp.getTarget();
            case AKPhaserParameterVibratoMode:
                return vibratoModeRamp.getTarget();
            case AKPhaserParameterDepth:
                return depthRamp.getTarget();
            case AKPhaserParameterFeedback:
                return feedbackRamp.getTarget();
            case AKPhaserParameterInverted:
                return invertedRamp.getTarget();
            case AKPhaserParameterLfoBPM:
                return lfoBPMRamp.getTarget();
            case AKPhaserParameterRampTime:
                return notchMinimumFrequencyRamp.getRampTime(_sampleRate);
        }
        return 0;
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeDSPBase::init(_channels, _sampleRate);
        sp_phaser_create(&_phaser);
        sp_phaser_init(_sp, _phaser);
        *_phaser->MinNotch1Freq = 100;
        *_phaser->MaxNotch1Freq = 800;
        *_phaser->Notch_width = 1000;
        *_phaser->NotchFreq = 1.5;
        *_phaser->VibratoMode = 1;
        *_phaser->depth = 1;
        *_phaser->feedback_gain = 0;
        *_phaser->invert = 0;
        *_phaser->lfobpm = 30;
    }

    void destroy() {
        sp_phaser_destroy(&_phaser);
        AKSoundpipeDSPBase::destroy();
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do gain ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                notchMinimumFrequencyRamp.advanceTo(_now + frameOffset);
                notchMaximumFrequencyRamp.advanceTo(_now + frameOffset);
                notchWidthRamp.advanceTo(_now + frameOffset);
                notchFrequencyRamp.advanceTo(_now + frameOffset);
                vibratoModeRamp.advanceTo(_now + frameOffset);
                depthRamp.advanceTo(_now + frameOffset);
                feedbackRamp.advanceTo(_now + frameOffset);
                invertedRamp.advanceTo(_now + frameOffset);
                lfoBPMRamp.advanceTo(_now + frameOffset);
            }
            *_phaser->MinNotch1Freq = notchMinimumFrequencyRamp.getValue();
            *_phaser->MaxNotch1Freq = notchMaximumFrequencyRamp.getValue();
            *_phaser->Notch_width = notchWidthRamp.getValue();
            *_phaser->NotchFreq = notchFrequencyRamp.getValue();
            *_phaser->VibratoMode = vibratoModeRamp.getValue();
            *_phaser->depth = depthRamp.getValue();
            *_phaser->feedback_gain = feedbackRamp.getValue();
            *_phaser->invert = invertedRamp.getValue();
            *_phaser->lfobpm = lfoBPMRamp.getValue();

            float *tmpin[2];
            float *tmpout[2];
            for (int channel = 0; channel < _nChannels; ++channel) {
                float* in  = (float*)_inBufferListPtr->mBuffers[channel].mData  + frameOffset;
                float* out = (float*)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

                if (channel < 2) {
                    tmpin[channel] = in;
                    tmpout[channel] = out;
                }
                if (!_playing) {
                    *out = *in;
                }
            }
            if (_playing) {
                sp_phaser_compute(_sp, _phaser, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);
            }
        }
    }
};

#endif
