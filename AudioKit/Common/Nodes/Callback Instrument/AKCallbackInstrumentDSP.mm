// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AudioKit.h"
#import "TPCircularBuffer.h"

class AKCallbackInstrumentDSP : public AKSoundpipeDSPBase {
public:
    // MARK: Member Functions

    TPCircularBuffer midiBuffer;
    NSTimer* timer;

    AKCallbackInstrumentDSP() {
        TPCircularBufferInit(&midiBuffer, 4096);
        // Hopefully this polling interval is ok.
        timer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                repeats:true
                                                  block:^(NSTimer * _Nonnull timer) {
                 consumer();
                 }];
    }

    ~AKCallbackInstrumentDSP() {
        TPCircularBufferCleanup(&midiBuffer);
        [timer invalidate];
    }

    void init(int _channels, double _sampleRate) override {
        AKSoundpipeKernel::init(_channels, _sampleRate);
    }

    void destroy() {
        AKSoundpipeKernel::destroy();
    }
    
    void start() {
        started = true;
    }

    void stop() {
        started = false;
    }

    void reset() {
        resetted = true;
    }

    void setParameter(AUParameterAddress address, AUValue value) {

    }

    AUValue getParameter(AUParameterAddress address) {
        return 0.0f;
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {

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

    virtual void handleMIDIEvent(AUMIDIEvent const& midiEvent) override {
        if (midiEvent.length != 3) return;
        TPCircularBufferProduceBytes(&midiBuffer, midiEvent.data, 3);
    }

    void consumer() {
        int32_t availableBytes;
        uint8_t* data = (uint8_t*) TPCircularBufferTail(&midiBuffer, &availableBytes);
        if(data) {
            int32_t messageCount = availableBytes / 3;

            if(callback) {
                for(int messageIndex=0; messageIndex < messageCount; ++messageIndex) {
                    uint8_t status = data[3*messageIndex];
                    uint8_t data1 = data[3*messageIndex+1];
                    uint8_t data2 = data[3*messageIndex+2];
                    callback(status, data1, data2);
                }
            }
            TPCircularBufferConsume(&midiBuffer, messageCount * 3);
        }
    }
    
private:
    int count = 0;
    int lastFrameCount = 0;
    bool updateTime = false;

public:
    bool started = false;
    bool resetted = false;
    AKCMIDICallback callback = nullptr;
};

AK_REGISTER_DSP(AKCallbackInstrumentDSP)
