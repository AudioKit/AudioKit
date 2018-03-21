//
//  ModulatedDelay.hpp
//  ExtendingAudioKit
//
//  Created by Shane Dunne on 2018-03-17.
//  Copyright © 2018 Shane Dunne & Associates. All rights reserved.
//

#pragma once

#include "AKModulatedDelay_Typedefs.h"
#include "AdjustableDelayLine.hpp"
#include "FunctionTable.hpp"

namespace AudioKitCore
{

    class ModulatedDelay
    {
    public:
        ModulatedDelay(AKModulatedDelayType type);
        ~ModulatedDelay() { deinit(); }

        void init(int _channels, double _sampleRate);
        void deinit();
        
        void setModFrequencyHz(float freq);
        float getModFrequencyHz() { return modFreqHz; }
        
        void setModDepthFraction(float fraction) { modDepthFraction = fraction; }
        float getModDepthFraction() { return modDepthFraction; }
        
        void Render(unsigned channelCount, unsigned sampleCount, float* inBuffers[], float *outBuffers[]);
        
    protected:
        float minDelayMs, maxDelayMs, midDelayMs, delayRangeMs;
        float modFreqHz, modDepthFraction, dryWetMix;
        
        AKModulatedDelayType effectType;
        AdjustableDelayLine leftDelayLine, rightDelayLine;
        FunctionTableOscillator modOscillator;
    };
    
}
