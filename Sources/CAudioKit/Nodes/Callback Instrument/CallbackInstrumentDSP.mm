// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "DSPBase.h"
#import "../../Internals/Utilities/RingBuffer.h"

using AudioKit::RingBuffer;

typedef void (^CMIDICallback)(uint8_t, uint8_t, uint8_t);

class CallbackInstrumentDSP : public DSPBase {
public:
    // MARK: Member Functions

    RingBuffer<AUMIDIEvent> midiBuffer;
    NSTimer* timer;

    CallbackInstrumentDSP() {
        // Hopefully this polling interval is ok.
        timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                repeats:true
                                                  block:^(NSTimer * _Nonnull timer) {
                 consumer();
                 }];
    }

    ~CallbackInstrumentDSP() {
        [timer invalidate];
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        //do nothing
        for (int i = 0; i < frameCount; i++) {
            count += 1;
            if (updateTime) {
                int diff = count - lastFrameCount;
                printf("debug: time is %i diff is %i\n", count, diff);
                lastFrameCount = count;
                updateTime = false;
            }
        }
    }

    void handleMIDIEvent(AUMIDIEvent const& midiEvent) override {
        if (midiEvent.length != 3) return;
        midiBuffer.push(midiEvent);
    }

    void consumer() {
        midiBuffer.popAll([this] (const AUMIDIEvent& event) {
            if(event.length > 0) {
                int32_t messageCount = sizeof(event.data) / 3;

                if(callback) {
                    for(int messageIndex=0; messageIndex < messageCount; ++messageIndex) {
                        uint8_t status = event.data[3*messageIndex];
                        uint8_t data1 = event.data[3*messageIndex+1];
                        uint8_t data2 = event.data[3*messageIndex+2];
                        callback(status, data1, data2);
                    }
                }
            }
        });
    }
    
    void setCallback(CMIDICallback func) {
        callback = func;
    }
    
private:
    int count = 0;
    int lastFrameCount = 0;
    bool updateTime = false;

public:
    CMIDICallback callback = nullptr;
};

AK_API void akCallbackInstrumentSetCallback(DSPRef dsp, CMIDICallback callback) {
    static_cast<CallbackInstrumentDSP*>(dsp)->setCallback(callback);
}

AK_REGISTER_DSP(CallbackInstrumentDSP, "clbk")
