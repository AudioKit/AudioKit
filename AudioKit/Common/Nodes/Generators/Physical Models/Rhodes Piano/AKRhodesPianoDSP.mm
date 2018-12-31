//
//  AKRhodesPianoDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/22/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKRhodesPianoDSP.hpp"

#include "Rhodey.h"
#include "sinewave_raw.h"
#include "fwavblnk_raw.h"

// "Constructor" function for interop with Swift

extern "C" AKDSPRef createRhodesPianoDSP(int channelCount, double sampleRate) {
    AKRhodesPianoDSP *dsp = new AKRhodesPianoDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

// AKRhodesPianoDSP method implementations

struct AKRhodesPianoDSP::InternalData
{
    float internalTrigger = 0;
    stk::Rhodey *rhodesPiano;

    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp amplitudeRamp;
    AKLinearParameterRamp detuningOffsetRamp;
    AKLinearParameterRamp detuningMultiplierRamp;
};

AKRhodesPianoDSP::AKRhodesPianoDSP() : data(new InternalData)
{
    data->frequencyRamp.setTarget(110, true);
    data->frequencyRamp.setDurationInSamples(10000);
    data->amplitudeRamp.setTarget(0.5, true);
    data->amplitudeRamp.setDurationInSamples(10000);
}

AKRhodesPianoDSP::~AKRhodesPianoDSP() = default;

/** Uses the ParameterAddress as a key */
void AKRhodesPianoDSP::setParameter(AUParameterAddress address, float value, bool immediate)  {
    switch (address) {
        case AKRhodesPianoParameterFrequency:
            data->frequencyRamp.setTarget(value, immediate);
            break;
        case AKRhodesPianoParameterAmplitude:
            data->amplitudeRamp.setTarget(value, immediate);
            break;
        case AKRhodesPianoParameterRampDuration:
            data->frequencyRamp.setRampDuration(value, sampleRate);
            data->amplitudeRamp.setRampDuration(value, sampleRate);
            break;
    }
}

/** Uses the ParameterAddress as a key */
float AKRhodesPianoDSP::getParameter(AUParameterAddress address)  {
    switch (address) {
        case AKRhodesPianoParameterFrequency:
            return data->frequencyRamp.getTarget();
        case AKRhodesPianoParameterAmplitude:
            return data->amplitudeRamp.getTarget();
        case AKRhodesPianoParameterRampDuration:
            return data->frequencyRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKRhodesPianoDSP::init(int channelCount, double sampleRate)  {
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
    data->rhodesPiano = new stk::Rhodey();
}

void AKRhodesPianoDSP::trigger() {
    data->internalTrigger = 1;
}

void AKRhodesPianoDSP::triggerFrequencyAmplitude(AUValue freq, AUValue amp)  {
    bool immediate = true;
    data->frequencyRamp.setTarget(freq, immediate);
    data->amplitudeRamp.setTarget(amp, immediate);
    trigger();
}

void AKRhodesPianoDSP::destroy() {
    delete data->rhodesPiano;
}

void AKRhodesPianoDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            data->frequencyRamp.advanceTo(now + frameOffset);
            data->amplitudeRamp.advanceTo(now + frameOffset);
        }
        float frequency = data->frequencyRamp.getValue();
        float amplitude = data->amplitudeRamp.getValue();

        for (int channel = 0; channel < channelCount; ++channel) {
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;

            if (isStarted) {
                if (data->internalTrigger == 1) {
                    data->rhodesPiano->noteOn(frequency, amplitude);
                }
                *out = data->rhodesPiano->tick();
            } else {
                *out = 0.0;
            }
        }
    }
    if (data->internalTrigger == 1) {
        data->internalTrigger = 0;
    }
}

