// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKPhaserDSP.hpp"
#include "AKLinearParameterRamp.hpp"

extern "C" AKDSPRef createPhaserDSP() {
    return new AKPhaserDSP();
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
    parameters[AKPhaserParameterNotchMinimumFrequency] = &data->notchMinimumFrequencyRamp;
    parameters[AKPhaserParameterNotchMaximumFrequency] = &data->notchMaximumFrequencyRamp;
    parameters[AKPhaserParameterNotchWidth] = &data->notchWidthRamp;
    parameters[AKPhaserParameterNotchFrequency] = &data->notchFrequencyRamp;
    parameters[AKPhaserParameterVibratoMode] = &data->vibratoModeRamp;
    parameters[AKPhaserParameterDepth] = &data->depthRamp;
    parameters[AKPhaserParameterFeedback] = &data->feedbackRamp;
    parameters[AKPhaserParameterInverted] = &data->invertedRamp;
    parameters[AKPhaserParameterLfoBPM] = &data->lfoBPMRamp;
}

void AKPhaserDSP::init(int channelCount, double sampleRate) {
    AKSoundpipeDSPBase::init(channelCount, sampleRate);
    sp_phaser_create(&data->phaser);
    sp_phaser_init(sp, data->phaser);
}

void AKPhaserDSP::deinit() {
    AKSoundpipeDSPBase::deinit();
    sp_phaser_destroy(&data->phaser);
}

void AKPhaserDSP::reset() {
    AKSoundpipeDSPBase::reset();
    if (!isInitialized) return;
    sp_phaser_init(sp, data->phaser);
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
                continue;
            }
            
        }
        if (isStarted) {
            sp_phaser_compute(sp, data->phaser, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);
        }
    }
}
