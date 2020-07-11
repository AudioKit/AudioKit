// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AKPhaserDSP.hpp"
#include "ParameterRamper.hpp"

#import "AKSoundpipeDSPBase.hpp"

class AKPhaserDSP : public AKSoundpipeDSPBase {
private:
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

public:
    AKPhaserDSP() {
        parameters[AKPhaserParameterNotchMinimumFrequency] = &notchMinimumFrequencyRamp;
        parameters[AKPhaserParameterNotchMaximumFrequency] = &notchMaximumFrequencyRamp;
        parameters[AKPhaserParameterNotchWidth] = &notchWidthRamp;
        parameters[AKPhaserParameterNotchFrequency] = &notchFrequencyRamp;
        parameters[AKPhaserParameterVibratoMode] = &vibratoModeRamp;
        parameters[AKPhaserParameterDepth] = &depthRamp;
        parameters[AKPhaserParameterFeedback] = &feedbackRamp;
        parameters[AKPhaserParameterInverted] = &invertedRamp;
        parameters[AKPhaserParameterLfoBPM] = &lfoBPMRamp;
    }

    void init(int channelCount, double sampleRate) {
        AKSoundpipeDSPBase::init(channelCount, sampleRate);
        sp_phaser_create(&phaser);
        sp_phaser_init(sp, phaser);
    }

    void deinit() {
        AKSoundpipeDSPBase::deinit();
        sp_phaser_destroy(&phaser);
    }

    void reset() {
        AKSoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_phaser_init(sp, phaser);
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            *phaser->MinNotch1Freq = notchMinimumFrequencyRamp.getAndStep();
            *phaser->MaxNotch1Freq = notchMaximumFrequencyRamp.getAndStep();
            *phaser->Notch_width = notchWidthRamp.getAndStep();
            *phaser->NotchFreq = notchFrequencyRamp.getAndStep();
            *phaser->VibratoMode = vibratoModeRamp.getAndStep();
            *phaser->depth = depthRamp.getAndStep();
            *phaser->feedback_gain = feedbackRamp.getAndStep();
            *phaser->invert = invertedRamp.getAndStep();
            *phaser->lfobpm = lfoBPMRamp.getAndStep();

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
                sp_phaser_compute(sp, phaser, tmpin[0], tmpin[1], tmpout[0], tmpout[1]);
            }
        }
    }
};

extern "C" AKDSPRef createPhaserDSP() {
    return new AKPhaserDSP();
}
