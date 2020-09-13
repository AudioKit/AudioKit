// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

// Utility class to manage DSP parameters which can change value smoothly (be ramped) while rendering, without introducing clicks or other distortion into the signal.
//
// Originally based on Apple sample code, but significantly altered by Aurelius Prochazka

#pragma once

#ifdef __cplusplus

#import <AudioToolbox/AUAudioUnit.h>
#import <memory>

class ParameterRamper {
private:
    struct InternalData;
    std::unique_ptr<struct InternalData> data;

public:
    ParameterRamper(float value = 0.f);
    ParameterRamper(const ParameterRamper& other) = delete; // non copyable
    ~ParameterRamper();

    ParameterRamper& operator=( const ParameterRamper& ) = delete; // non copyable

    void setImmediate(float value);

    void init(float sampleRate);

    void reset();
    
    /// Ramp duration (seconds) to use for UI changes (dezipper checks)
//    void setDefaultRampDuration(float duration);

    void setUIValue(float value);

    float getUIValue() const;

    /// Dezipper using the default ramp duration
    void dezipperCheck();
    
    void dezipperCheck(uint32_t rampDuration);

    void startRamp(float newGoal, uint32_t duration);

    float get() const;

    void step();

    float getAndStep();

    void stepBy(uint32_t n);
};

#endif
