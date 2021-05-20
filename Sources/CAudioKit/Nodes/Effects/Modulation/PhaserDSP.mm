// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum PhaserParameter : AUParameterAddress {
    PhaserParameterNotchMinimumFrequency,
    PhaserParameterNotchMaximumFrequency,
    PhaserParameterNotchWidth,
    PhaserParameterNotchFrequency,
    PhaserParameterVibratoMode,
    PhaserParameterDepth,
    PhaserParameterFeedback,
    PhaserParameterInverted,
    PhaserParameterLfoBPM,
};

class PhaserDSP : public SoundpipeDSPBase {
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
    PhaserDSP() {
        parameters[PhaserParameterNotchMinimumFrequency] = &notchMinimumFrequencyRamp;
        parameters[PhaserParameterNotchMaximumFrequency] = &notchMaximumFrequencyRamp;
        parameters[PhaserParameterNotchWidth] = &notchWidthRamp;
        parameters[PhaserParameterNotchFrequency] = &notchFrequencyRamp;
        parameters[PhaserParameterVibratoMode] = &vibratoModeRamp;
        parameters[PhaserParameterDepth] = &depthRamp;
        parameters[PhaserParameterFeedback] = &feedbackRamp;
        parameters[PhaserParameterInverted] = &invertedRamp;
        parameters[PhaserParameterLfoBPM] = &lfoBPMRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_phaser_create(&phaser);
        sp_phaser_init(sp, phaser);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_phaser_destroy(&phaser);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_phaser_init(sp, phaser);
    }

    void process(FrameRange range) override {
        for (int i : range) {

            *phaser->MinNotch1Freq = notchMinimumFrequencyRamp.getAndStep();
            *phaser->MaxNotch1Freq = notchMaximumFrequencyRamp.getAndStep();
            *phaser->Notch_width = notchWidthRamp.getAndStep();
            *phaser->NotchFreq = notchFrequencyRamp.getAndStep();
            *phaser->VibratoMode = vibratoModeRamp.getAndStep();
            *phaser->depth = depthRamp.getAndStep();
            *phaser->feedback_gain = feedbackRamp.getAndStep();
            *phaser->invert = invertedRamp.getAndStep();
            *phaser->lfobpm = lfoBPMRamp.getAndStep();

            float leftIn = inputSample(0, i);
            float rightIn = inputSample(1, i);

            float &leftOut = outputSample(0, i);
            float &rightOut = outputSample(1, i);
            
            sp_phaser_compute(sp, phaser, &leftIn, &rightIn, &leftOut, &rightOut);
        }
    }
};

AK_REGISTER_DSP(PhaserDSP, "phas")
AK_REGISTER_PARAMETER(PhaserParameterNotchMinimumFrequency)
AK_REGISTER_PARAMETER(PhaserParameterNotchMaximumFrequency)
AK_REGISTER_PARAMETER(PhaserParameterNotchWidth)
AK_REGISTER_PARAMETER(PhaserParameterNotchFrequency)
AK_REGISTER_PARAMETER(PhaserParameterVibratoMode)
AK_REGISTER_PARAMETER(PhaserParameterDepth)
AK_REGISTER_PARAMETER(PhaserParameterFeedback)
AK_REGISTER_PARAMETER(PhaserParameterInverted)
AK_REGISTER_PARAMETER(PhaserParameterLfoBPM)
