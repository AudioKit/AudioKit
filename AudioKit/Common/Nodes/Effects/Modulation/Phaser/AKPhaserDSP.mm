// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKPhaserDSP.hpp"
#include "ParameterRamper.hpp"

extern "C" AKDSPRef createPhaserDSP() {
    return new AKPhaserDSP();
}

struct AKPhaserDSP::InternalData {
    sp_phaser *phaser;
    ParameterRamper notchMinimumFrequencyRamp;
    ParameterRamper notchMaximumFrequencyRamp;
    ParameterRamper notchWidthRamp;
    ParameterRamper notchFrequencyRamp;
    ParameterRamper vibratoModeRamp;
    ParameterRamper depthRamp;
    ParameterRamper feedbackRamp;
    ParameterRamper invertedRamp;
    ParameterRamper lfoBPMRamp;
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

        *data->phaser->MinNotch1Freq = data->notchMinimumFrequencyRamp.getAndStep();
        *data->phaser->MaxNotch1Freq = data->notchMaximumFrequencyRamp.getAndStep();
        *data->phaser->Notch_width = data->notchWidthRamp.getAndStep();
        *data->phaser->NotchFreq = data->notchFrequencyRamp.getAndStep();
        *data->phaser->VibratoMode = data->vibratoModeRamp.getAndStep();
        *data->phaser->depth = data->depthRamp.getAndStep();
        *data->phaser->feedback_gain = data->feedbackRamp.getAndStep();
        *data->phaser->invert = data->invertedRamp.getAndStep();
        *data->phaser->lfobpm = data->lfoBPMRamp.getAndStep();

        float *tmpin[2];
        float *tmpout[2];
        for (int channel = 0; channel < channelCount; ++channel) {
            float *in  = (float *)inputBufferLists[0]->mBuffers[channel].mData  + frameOffset;
            float *out = (float *)outputBufferLists[0]->mBuffers[channel].mData + frameOffset;
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
