//
//  AKOscillatorDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka on 10/3/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

#ifndef AKOscillatorDSPKernel_hpp
#define AKOscillatorDSPKernel_hpp

#import "AKDSPKernel.hpp"
#import "AKParameterRamper.hpp"

extern "C" {
#include "base.h"
#include "ftbl.h"
#include "osc.h"
}

enum {
	ParamCutoff = 0,
	ParamResonance = 1
};

class AKOscillatorDSPKernel : public AKDSPKernel {
public:
    // MARK: Member Functions

    AKOscillatorDSPKernel() {}

	void init(int channelCount, double inSampleRate) {
        channels = channelCount;

		sampleRate = float(inSampleRate);

        sp_create(&sp);
        sp_ftbl_create(sp, &ftbl, 4096);
        sp_gen_sine(sp, ftbl);

        sp_osc_create(&osc);
        sp_osc_init(sp, osc, ftbl, 0);

        osc->amp = 90;
        osc->freq = 400;
	}

	void reset() {
	}

	void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case ParamCutoff:
				frequencyRamper.set(clamp(value, 12.0f, 20000.0f));
				break;

            case ParamResonance:
                amplitudeRamper.set(clamp(value, 0.0f, 100.0f));
				break;
        }
	}

	AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case ParamCutoff:
                return frequencyRamper.goal();

            case ParamResonance:
                return amplitudeRamper.goal();

			default: return 0.0f;
        }
	}

	void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
			case ParamCutoff:
				frequencyRamper.startRamp(clamp(value, 12.0f, 20000.0f), duration);
				break;

			case ParamResonance:
				amplitudeRamper.startRamp(clamp(value, 0.0f, 100.0f), duration);
				break;
		}
	}
    
	void setBuffers(AudioBufferList* outBufferList) {
		outBufferListPtr = outBufferList;
	}

	void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {
        // For each sample.
		for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
			double frequency = double(frequencyRamper.getStep());
			double amplitude = double(amplitudeRamper.getStep());

            int frameOffset = int(frameIndex + bufferOffset);

            osc->freq = (float)(frequency);
            osc->amp  = (float)(amplitude / 100.0);

			for (int channel = 0; channel < channels; ++channel) {
				float* out = (float*)outBufferListPtr->mBuffers[channel].mData + frameOffset;

                sp_osc_compute(sp, osc, nil, out);
            }
		}
	}

    // MARK: Member Variables

private:

    int channels = 1;
	float sampleRate = 44100.0;

	AudioBufferList* outBufferListPtr = nullptr;

    sp_data *sp;
    sp_osc *osc;
    sp_ftbl *ftbl;

public:
	AKParameterRamper amplitudeRamper = 50;
    AKParameterRamper frequencyRamper = 400.0;
};

#endif /* AKOscillatorDSPKernel_hpp */
