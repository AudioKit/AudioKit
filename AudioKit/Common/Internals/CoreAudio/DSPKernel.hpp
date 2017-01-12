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
};

class AKOutputBuffered {
protected:
    AudioBufferList *outBufferListPtr = nullptr;

};

class AKBuffered: public AKOutputBuffered {
protected:
    AudioBufferList *inBufferListPtr = nullptr;
public:

};
