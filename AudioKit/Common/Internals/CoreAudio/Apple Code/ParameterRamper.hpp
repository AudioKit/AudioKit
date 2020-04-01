//
// ParameterRamper.hpp
// AudioKit
//
// Utility class to manage DSP parameters which can change value smoothly (be ramped) while rendering, without introducing clicks or other distortion into the signal.
//
// Originally based on Apple sample code, but significantly altered by Aurelius Prochazka
//
//  Copyright © 2020 AudioKit. All rights reserved.
//
#pragma once

#ifdef __cplusplus

#import <AudioToolbox/AUAudioUnit.h>

class ParameterRamper {
private:
    struct InternalData;
    struct InternalData *data;

public:
    ParameterRamper(float value);
    ~ParameterRamper();

    void setImmediate(float value);

    void init();

    void reset();

    void setTaper(float taper);

    float getTaper() const;

    void setSkew(float skew);

    float getSkew() const;

    void setOffset(uint32_t offset);

    uint32_t getOffset() const;

    void setUIValue(float value);

    float getUIValue() const;

    void dezipperCheck(uint32_t rampDuration);

    void startRamp(float newGoal, uint32_t duration);

    float get() const;

    void step();

    float getAndStep();

    void stepBy(uint32_t n);
};

#endif
