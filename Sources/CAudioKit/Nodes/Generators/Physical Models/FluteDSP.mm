// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "STKInstrumentDSP.h"

#include "Flute.h"

class FluteDSP : public STKInstrumentDSP {
private:
    stk::Flute *flute = nullptr;

public:
    FluteDSP() {}
    ~FluteDSP() = default;

    void init(int channelCount, double sampleRate) override {
        DSPBase::init(channelCount, sampleRate);

        stk::Stk::setSampleRate(sampleRate);
        flute = new stk::Flute(/*lowestFrequency*/100);
    }

    stk::Instrmnt* getInstrument() override {
        return flute;
    }

    void deinit() override {
        DSPBase::deinit();
        delete flute;
        flute = nullptr;
    }

};

AK_REGISTER_DSP(FluteDSP, "flut");
