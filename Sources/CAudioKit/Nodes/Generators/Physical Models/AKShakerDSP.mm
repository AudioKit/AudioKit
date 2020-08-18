// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKSTKInstrumentDSP.hpp"
#include "Shakers.h"

class AKShakerDSP : public AKSTKInstrumentDSP {
private:
    stk::Shakers *shaker = nullptr;

public:
    AKShakerDSP() {}
    ~AKShakerDSP() = default;

    /// Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override {
        return 0;
    }

    void init(int channelCount, double sampleRate) override {
        AKDSPBase::init(channelCount, sampleRate);

        stk::Stk::setSampleRate(sampleRate);
        shaker = new stk::Shakers();
    }

    stk::Instrmnt* getInstrument() override {
        return shaker;
    }

    void deinit() override {
        AKDSPBase::deinit();
        delete shaker;
        shaker = nullptr;
    }

};

AK_REGISTER_DSP(AKShakerDSP)

