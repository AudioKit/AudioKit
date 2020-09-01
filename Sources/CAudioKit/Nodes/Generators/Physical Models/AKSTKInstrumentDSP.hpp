// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#include "Instrmnt.h"
#include "AKDSPBase.hpp"

/// Common base class for STK instruments.
class AKSTKInstrumentDSP : public AKDSPBase {

public:

    AKSTKInstrumentDSP();

    virtual stk::Instrmnt* getInstrument() = 0;

    void reset() override;

    void handleMIDIEvent(AUMIDIEvent const& midiEvent) override;

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;

};
