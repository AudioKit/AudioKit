// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import "DSPBase.h"

#ifdef __cplusplus

class SoundpipeDSPBase: public DSPBase {
protected:
    struct sp_data *sp = nullptr;
    float internalTrigger=0;
public:
    SoundpipeDSPBase(int inputBusCount=1, bool canProcessInPlace=true) : DSPBase(inputBusCount, canProcessInPlace) { }

    virtual void init(int channelCount, double sampleRate) override;
    virtual void deinit() override;
    virtual void handleMIDIEvent(AUMIDIEvent const& midiEvent) override;
    virtual void processSample(int channel, float *in, float *out);
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override;
};

#endif
