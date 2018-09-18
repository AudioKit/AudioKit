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

/**
 Base class for DSPKernels. Many of the methods are virtual, because the base AudioUnit class
 does not know the type of the subclass at compile time.
 */

class AKDSPBase {

protected:

    int _nChannels;                               /* From Apple Example code */
    double _sampleRate;                           /* From Apple Example code */
    AudioBufferList *_inBufferListPtr = nullptr;  /* From Apple Example code */
    AudioBufferList *_outBufferListPtr = nullptr; /* From Apple Example code */

    // To support AKAudioUnit functions
    bool _initialized = true;
    bool _playing = true;
    int64_t _now = 0;  // current time in samples

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

    virtual void setBuffers(AudioBufferList *inBufs, AudioBufferList *outBufs) {
        _inBufferListPtr = inBufs;
        _outBufferListPtr = outBufs;
    }

    virtual void setBuffer(AudioBufferList *outBufs) {
        _outBufferListPtr = outBufs;
    }

    virtual void init(int nChannels, double sampleRate) {
        this->_nChannels = nChannels;
        this->_sampleRate = sampleRate;
    }
    
    /// override this if your DSP kernel allocates memory; free it here
    virtual void deinit() {
    }

    // Add for compatibility with AKAudioUnit
    virtual void start() { _playing = true; }
    virtual void stop() { _playing = false; }
    virtual bool isPlaying() { return _playing; }
    virtual bool isSetup() { return _initialized; }


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

