//
//  AKMoogLadderDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/3/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

#ifndef AKMoogLadderDSPKernel_hpp
#define AKMoogLadderDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

extern "C" {
#include "base.h"
#include "moogladder.h"
}

enum {
	ParamCutoffFrequency = 0,
	ParamResonance = 1
};

class AKMoogLadderDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKMoogLadderDSPKernel() {}
	
	void init(int channelCount, double inSampleRate) {
        channels = channelCount;
		
		sampleRate = float(inSampleRate);
        
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
            case ParamCutoffFrequency:
				cutoffFrequencyRamper.set(clamp(value, 12.0f, 20000.0f));
				break;
                
            case ParamResonance:
                resonanceRamper.set(clamp(value, 0.0f, 100.0f));
				break;
        }
	}

	AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case ParamCutoffFrequency:
                return cutoffFrequencyRamper.goal();

            case ParamResonance:
                return resonanceRamper.goal();
				
			default: return 0.0f;
        }
	}

	void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
			case ParamCutoffFrequency:
				cutoffFrequencyRamper.startRamp(clamp(value, 12.0f, 20000.0f), duration);
				break;
			
			case ParamResonance:
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
			double cutoffFrequency = double(cutoffFrequencyRamper.getStep());
			double resonance       = double(resonanceRamper.getStep());

            int frameOffset = int(frameIndex + bufferOffset);
            
            moog->freq = (float)(cutoffFrequency);
            moog->res  = (float)(resonance / 100.0);
			
			for (int channel = 0; channel < channels; ++channel) {
				float* in  = (float*)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
				float* out = (float*)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                
                sp_moogladder_compute(sp, moog, in, out);
            }
		}
	}
	
    // MARK: Member Variables

private:
	
    int channels = 2;
	float sampleRate = 44100.0;
	
	AudioBufferList* inBufferListPtr = nullptr;
	AudioBufferList* outBufferListPtr = nullptr;
    
    sp_data *sp;
    sp_moogladder *moog;

public:
	AKParameterRamper resonanceRamper = 50;
    AKParameterRamper cutoffFrequencyRamper = 400.0;
};

#endif /* AKMoogLadderDSPKernel_hpp */
