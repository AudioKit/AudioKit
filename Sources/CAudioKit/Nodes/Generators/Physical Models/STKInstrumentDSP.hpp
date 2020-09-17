// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#include "Instrmnt.h"
#include "DSPBase.h"

/// Common base class for STK instruments.
class STKInstrumentDSP : public DSPBase {

public:

    STKInstrumentDSP();

    virtual stk::Instrmnt* getInstrument() = 0;

    void reset() override;

    void handleMIDIEvent(AUMIDIEvent const& midiEvent) override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;

};
