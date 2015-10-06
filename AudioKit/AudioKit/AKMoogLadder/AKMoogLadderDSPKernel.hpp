//
//  AKMoogLadderDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/3/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

#ifndef AKMoogLadderDSPKernel_hpp
#define AKMoogLadderDSPKernel_hpp

#import "DSPKernel.hpp"
#import "ParameterRamper.hpp"
#import <vector>

// AK
extern "C" {
#include "base.h"
#include "moogladder.h"
}

enum {
	FilterParamCutoff = 0,
	FilterParamResonance = 1
};

static inline double squared(double x) {
    return x * x;
}

class AKMoogLadderDSPKernel : public DSPKernel {
public:
    // MARK: Member Functions

    AKMoogLadderDSPKernel() {}
	
	void init(int channelCount, double inSampleRate) {
        channels = channelCount;
		
		sampleRate = float(inSampleRate);
		nyquist = 0.5 * sampleRate;
		inverseNyquist = 1.0 / nyquist;
        
        // AK
        sp_create(&sp);
        sp_moogladder_create(&moog);
        sp_moogladder_init(sp, moog);
        moog->res = 0.9;
        moog->freq = 2300;
	}
	
	void reset() {
	}
	
	void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case FilterParamCutoff:
				cutoffRamper.set(clamp(value * inverseNyquist, 0.0f, 0.99f));
				break;
                
            case FilterParamResonance:
                resonanceRamper.set(clamp(value, 0.0f, 100.0f));
				break;
        }
	}

	AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case FilterParamCutoff:
                // Return the goal. It is not thread safe to return the ramping value.
                return cutoffRamper.goal() * nyquist;

            case FilterParamResonance:
                return resonanceRamper.goal();
				
			default: return 0.0f;
        }
	}

	void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
			case FilterParamCutoff:
				cutoffRamper.startRamp(clamp(value * inverseNyquist, 0.0f, 0.99f), duration);
				break;
			
			case FilterParamResonance:
				resonanceRamper.startRamp(clamp(value, 0.0f, 100.0f), duration);
				break;
		}
	}
	
	void setBuffers(AudioBufferList* inBufferList, AudioBufferList* outBufferList) {
		inBufferListPtr = inBufferList;
		outBufferListPtr = outBufferList;
	}
	
	void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        // For each sample.
		for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
			double cutoff    = double(cutoffRamper.getStep());
			double resonance = double(resonanceRamper.getStep());

            int frameOffset = int(frameIndex + bufferOffset);
            
            // AK Decouple these from the rescaling?
            moog->freq = (float)cutoff * 10000;
            moog->res  = (float)(resonance / 100);
			
			for (int channel = 0; channel < channels; ++channel) {
				float* in  = (float*)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
				float* out = (float*)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                
                // AK
                sp_moogladder_compute(sp, moog, in, out);
            }
		}
	}
	
    // MARK: Member Variables

private:
	
    int channels = 2;
	float sampleRate = 44100.0;
	float nyquist = 0.5 * sampleRate;
	float inverseNyquist = 1.0 / nyquist;
	
	AudioBufferList* inBufferListPtr = nullptr;
	AudioBufferList* outBufferListPtr = nullptr;
    
    // AK
    sp_data *sp;
    sp_moogladder *moog;

public:
	ParameterRamper cutoffRamper = 400.0 / 44100.0;
	ParameterRamper resonanceRamper = 50;
};

#endif /* AKMoogLadderDSPKernel_hpp */
