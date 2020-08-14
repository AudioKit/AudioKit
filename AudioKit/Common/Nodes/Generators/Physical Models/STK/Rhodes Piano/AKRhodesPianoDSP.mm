// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AudioKit.h"

#include "Rhodey.h"
#include "sinewave_raw.h"
#include "fwavblnk_raw.h"

enum AKRhodesPianoParameter : AUParameterAddress {
    AKRhodesPianoParameterFrequency,
    AKRhodesPianoParameterAmplitude
};

class AKRhodesPianoDSP : public AKDSPBase {
private:
    float internalTrigger = 0;
    stk::Rhodey *rhodesPiano;

    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp amplitudeRamp;

public:
    AKRhodesPianoDSP() {
        frequencyRamp.setTarget(110, true);
        frequencyRamp.setDurationInSamples(10000);
        amplitudeRamp.setTarget(0.5, true);
        amplitudeRamp.setDurationInSamples(10000);
    }

    ~AKRhodesPianoDSP() = default;

    /// Uses the ParameterAddress as a key
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKRhodesPianoParameterFrequency:
                frequencyRamp.setTarget(value, immediate);
                break;
            case AKRhodesPianoParameterAmplitude:
                amplitudeRamp.setTarget(value, immediate);
                break;
        }
    }

    /// Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKRhodesPianoParameterFrequency:
                return frequencyRamp.getTarget();
            case AKRhodesPianoParameterAmplitude:
                return amplitudeRamp.getTarget();
        }
        return 0;
    }

    void init(int channelCount, double sampleRate) override {
        AKDSPBase::init(channelCount, sampleRate);

        NSError *error = nil;
        NSURL *directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory()
                                                      stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]]
                                         isDirectory:YES];
        NSFileManager *manager = [NSFileManager defaultManager];
        if ([manager createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&error] == YES) {
            NSURL *sineURL = [directoryURL URLByAppendingPathComponent:@"sinewave.raw"];
            if ([manager fileExistsAtPath:sineURL.path] == NO) { // Create files once
                [[NSData dataWithBytesNoCopy:sinewave length:sinewave_len freeWhenDone:NO] writeToURL:sineURL atomically:YES];
                [[NSData dataWithBytesNoCopy:fwavblnk length:fwavblnk_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"fwavblnk.raw"] atomically:YES];
            }
        } else {
            NSLog(@"Failed to create temporary directory at path %@ with error %@", directoryURL, error);
        }

        stk::Stk::setRawwavePath(directoryURL.fileSystemRepresentation);

        stk::Stk::setSampleRate(sampleRate);
        rhodesPiano = new stk::Rhodey();
    }

    void trigger() override {
        internalTrigger = 1;
    }

    void triggerFrequencyAmplitude(AUValue freq, AUValue amp) override {
        bool immediate = true;
        frequencyRamp.setTarget(freq, immediate);
        amplitudeRamp.setTarget(amp, immediate);
        trigger();
    }

    void deinit() override {
        AKDSPBase::deinit();
        delete rhodesPiano;
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
            int frameOffset = int(frameIndex + bufferOffset);

            // do ramping every 8 samples
            if ((frameOffset & 0x7) == 0) {
                frequencyRamp.advanceTo(now + frameOffset);
                amplitudeRamp.advanceTo(now + frameOffset);
            }
            float frequency = frequencyRamp.getValue();
            float amplitude = amplitudeRamp.getValue();

            for (int channel = 0; channel < channelCount; ++channel) {
                float *out = (float *)outputBufferList->mBuffers[channel].mData + frameOffset;

                if (isStarted) {
                    if (internalTrigger == 1) {
                        rhodesPiano->noteOn(frequency, amplitude);
                    }
                    *out = rhodesPiano->tick();
                } else {
                    *out = 0.0;
                }
            }
        }
        if (internalTrigger == 1) {
            internalTrigger = 0;
        }
    }
};

AK_REGISTER_DSP(AKRhodesPianoDSP);
AK_REGISTER_PARAMETER(AKRhodesPianoParameterFrequency)
AK_REGISTER_PARAMETER(AKRhodesPianoParameterAmplitude)
