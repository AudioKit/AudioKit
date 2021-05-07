// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "STKInstrumentDSP.h"
#import "StkBundleHelper.h"

#include "Rhodey.h"

class RhodesPianoKeyDSP : public STKInstrumentDSP {
private:
    stk::Rhodey *rhodesPiano = nullptr;

public:
    RhodesPianoKeyDSP() {}
    ~RhodesPianoKeyDSP() = default;

    void init(int channelCount, double sampleRate) override {
        DSPBase::init(channelCount, sampleRate);

        auto bundle = [StkBundleHelper moduleBundle];
        auto directoryURL = [bundle.resourceURL URLByAppendingPathComponent:@"rawwaves"];

        stk::Stk::setRawwavePath(directoryURL.fileSystemRepresentation);

        stk::Stk::setSampleRate(sampleRate);
        rhodesPiano = new stk::Rhodey();
    }

    stk::Instrmnt* getInstrument() override {
        return rhodesPiano;
    }

    void deinit() override {
        DSPBase::deinit();
        delete rhodesPiano;
        rhodesPiano = nullptr;
    }

};

AK_REGISTER_DSP(RhodesPianoKeyDSP, "rhds");
