// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "STKInstrumentDSP.h"
#include "Shakers.h"

class ShakerDSP : public STKInstrumentDSP {
private:
    stk::Shakers *shaker = nullptr;

public:
    ShakerDSP() {}
    ~ShakerDSP() = default;

    /// Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override {
        return 0;
    }

    void init(int channelCount, double sampleRate) override {
        DSPBase::init(channelCount, sampleRate);

        stk::Stk::setSampleRate(sampleRate);
        shaker = new stk::Shakers();
    }

    stk::Instrmnt* getInstrument() override {
        return shaker;
    }

    void deinit() override {
        DSPBase::deinit();
        delete shaker;
        shaker = nullptr;
    }

};

AK_REGISTER_DSP(ShakerDSP, "shak")

