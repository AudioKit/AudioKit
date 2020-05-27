// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import "AKInterop.hpp"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#ifndef __cplusplus

#include <stdarg.h>

AUInternalRenderBlock internalRenderBlockDSP(AKDSPRef pDSP);

size_t inputBusCountDSP(AKDSPRef pDSP);
size_t outputBusCountDSP(AKDSPRef pDSP);
bool canProcessInPlaceDSP(AKDSPRef pDSP);

void setBufferDSP(AKDSPRef pDSP, AVAudioPCMBuffer* buffer, size_t busIndex);
void allocateRenderResourcesDSP(AKDSPRef pDSP, AVAudioFormat* format);
void deallocateRenderResourcesDSP(AKDSPRef pDSP);
void resetDSP(AKDSPRef pDSP);

void setParameterValueDSP(AKDSPRef pDSP, AUParameterAddress address, AUValue value);
AUValue getParameterValueDSP(AKDSPRef pDSP, AUParameterAddress address);

void setParameterRampDurationDSP(AKDSPRef pDSP, AUParameterAddress address, float rampDuration);
void setParameterRampTaperDSP(AKDSPRef pDSP, AUParameterAddress address, float taper);
void setParameterRampSkewDSP(AKDSPRef pDSP, AUParameterAddress address, float skew);

void startDSP(AKDSPRef pDSP);
void stopDSP(AKDSPRef pDSP);

void triggerDSP(AKDSPRef pDSP);
void triggerFrequencyDSP(AKDSPRef pDSP, AUValue frequency, AUValue amplitude);

void setWavetableDSP(AKDSPRef pDSP, const float* table, size_t length, int index);

void deleteDSP(AKDSPRef pDSP);

#else

#import <Foundation/Foundation.h>
#import <algorithm>
#import <vector>
#import <map>

/**
 Base class for DSPKernels. Many of the methods are virtual, because the base AudioUnit class
 does not know the type of the subclass at compile time.
 */

class AKDSPBase {
    
    std::vector<const AVAudioPCMBuffer*> internalBuffers;
    
protected:

    int channelCount;
    double sampleRate;
    
    /// Subclasses should process in place and set this to true if possible
    bool bCanProcessInPlace = false;
    
    // To support AKAudioUnit functions
    bool isInitialized = false;
    bool isStarted = true;

    // current time in samples
    AUEventSampleTime now = 0;
    
    std::map<AUParameterAddress, class ParameterRamper*> parameters;

public:
    
    AKDSPBase();
    
    /// Virtual destructor allows child classes to be deleted with only AKDSPBase *pointer
    virtual ~AKDSPBase() {}
    
    std::vector<AudioBufferList*> inputBufferLists;
    std::vector<AudioBufferList*> outputBufferLists;
    
    AUInternalRenderBlock internalRenderBlock();
    
    inline bool canProcessInPlace() const { return bCanProcessInPlace; }
    
    void setBuffer(const AVAudioPCMBuffer* buffer, size_t busIndex);
    
    /// The Render function.
    virtual void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) = 0;
    
    /// Uses the ParameterAddress as a key
    virtual void setParameter(AUParameterAddress address, float value, bool immediate = false);

    /// Uses the ParameterAddress as a key
    virtual float getParameter(AUParameterAddress address);

    /// Get the DSP into initialized state
    virtual void reset() {}

    /// Common for oscillators
    virtual void setWavetable(const float* table, size_t length, int index) {}

    /// Multiple waveform oscillators
    virtual void setupIndividualWaveform(uint32_t waveform, uint32_t size) {}

    virtual void setIndividualWaveformValue(uint32_t waveform, uint32_t index, float value) {}

    /// STK Triggers
    virtual void trigger() {}

    virtual void triggerFrequencyAmplitude(AUValue frequency, AUValue amplitude) {}
    
    /// override this if your DSP kernel allocates memory or requires the session sample rate for initialization
    virtual void init(int channelCount, double sampleRate);

    /// override this if your DSP kernel allocates memory; free it here
    virtual void deinit();

    // Add for compatibility with AKAudioUnit
    virtual void start()
    {
        isStarted = true;
    }

    virtual void stop()
    {
        isStarted = false;
    }

    virtual bool isPlaying()
    {
        return isStarted;
    }

    virtual bool isSetup()
    {
        return isInitialized;
    }

    virtual void handleMIDIEvent(AUMIDIEvent const& midiEvent) {}
    
    void setParameterRampDuration(AUParameterAddress address, float duration);
    
    void setParameterRampTaper(AUParameterAddress address, float taper);
    
    void setParameterRampSkew(AUParameterAddress address, float skew);

private:

    /**
     Handles the event list processing and rendering loop. Should be called from AU renderBlock
     From Apple Example code
     */
    void processWithEvents(AudioTimeStamp const *timestamp, AUAudioFrameCount frameCount,
                           AURenderEvent const *events);
    
    void handleOneEvent(AURenderEvent const *event);
    
    void performAllSimultaneousEvents(AUEventSampleTime now, AURenderEvent const *&event);
    
    void startRamp(const AUParameterEvent& event);
};

#endif
