// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "SoundpipeDSPBase.h"
#include "ParameterRamper.h"
#include "Soundpipe.h"

enum MetalBarParameter : AUParameterAddress {
    MetalBarParameterLeftBoundaryCondition,
    MetalBarParameterRightBoundaryCondition,
    MetalBarParameterDecayDuration,
    MetalBarParameterScanSpeed,
    MetalBarParameterPosition,
    MetalBarParameterStrikeVelocity,
    MetalBarParameterStrikeWidth,
};

class MetalBarDSP : public SoundpipeDSPBase {
private:
    sp_bar *bar;
    ParameterRamper leftBoundaryConditionRamp;
    ParameterRamper rightBoundaryConditionRamp;
    ParameterRamper decayDurationRamp;
    ParameterRamper scanSpeedRamp;
    ParameterRamper positionRamp;
    ParameterRamper strikeVelocityRamp;
    ParameterRamper strikeWidthRamp;

public:
    MetalBarDSP() : SoundpipeDSPBase(/*inputBusCount*/0) {
        parameters[MetalBarParameterLeftBoundaryCondition] = &leftBoundaryConditionRamp;
        parameters[MetalBarParameterRightBoundaryCondition] = &rightBoundaryConditionRamp;
        parameters[MetalBarParameterDecayDuration] = &decayDurationRamp;
        parameters[MetalBarParameterScanSpeed] = &scanSpeedRamp;
        parameters[MetalBarParameterPosition] = &positionRamp;
        parameters[MetalBarParameterStrikeVelocity] = &strikeVelocityRamp;
        parameters[MetalBarParameterStrikeWidth] = &strikeWidthRamp;
    }

    void init(int channelCount, double sampleRate) override {
        SoundpipeDSPBase::init(channelCount, sampleRate);
        sp_bar_create(&bar);
        sp_bar_init(sp, bar, 3, 0.0001);
    }

    void deinit() override {
        SoundpipeDSPBase::deinit();
        sp_bar_destroy(&bar);
    }

    void reset() override {
        SoundpipeDSPBase::reset();
        if (!isInitialized) return;
        sp_bar_init(sp, bar, 3, 0.0001);
    }
    
    
    void handleMIDIEvent(AUMIDIEvent const& midiEvent) override {
        uint8_t status = midiEvent.data[0] & 0xF0;

        sp_bar_init(sp, bar, 3, 0.0001);
        if (status == MIDI_NOTE_ON) {
            internalTrigger = 1.0;
        }
    }

    void process(FrameRange range) override {

        for (int i : range) {

            bar->bcL = leftBoundaryConditionRamp.getAndStep();
            bar->bcR = rightBoundaryConditionRamp.getAndStep();
            bar->T30 = decayDurationRamp.getAndStep();
            bar->scan = scanSpeedRamp.getAndStep();
            bar->pos = positionRamp.getAndStep();
            bar->vel = strikeVelocityRamp.getAndStep();
            bar->wid = strikeWidthRamp.getAndStep();
            
            sp_bar_compute(sp, bar, &internalTrigger, &outputSample(0, i));
        }
        cloneFirstChannel(range);
    }
};

AK_REGISTER_DSP(MetalBarDSP, "mbar")
AK_REGISTER_PARAMETER(MetalBarParameterLeftBoundaryCondition)
AK_REGISTER_PARAMETER(MetalBarParameterRightBoundaryCondition)
AK_REGISTER_PARAMETER(MetalBarParameterDecayDuration)
AK_REGISTER_PARAMETER(MetalBarParameterScanSpeed)
AK_REGISTER_PARAMETER(MetalBarParameterPosition)
AK_REGISTER_PARAMETER(MetalBarParameterStrikeVelocity)
AK_REGISTER_PARAMETER(MetalBarParameterStrikeWidth)
