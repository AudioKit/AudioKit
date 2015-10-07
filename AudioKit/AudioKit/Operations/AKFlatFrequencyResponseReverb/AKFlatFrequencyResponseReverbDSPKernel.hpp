//
//  AKFlatFrequencyResponseReverbDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/3/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

#ifndef AKFlatFrequencyResponseReverbDSPKernel_hpp
#define AKFlatFrequencyResponseReverbDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

extern "C" {
#include "base.h"
#include "allpass.h"
}

enum {
	ParamReverbDuration = 0
};

class AKFlatFrequencyResponseReverbDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKFlatFrequencyResponseReverbDSPKernel() {}

	void init(int channelCount, double inSampleRate, double loopTime) {
        channels = channelCount;

		sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp_allpass_create(&allpass);
        sp_allpass_init(sp, allpass, loopTime);
        allpass->revtime = 0.1;
	}

	void reset() {
	}

	void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case ParamReverbDuration:
				reverbDurationRamper.set(clamp(value, 0.0f, 5.0f));
				break;
        }
	}

	AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case ParamReverbDuration:
                return reverbDurationRamper.goal();

			default: return 0.0f;
        }
	}

	void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
			case ParamReverbDuration:
				reverbDurationRamper.startRamp(clamp(value, 0.0f, 5.0f), duration);
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
			double reverbDuration = double(reverbDurationRamper.getStep());

            int frameOffset = int(frameIndex + bufferOffset);
            allpass->revtime = (float)reverbDuration;

			for (int channel = 0; channel < channels; ++channel) {
				float* in  = (float*)inBufferListPtr->mBuffers[channel].mData  + frameOffset;
				float* out = (float*)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                sp_allpass_compute(sp, allpass, in, out);
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
    sp_allpass *allpass;

public:
	AKParameterRamper reverbDurationRamper = 0.5;
};

#endif /* AKFlatFrequencyResponseReverbDSPKernel_hpp */
