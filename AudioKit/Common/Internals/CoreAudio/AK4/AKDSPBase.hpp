//
//  AKDSPBase.hpp
//  AudioKit
//
//  Created by Andrew Voelkel, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#pragma once
#ifdef __cplusplus

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <algorithm>
#import "AKInterop.h"
/**
 Base class for DSPKernels. Many of the methods are virtual, because the base AudioUnit class
 does not know the type of the subclass at compile time.
 */

class AKDSPBase {

protected:

    int channelCount;
    double sampleRate;
    AudioBufferList *inBufferListPtr = nullptr;
    AudioBufferList *outBufferListPtr = nullptr;

    // To support AKAudioUnit functions
    bool isInitialized = true;
    bool isStarted = true;
    int64_t now = 0;  // current time in samples

public:
    
    /// Virtual destructor allows child classes to be deleted with only AKDSPBase *pointer
    virtual ~AKDSPBase() {}
    
    /// The Render function.
    virtual void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) = 0;

    /// Uses the ParameterAddress as a key
    virtual void setParameter(AUParameterAddress address, float value, bool immediate = false) {}

    /// Uses the ParameterAddress as a key
    virtual float getParameter(AUParameterAddress address) { return 0.0; }

    /// Get the DSP into initialized state
    virtual void reset() {}

    /// Don't necessarily reset, but clear out the buffers if applicable
    virtual void clear() {}

    /// Many effects have a single value that is a constant for the lifetime of the effect
    virtual void initializeConstant(AUValue value) {}

    /// Common for oscillators
    virtual void setupWaveform(uint32_t size) {}
    virtual void setWaveformValue(uint32_t index, float value) {}

    /// Multiple waveform oscillators
    virtual void setupIndividualWaveform(uint32_t waveform, uint32_t size) {}
    virtual void setIndividualWaveformValue(uint32_t waveform, uint32_t index, float value) {}

    /// STK Triggers
    virtual void trigger() {}
    virtual void triggerFrequencyAmplitude(AUValue frequency, AUValue amplitude) {}
    virtual void triggerTypeAmplitude(AUValue type, AUValue amplitude) {}

    /// File-based effects convolution and phase locked vocoder
    virtual void setUpTable(float *table, UInt32 size) {}
    virtual void setPartitionLength(int partLength) {}
    virtual void initConvolutionEngine() {}

    virtual void setBuffers(AudioBufferList *inBufs, AudioBufferList *outBufs) {
        inBufferListPtr = inBufs;
        outBufferListPtr = outBufs;
    }

    virtual void setBuffer(AudioBufferList *outBufs) {
        outBufferListPtr = outBufs;
    }

    virtual void init(int channelCount, double sampleRate) {
        this->channelCount = channelCount;
        this->sampleRate = sampleRate;
    }
    
    /// override this if your DSP kernel allocates memory; free it here
    virtual void deinit() {
    }

    // Add for compatibility with AKAudioUnit
    virtual void start() { isStarted = true; }
    virtual void stop() { isStarted = false; }
    virtual bool isPlaying() { return isStarted; }
    virtual bool isSetup() { return isInitialized; }

    virtual void handleMIDIEvent(AUMIDIEvent const& midiEvent) {}
    /**
     Handles the event list processing and rendering loop. Should be called from AU renderBlock
     From Apple Example code
     */
    void processWithEvents(AudioTimeStamp const *timestamp, AUAudioFrameCount frameCount,
                           AURenderEvent const *events);

private:

    void handleOneEvent(AURenderEvent const *event);
    void performAllSimultaneousEvents(AUEventSampleTime now, AURenderEvent const *&event);
};

#endif

