// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKSTKInstrumentDSP.hpp"

#include "Clarinet.h"

class AKClarinetDSP : public AKSTKInstrumentDSP {
private:
    stk::Clarinet *clarinet = nullptr;

public:
    AKClarinetDSP() {}
    ~AKClarinetDSP() = default;

    void init(int channelCount, double sampleRate) override {
        AKDSPBase::init(channelCount, sampleRate);

        stk::Stk::setSampleRate(sampleRate);
        clarinet = new stk::Clarinet(/*lowestFrequency*/100);
    }

    stk::Instrmnt* getInstrument() override {
        return clarinet;
    }

    void deinit() override {
        AKDSPBase::deinit();
        delete clarinet;
        clarinet = nullptr;
    }

};

AK_REGISTER_DSP(AKClarinetDSP);
