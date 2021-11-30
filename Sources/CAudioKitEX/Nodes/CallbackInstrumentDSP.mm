// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "DSPBase.h"
#import "Internals/RingBuffer.h"

using AudioKit::RingBuffer;

typedef void (^CMIDICallback)(uint8_t, uint8_t, uint8_t);

class CallbackInstrumentDSP : public DSPBase {
public:
    // MARK: Member Functions

    RingBuffer<AUMIDIEvent> midiBuffer;
    dispatch_source_t timer;

    CallbackInstrumentDSP() {
        static dispatch_once_t onceToken;
        static dispatch_queue_t timerQueue;
        dispatch_once(&onceToken, ^{
            timerQueue = dispatch_queue_create("audio.kit.timer.queue", DISPATCH_QUEUE_CONCURRENT);
        });
        // Hopefully this polling interval is ok.
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, timerQueue);
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.01, 0);
        dispatch_source_set_event_handler(timer, ^{
            consumer();
        });
        dispatch_resume(timer);
    }

    ~CallbackInstrumentDSP() {
        dispatch_source_cancel(timer);
        timer = nil;
    }

    void process(FrameRange range) override {
        count += range.count;
        if (updateTime) {
            lastFrameCount = count;
            updateTime = false;
        }
    }

    void handleMIDIEvent(AUMIDIEvent const& midiEvent) override {
        if (midiEvent.length != 3) return;
        midiBuffer.push(midiEvent);
    }

    void consumer() {
        midiBuffer.popAll([this] (const AUMIDIEvent& event) {
            if (event.length == 3 && callback) {
                uint8_t status = event.data[0];
                uint8_t data1 = event.data[1];
                uint8_t data2 = event.data[2];
                callback(status, data1, data2);
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

    CMIDICallback callback = nullptr;
};

AK_API void akCallbackInstrumentSetCallback(DSPRef dsp, CMIDICallback callback) {
    static_cast<CallbackInstrumentDSP*>(dsp)->setCallback(callback);
}

AK_REGISTER_DSP(CallbackInstrumentDSP, "clbk")
