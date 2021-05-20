// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum PluckedStringParameter : AUParameterAddress {
    PluckedStringParameterFrequency,
    PluckedStringParameterAmplitude,
};

class PluckedStringDSP : public SoundpipeDSPBase {
private:
    sp_pluck *pluck;
    ParameterRamper frequencyRamp;
    ParameterRamper amplitudeRamp;

public:
    PluckedStringDSP() : SoundpipeDSPBase(/*inputBusCount*/0) {
        parameters[PluckedStringParameterFrequency] = &frequencyRamp;
        parameters[PluckedStringParameterAmplitude] = &amplitudeRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_pluck_create(&pluck);
        sp_pluck_init(sp, pluck, 110);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_pluck_destroy(&pluck);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_pluck_init(sp, pluck, 110);
    }
    
    void handleMIDIEvent(AUMIDIEvent const& midiEvent) override {
        uint8_t status = midiEvent.data[0] & 0xF0;

        if(status == MIDI_NOTE_ON) {
            internalTrigger = 1.0;
        }
    }

    void process(FrameRange range) override {

        for (int i : range) {

            pluck->freq = frequencyRamp.getAndStep();
            pluck->amp = amplitudeRamp.getAndStep();

            sp_pluck_compute(sp, pluck, &internalTrigger, &outputSample(0, i));
        }
        cloneFirstChannel(range);

        if (internalTrigger == 1) {
            internalTrigger = 0;
        }
    }
};

AK_REGISTER_DSP(PluckedStringDSP, "pluk")
AK_REGISTER_PARAMETER(PluckedStringParameterFrequency)
AK_REGISTER_PARAMETER(PluckedStringParameterAmplitude)
