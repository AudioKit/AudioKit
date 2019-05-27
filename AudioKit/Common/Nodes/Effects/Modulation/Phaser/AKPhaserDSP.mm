//
//  AKPhaserDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#include "AKPhaserDSP.hpp"
#import "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createPhaserDSP(int channelCount, double sampleRate) {
    AKPhaserDSP *dsp = new AKPhaserDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

struct AKPhaserDSP::InternalData {
    sp_phaser *phaser;
    AKLinearParameterRamp notchMinimumFrequencyRamp;
    AKLinearParameterRamp notchMaximumFrequencyRamp;
    AKLinearParameterRamp notchWidthRamp;
    AKLinearParameterRamp notchFrequencyRamp;
    AKLinearParameterRamp vibratoModeRamp;
    AKLinearParameterRamp depthRamp;
    AKLinearParameterRamp feedbackRamp;
    AKLinearParameterRamp invertedRamp;
    AKLinearParameterRamp lfoBPMRamp;
};

AKPhaserDSP::AKPhaserDSP() : data(new InternalData) {
    data->notchMinimumFrequencyRamp.setTarget(defaultNotchMinimumFrequency, true);
    data->notchMinimumFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->notchMaximumFrequencyRamp.setTarget(defaultNotchMaximumFrequency, true);
    data->notchMaximumFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->notchWidthRamp.setTarget(defaultNotchWidth, true);
    data->notchWidthRamp.setDurationInSamples(defaultRampDurationSamples);
    data->notchFrequencyRamp.setTarget(defaultNotchFrequency, true);
    data->notchFrequencyRamp.setDurationInSamples(defaultRampDurationSamples);
    data->vibratoModeRamp.setTarget(defaultVibratoMode, true);
    data->vibratoModeRamp.setDurationInSamples(defaultRampDurationSamples);
    data->depthRamp.setTarget(defaultDepth, true);
    data->depthRamp.setDurationInSamples(defaultRampDurationSamples);
    data->feedbackRamp.setTarget(defaultFeedback, true);
    data->feedbackRamp.setDurationInSamples(defaultRampDurationSamples);
    data->invertedRamp.setTarget(defaultInverted, true);
    data->invertedRamp.setDurationInSamples(defaultRampDurationSamples);
    data->lfoBPMRamp.setTarget(defaultLfoBPM, true);
    data->lfoBPMRamp.setDurationInSamples(defaultRampDurationSamples);
}

// Uses the ParameterAddress as a key
void AKPhaserDSP::setParameter(AUParameterAddress address, AUValue value, bool immediate) {
    switch (address) {
        case AKPhaserParameterNotchMinimumFrequency:
            data->notchMinimumFrequencyRamp.setTarget(clamp(value, notchMinimumFrequencyLowerBound, notchMinimumFrequencyUpperBound), immediate);
            break;
        case AKPhaserParameterNotchMaximumFrequency:
            data->notchMaximumFrequencyRamp.setTarget(clamp(value, notchMaximumFrequencyLowerBound, notchMaximumFrequencyUpperBound), immediate);
            break;
        case AKPhaserParameterNotchWidth:
            data->notchWidthRamp.setTarget(clamp(value, notchWidthLowerBound, notchWidthUpperBound), immediate);
            break;
        case AKPhaserParameterNotchFrequency:
            data->notchFrequencyRamp.setTarget(clamp(value, notchFrequencyLowerBound, notchFrequencyUpperBound), immediate);
            break;
        case AKPhaserParameterVibratoMode:
            data->vibratoModeRamp.setTarget(clamp(value, vibratoModeLowerBound, vibratoModeUpperBound), immediate);
            break;
        case AKPhaserParameterDepth:
            data->depthRamp.setTarget(clamp(value, depthLowerBound, depthUpperBound), immediate);
            break;
        case AKPhaserParameterFeedback:
            data->feedbackRamp.setTarget(clamp(value, feedbackLowerBound, feedbackUpperBound), immediate);
            break;
        case AKPhaserParameterInverted:
            data->invertedRamp.setTarget(clamp(value, invertedLowerBound, invertedUpperBound), immediate);
            break;
        case AKPhaserParameterLfoBPM:
            data->lfoBPMRamp.setTarget(clamp(value, lfoBPMLowerBound, lfoBPMUpperBound), immediate);
            break;
        case AKPhaserParameterRampDuration:
            data->notchMinimumFrequencyRamp.setRampDuration(value, sampleRate);
            data->notchMaximumFrequencyRamp.setRampDuration(value, sampleRate);
            data->notchWidthRamp.setRampDuration(value, sampleRate);
            data->notchFrequencyRamp.setRampDuration(value, sampleRate);
            data->vibratoModeRamp.setRampDuration(value, sampleRate);
            data->depthRamp.setRampDuration(value, sampleRate);
            data->feedbackRamp.setRampDuration(value, sampleRate);
            data->invertedRamp.setRampDuration(value, sampleRate);
            data->lfoBPMRamp.setRampDuration(value, sampleRate);
            break;
    }
}

// Uses the ParameterAddress as a key
float AKPhaserDSP::getParameter(uint64_t address) {
    switch (address) {
        case AKPhaserParameterNotchMinimumFrequency:
            return data->notchMinimumFrequencyRamp.getTarget();
        case AKPhaserParameterNotchMaximumFrequency:
            return data->notchMaximumFrequencyRamp.getTarget();
        case AKPhaserParameterNotchWidth:
            return data->notchWidthRamp.getTarget();
        case AKPhaserParameterNotchFrequency:
            return data->notchFrequencyRamp.getTarget();
        case AKPhaserParameterVibratoMode:
            return data->vibratoModeRamp.getTarget();
        case AKPhaserParameterDepth:
            return data->depthRamp.getTarget();
        case AKPhaserParameterFeedback:
            return data->feedbackRamp.getTarget();
        case AKPhaserParameterInverted:
            return data->invertedRamp.getTarget();
        case AKPhaserParameterLfoBPM:
            return data->lfoBPMRamp.getTarget();
        case AKPhaserParameterRampDuration:
            return data->notchMinimumFrequencyRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKPhaserDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_phaser_create(&data->phaser);
    sp_phaser_init(sp, data->phaser);
    *data->phaser->MinNotch1Freq = defaultNotchMinimumFrequency;
    *data->phaser->MaxNotch1Freq = defaultNotchMaximumFrequency;
    *data->phaser->Notch_width = defaultNotchWidth;
    *data->phaser->NotchFreq = defaultNotchFrequency;
    *data->phaser->VibratoMode = defaultVibratoMode;
    *data->phaser->depth = defaultDepth;
    *data->phaser->feedback_gain = defaultFeedback;
    *data->phaser->invert = defaultInverted;
    *data->phaser->lfobpm = defaultLfoBPM;
}

void AKPhaserDSP::deinit() {
    sp_phaser_destroy(&data->phaser);
}

void AKPhaserDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->notchMinimumFrequencyRamp.advanceTo(now + frameOffset);
            data->notchMaximumFrequencyRamp.advanceTo(now + frameOffset);
            data->notchWidthRamp.advanceTo(now + frameOffset);
            data->notchFrequencyRamp.advanceTo(now + frameOffset);
            data->vibratoModeRamp.advanceTo(now + frameOffset);
            data->depthRamp.advanceTo(now + frameOffset);
            data->feedbackRamp.advanceTo(now + frameOffset);
            data->invertedRamp.advanceTo(now + frameOffset);
            data->lfoBPMRamp.advanceTo(now + frameOffset);
        }

        *data->phaser->MinNotch1Freq = data->notchMinimumFrequencyRamp.getValue();
        *data->phaser->MaxNotch1Freq = data->notchMaximumFrequencyRamp.getValue();
        *data->phaser->Notch_width = data->notchWidthRamp.getValue();
        *data->phaser->NotchFreq = data->notchFrequencyRamp.getValue();
        *data->phaser->VibratoMode = data->vibratoModeRamp.getValue();
        *data->phaser->depth = data->depthRamp.getValue();
        *data->phaser->feedback_gain = data->feedbackRamp.getValue();
        *data->phaser->invert = data->invertedRamp.getValue();
        *data->phaser->lfobpm = data->lfoBPMRamp.getValue();

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < channelCount; ++channel) {
            float *in  = (float *)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
            if (channel < 2) {
                tmpin[channel] = in;
                tmpout[channel] = out;
            }
            if (!isStarted) {
                *out = *in;
            }

        }
        if (isStarted) {
            sp_phaser_compute(sp, data->phaser, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);
        }
    }
}
