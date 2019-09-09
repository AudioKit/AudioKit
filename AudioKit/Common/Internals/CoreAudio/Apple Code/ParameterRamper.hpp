/*
<samplecode>
     <abstract>
     Utility class to manage DSP parameters which can change value smoothly (be ramped) while rendering, without introducing clicks or other distortion into the signal.
     </abstract>
</samplecode>
 */

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
