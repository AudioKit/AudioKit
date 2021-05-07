// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "STKInstrumentDSP.h"
#import "StkBundleHelper.h"

#include "TubeBell.h"

class TubularBellsDSP : public STKInstrumentDSP {
private:
    stk::TubeBell *tubularBells = nullptr;

public:
    TubularBellsDSP() {}
    ~TubularBellsDSP() = default;

    void init(int channelCount, double sampleRate) override {
        DSPBase::init(channelCount, sampleRate);

        auto bundle = [StkBundleHelper moduleBundle];
        auto directoryURL = [bundle.resourceURL URLByAppendingPathComponent:@"rawwaves"];

        stk::Stk::setRawwavePath(directoryURL.fileSystemRepresentation);

        stk::Stk::setSampleRate(sampleRate);
        tubularBells = new stk::TubeBell();
    }

    stk::Instrmnt* getInstrument() override {
        return tubularBells;
    }

    void deinit() override {
        DSPBase::deinit();
        delete tubularBells;
        tubularBells = nullptr;
    }

};

AK_REGISTER_DSP(TubularBellsDSP, "tbel");
