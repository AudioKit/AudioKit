// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "STKInstrumentDSP.h"
#import "StkBundleHelper.h"

#include "Mandolin.h"

class MandolinStringDSP : public STKInstrumentDSP {
private:
    stk::Mandolin *mandolin = nullptr;

public:
    MandolinStringDSP() {}
    ~MandolinStringDSP() = default;

    void init(int channelCount, double sampleRate) override {
        DSPBase::init(channelCount, sampleRate);

        auto bundle = [StkBundleHelper moduleBundle];
        auto directoryURL = [bundle.resourceURL URLByAppendingPathComponent:@"rawwaves"];

        stk::Stk::setRawwavePath(directoryURL.fileSystemRepresentation);

        stk::Stk::setSampleRate(sampleRate);
        mandolin = new stk::Mandolin(/*lowestFrequency*/100);
    }

    stk::Instrmnt* getInstrument() override {
        return mandolin;
    }

    void deinit() override {
        DSPBase::deinit();
        delete mandolin;
        mandolin = nullptr;
    }

};

AK_REGISTER_DSP(MandolinStringDSP, "mand");
