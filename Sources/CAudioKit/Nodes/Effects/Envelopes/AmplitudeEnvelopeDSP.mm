    // Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum AmplitudeEnvelopeParameter : AUParameterAddress {
    AmplitudeEnvelopeParameterAttackDuration,
    AmplitudeEnvelopeParameterDecayDuration,
    AmplitudeEnvelopeParameterSustainLevel,
    AmplitudeEnvelopeParameterReleaseDuration,
};

class AmplitudeEnvelopeDSP : public SoundpipeDSPBase {
private:
    sp_adsr *adsr;
    float amp = 0;
    ParameterRamper attackDurationRamp;
    ParameterRamper decayDurationRamp;
    ParameterRamper sustainLevelRamp;
    ParameterRamper releaseDurationRamp;

public:
    AmplitudeEnvelopeDSP() {
        parameters[AmplitudeEnvelopeParameterAttackDuration] = &attackDurationRamp;
        parameters[AmplitudeEnvelopeParameterDecayDuration] = &decayDurationRamp;
        parameters[AmplitudeEnvelopeParameterSustainLevel] = &sustainLevelRamp;
        parameters[AmplitudeEnvelopeParameterReleaseDuration] = &releaseDurationRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_adsr_create(&adsr);
        sp_adsr_init(sp, adsr);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_adsr_destroy(&adsr);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_adsr_init(sp, adsr);
    }
    
    void handleMIDIEvent(AUMIDIEvent const& midiEvent) override {
        uint8_t status = midiEvent.data[0] & 0xF0;

        if (status == MIDI_NOTE_ON) {
            internalTrigger = midiEvent.data[2] / 127.0;
        }
    }

    void process(FrameRange range) override {

        for (int i : range) {

            adsr->atk = attackDurationRamp.getAndStep();
            adsr->dec = decayDurationRamp.getAndStep();
            adsr->sus = sustainLevelRamp.getAndStep();
            adsr->rel = releaseDurationRamp.getAndStep();

            sp_adsr_compute(sp, adsr, &internalTrigger, &amp);
            outputSample(0, i) = inputSample(0, i) * amp;
            outputSample(1, i) = inputSample(1, i) * amp;
        }
    }
};

AK_REGISTER_DSP(AmplitudeEnvelopeDSP, "adsr")
AK_REGISTER_PARAMETER(AmplitudeEnvelopeParameterAttackDuration)
AK_REGISTER_PARAMETER(AmplitudeEnvelopeParameterDecayDuration)
AK_REGISTER_PARAMETER(AmplitudeEnvelopeParameterSustainLevel)
AK_REGISTER_PARAMETER(AmplitudeEnvelopeParameterReleaseDuration)
