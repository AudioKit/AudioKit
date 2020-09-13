// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once

#import "AKInterop.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

#include <stdarg.h>

AK_API AKDSPRef akCreateDSP(const char* name);
AK_API AUParameterAddress akGetParameterAddress(const char* name);

AK_API AUInternalRenderBlock internalRenderBlockDSP(AKDSPRef pDSP);

AK_API size_t inputBusCountDSP(AKDSPRef pDSP);
AK_API size_t outputBusCountDSP(AKDSPRef pDSP);
AK_API bool canProcessInPlaceDSP(AKDSPRef pDSP);

AK_API void setBufferDSP(AKDSPRef pDSP, AVAudioPCMBuffer* buffer, size_t busIndex);
AK_API void allocateRenderResourcesDSP(AKDSPRef pDSP, AVAudioFormat* format);
AK_API void deallocateRenderResourcesDSP(AKDSPRef pDSP);
AK_API void resetDSP(AKDSPRef pDSP);

AK_API void setParameterValueDSP(AKDSPRef pDSP, AUParameterAddress address, AUValue value);
AK_API AUValue getParameterValueDSP(AKDSPRef pDSP, AUParameterAddress address);

AK_API void startDSP(AKDSPRef pDSP);
AK_API void stopDSP(AKDSPRef pDSP);

AK_API void initializeConstantDSP(AKDSPRef pDSP, AUValue value);

AK_API void triggerDSP(AKDSPRef pDSP);
AK_API void triggerFrequencyDSP(AKDSPRef pDSP, AUValue frequency, AUValue amplitude);

AK_API void setWavetableDSP(AKDSPRef pDSP, const float* table, size_t length, int index);

AK_API void deleteDSP(AKDSPRef pDSP);

/// Reset random seed to ensure deterministic results in tests.
AK_API void akSetSeed(unsigned int);

#ifdef __cplusplus

#import <Foundation/Foundation.h>
#import <vector>

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

    static constexpr int maxParameters = 128;
    
    class ParameterRamper* parameters[maxParameters];

public:
    
    AKDSPBase(int inputBusCount=1);
    
    /// Virtual destructor allows child classes to be deleted with only AKDSPBase *pointer
    virtual ~AKDSPBase() {}
    
    std::vector<AudioBufferList*> inputBufferLists;
    AudioBufferList* outputBufferList = nullptr;
    
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

    /// Pointer to a factory function.
    using CreateFunction = AKDSPRef (*)();

    /// Adds a function to create a subclass by name.
    static void addCreateFunction(const char* name, CreateFunction func);

    /// Registers a parameter.
    static void addParameter(const char* paramName, AUParameterAddress address);

    /// Create a subclass by name.
    static AKDSPRef create(const char* name);

    virtual void startRamp(const AUParameterEvent& event);

private:

    /**
     Handles the event list processing and rendering loop. Should be called from AU renderBlock
     From Apple Example code
     */
    void processWithEvents(AudioTimeStamp const *timestamp, AUAudioFrameCount frameCount,
                                   AURenderEvent const *events);
    
    void handleOneEvent(AURenderEvent const *event);
    
    void performAllSimultaneousEvents(AUEventSampleTime now, AURenderEvent const *&event);
    
};

/// Registers a creation function when initialized.
template<class T>
struct AKDSPRegistration {
    static AKDSPRef construct() {
        return new T();
    }

    AKDSPRegistration(const char* name) {
        AKDSPBase::addCreateFunction(name, construct);
    }
};

/// Convenience macro for registering a subclass of AKDSPBase.
///
/// You'll want to do `AK_REGISTER_DSP(AKMyClass)` in order to be able to call `akCreateDSP("AKMyClass")`
#define AK_REGISTER_DSP(ClassName) AKDSPRegistration<ClassName> __register##ClassName(#ClassName);

struct AKParameterRegistration {
    AKParameterRegistration(const char* name, AUParameterAddress address) {
        AKDSPBase::addParameter(name, address);
    }
};

#define AK_REGISTER_PARAMETER(ParamAddress) AKParameterRegistration __register_param_##ParamAddress(#ParamAddress, ParamAddress);

#endif
