// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AudioKit.h"

#include "TubeBell.h"
#include "sinewave_raw.h"
#include "fwavblnk_raw.h"

enum AKTubularBellsParameter : AUParameterAddress {
    AKTubularBellsParameterFrequency,
    AKTubularBellsParameterAmplitude
};

class AKTubularBellsDSP : public AKDSPBase {
private:
    float internalTrigger = 0;
    stk::TubeBell *tubularBells;

    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp amplitudeRamp;
    AKLinearParameterRamp detuningOffsetRamp;
    AKLinearParameterRamp detuningMultiplierRamp;

public:
    AKTubularBellsDSP() {
        frequencyRamp.setTarget(110, true);
        frequencyRamp.setDurationInSamples(10000);
        amplitudeRamp.setTarget(0.5, true);
        amplitudeRamp.setDurationInSamples(10000);
    }

    ~AKTubularBellsDSP() = default;

    /// Uses the ParameterAddress as a key
    void setParameter(AUParameterAddress address, float value, bool immediate) override {
        switch (address) {
            case AKTubularBellsParameterFrequency:
                frequencyRamp.setTarget(value, immediate);
                break;
            case AKTubularBellsParameterAmplitude:
                amplitudeRamp.setTarget(value, immediate);
                break;
        }
    }

    /// Uses the ParameterAddress as a key
    float getParameter(AUParameterAddress address) override {
        switch (address) {
            case AKTubularBellsParameterFrequency:
                return frequencyRamp.getTarget();
            case AKTubularBellsParameterAmplitude:
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
        tubularBells = new stk::TubeBell();
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
        delete tubularBells;
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
                        tubularBells->noteOn(frequency, amplitude);
                    }
                    *out = tubularBells->tick();
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

AK_REGISTER_DSP(AKTubularBellsDSP);
AK_REGISTER_PARAMETER(AKTubularBellsParameterFrequency)
AK_REGISTER_PARAMETER(AKTubularBellsParameterAmplitude)
