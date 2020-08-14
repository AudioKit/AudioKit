// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#include "AudioKit.h"

#include "DiodeClipper.hpp"
#include "AKSoulDSPBase.hpp"

class AKDiodeClipperDSP : public AKDSPBase {

public:
    Diode patch;
    std::vector<Diode::MIDIMessage> midiMessages;
    
    AKDiodeClipperDSP() {
        // Reserve space for MIDI messages so we don't have to allocate.
        midiMessages.reserve(1024);
    }
    
    // Need to override this since it's pure virtual.
    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        // Do nothing.
    }
    
    void processWithEvents(AudioTimeStamp const *timestamp,
                           AUAudioFrameCount frameCount,
                           AURenderEvent const *events) override {
        
        // Zero output channels.
        for(int channel=0; channel<channelCount; ++channel) {
            float* outputChanel = (float *)outputBufferList->mBuffers[channel].mData;
            std::fill(outputChanel, outputChanel+frameCount, 0.0f);
        }
        
        Diode::RenderContext<float> context;
        
        midiMessages.clear();
        
        AURenderEvent const* event = events;
        while(event) {
            if(event->head.eventType == AURenderEventMIDI) {
                Diode::MIDIMessage message;
                message.frameIndex = event->head.eventSampleTime - timestamp->mSampleTime;
                message.byte0 = event->MIDI.data[0];
                message.byte1 = event->MIDI.data[1];
                message.byte2 = event->MIDI.data[2];
                midiMessages.push_back(message);
            }
            event = event->head.next;
        }
        
        context.numFrames = frameCount;
        context.inputChannels[0] = (const float *)inputBufferLists[0]->mBuffers[0].mData;
        context.outputChannels[0] = (float *)outputBufferList->mBuffers[0].mData;
        context.incomingMIDI.messages = midiMessages.data();
        context.incomingMIDI.numMessages = (uint32_t) midiMessages.size();
        
        patch.render(context);
        
    }
};

// using AKDiodeClipperDSP = AKSoulDSPBase<Diode>;
AK_REGISTER_DSP(AKDiodeClipperDSP)

