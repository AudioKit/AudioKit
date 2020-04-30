// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import "AKInterop.hpp"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#ifndef __cplusplus

AUInternalRenderBlock internalRenderBlockDSP(AKDSPRef pDSP);
void allocateRenderResourcesDSP(AKDSPRef pDSP, AVAudioFormat* format, AVAudioPCMBuffer* inputBuffer, AVAudioPCMBuffer* outputBuffer);
void deallocateRenderResourcesDSP(AKDSPRef pDSP);
void resetDSP(AKDSPRef pDSP);
bool canProcessInPlaceDSP(AKDSPRef pDSP);

void setRampDurationDSP(AKDSPRef pDSP, float rampDuration);
void setParameterDSP(AKDSPRef pDSP, AUParameterAddress address, AUValue value);
AUValue getParameterDSP(AKDSPRef pDSP, AUParameterAddress address);

void startDSP(AKDSPRef pDSP);
void stopDSP(AKDSPRef pDSP);

void triggerDSP(AKDSPRef pDSP);
void triggerFrequencyDSP(AKDSPRef pDSP, AUValue frequency, AUValue amplitude);

void setWavetableDSP(AKDSPRef pDSP, const float* table, size_t length, int index);

void deleteDSP(AKDSPRef pDSP);

#else

#import <Foundation/Foundation.h>
#import <algorithm>
#import <map>

/**
 Base class for DSPKernels. Many of the methods are virtual, because the base AudioUnit class
 does not know the type of the subclass at compile time.
 */

class AKDSPBase {
    
    const AVAudioPCMBuffer *inputBuffer;
    const AVAudioPCMBuffer *outputBuffer;
    
    /// Ramp rate for ramped parameters
    float rampDuration;
    
protected:

    int channelCount;
    double sampleRate;
    AudioBufferList *inBufferListPtr = nullptr;
    AudioBufferList *outBufferListPtr = nullptr;
    
    /// Subclasses should process in place and set this to true if possible
    bool bCanProcessInPlace = false;
    
    // To support AKAudioUnit functions
    bool isInitialized = false;
    bool isStarted = true;

    // current time in samples
    AUEventSampleTime now = 0;
    
    std::map<AUParameterAddress, class AKParameterRampBase*> parameters;

public:
    
    AKDSPBase();
    
    /// Virtual destructor allows child classes to be deleted with only AKDSPBase *pointer
    virtual ~AKDSPBase() {}
    
    void setBuffers(const AVAudioPCMBuffer* inputBuffer, const AVAudioPCMBuffer* outputBuffer);
    
    AUInternalRenderBlock internalRenderBlock();
    
    /// The Render function.
    virtual void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) = 0;
    
    void setRampDuration(float duration);
    
    /// Uses the ParameterAddress as a key
    virtual void setParameter(AUParameterAddress address, float value, bool immediate = false);

    /// Uses the ParameterAddress as a key
    virtual float getParameter(AUParameterAddress address);

    /// Get the DSP into initialized state
    virtual void reset() {}
    
    inline bool canProcessInPlace() const { return bCanProcessInPlace; }

    /// Don't necessarily reset, but clear out the buffers if applicable
    virtual void clear() {}

    /// Common for oscillators
    virtual void setWavetable(const float* table, size_t length, int index) {}

    /// Multiple waveform oscillators
    virtual void setupIndividualWaveform(uint32_t waveform, uint32_t size) {}

    virtual void setIndividualWaveformValue(uint32_t waveform, uint32_t index, float value) {}

    /// STK Triggers
    virtual void trigger() {}

    virtual void triggerFrequencyAmplitude(AUValue frequency, AUValue amplitude) {}

    virtual bool isLooping()
    {
        return false;
    }

    virtual void toggleLooping() {}

    virtual void setTargetAU(AudioUnit target) {}

    virtual void addMIDIEvent(UInt8 status, UInt8 data1, UInt8 data2, double beat) {}

    /// Musical file
    virtual double getTempo()
    {
        return 0.0;
    }

    virtual void setBuffers(AudioBufferList *inBufs, AudioBufferList *outBufs)
    {
        inBufferListPtr = inBufs;
        outBufferListPtr = outBufs;
    }
    
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

    virtual void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) {}

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
