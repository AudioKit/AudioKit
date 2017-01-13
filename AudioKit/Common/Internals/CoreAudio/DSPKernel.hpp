/*
	<samplecode>
 <abstract>
 Utility code to manage scheduled parameters in an audio unit implementation.
 </abstract>
	</samplecode>
 */

#pragma once

#import <AudioToolbox/AudioToolbox.h>
#import <algorithm>
#import <AudioKit/AudioKit-Swift.h>

extern "C" {
#include "soundpipe.h"
}


template <typename T>
T clamp(T input, T low, T high) {
    return std::min(std::max(input, low), high);
}

// Put your DSP code into a subclass of DSPKernel.
class DSPKernel {
public:
    virtual void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) = 0;
    virtual void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) = 0;
    
    // Override to handle MIDI events.
    virtual void handleMIDIEvent(AUMIDIEvent const& midiEvent) {}
    
    void processWithEvents(AudioTimeStamp const* timestamp, AUAudioFrameCount frameCount, AURenderEvent const* events);
    
private:
    void handleOneEvent(AURenderEvent const* event);
    void performAllSimultaneousEvents(AUEventSampleTime now, AURenderEvent const*& event);
};

class AKDSPKernel: public DSPKernel {
protected:
    int channels = AKSettings.numberOfChannels;
    float sampleRate = AKSettings.sampleRate;
public:
    AKDSPKernel(int _channels, float _sampleRate):
      channels(_channels), sampleRate(_sampleRate) { }

    AKDSPKernel(): AKDSPKernel(AKSettings.numberOfChannels, AKSettings.sampleRate) { }

    void init(int _channels, double _sampleRate) {
        channels = _channels;
        sampleRate = _sampleRate;
    }
};

class AKOutputBuffered {
protected:
    AudioBufferList *outBufferListPtr = nullptr;
public:
    void setBuffer(AudioBufferList *outBufferList) {
        outBufferListPtr = outBufferList;
    }
};

class AKBuffered: public AKOutputBuffered {
protected:
    AudioBufferList *inBufferListPtr = nullptr;
public:
    void setBuffers(AudioBufferList *inBufferList, AudioBufferList *outBufferList) {
        inBufferListPtr = inBufferList;
        outBufferListPtr = outBufferList;
    }
};

class AKSporthKernel: public AKDSPKernel {
protected:
    sp_data *sp = nullptr;
public:
//    AKSporthKernel(int _channels, float _sampleRate) {
//
//      sp_create(&sp);
//
//    }

    void init(int channelCount, double inSampleRate) {
      AKDSPKernel::init(channelCount, inSampleRate);
      sp_create(&sp);
      sp->sr = sampleRate;
      sp->nchan = channels;
    }

//    ~AKSporthKernel() {
//        sp_destroy(&sp);
//    }
    void destroy() {
        sp_destroy(&sp);
    }

};


