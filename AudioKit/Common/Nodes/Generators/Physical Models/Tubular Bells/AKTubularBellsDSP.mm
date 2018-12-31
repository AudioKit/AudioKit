//
//  AKTubularBellsDSP.mm
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/22/18.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKTubularBellsDSP.hpp"

#include "TubeBell.h"
#include "sinewave_raw.h"
#include "fwavblnk_raw.h"

// "Constructor" function for interop with Swift

extern "C" AKDSPRef createTubularBellsDSP(int channelCount, double sampleRate) {
    AKTubularBellsDSP *dsp = new AKTubularBellsDSP();
    dsp->init(channelCount, sampleRate);
    return dsp;
}

// AKTubularBellsDSP method implementations

struct AKTubularBellsDSP::InternalData
{
    float internalTrigger = 0;
    stk::TubeBell *tubularBells;

    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp amplitudeRamp;
    AKLinearParameterRamp detuningOffsetRamp;
    AKLinearParameterRamp detuningMultiplierRamp;
};

AKTubularBellsDSP::AKTubularBellsDSP() : data(new InternalData)
{
    data->frequencyRamp.setTarget(110, true);
    data->frequencyRamp.setDurationInSamples(10000);
    data->amplitudeRamp.setTarget(0.5, true);
    data->amplitudeRamp.setDurationInSamples(10000);
}

AKTubularBellsDSP::~AKTubularBellsDSP() = default;

/** Uses the ParameterAddress as a key */
void AKTubularBellsDSP::setParameter(AUParameterAddress address, float value, bool immediate)  {
    switch (address) {
        case AKTubularBellsParameterFrequency:
            data->frequencyRamp.setTarget(value, immediate);
            break;
        case AKTubularBellsParameterAmplitude:
            data->amplitudeRamp.setTarget(value, immediate);
            break;
        case AKTubularBellsParameterRampDuration:
            data->frequencyRamp.setRampDuration(value, sampleRate);
            data->amplitudeRamp.setRampDuration(value, sampleRate);
            break;
    }
}

/** Uses the ParameterAddress as a key */
float AKTubularBellsDSP::getParameter(AUParameterAddress address)  {
    switch (address) {
        case AKTubularBellsParameterFrequency:
            return data->frequencyRamp.getTarget();
        case AKTubularBellsParameterAmplitude:
            return data->amplitudeRamp.getTarget();
        case AKTubularBellsParameterRampDuration:
            return data->frequencyRamp.getRampDuration(sampleRate);
    }
    return 0;
}

void AKTubularBellsDSP::init(int channelCount, double sampleRate)  {
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
    data->tubularBells = new stk::TubeBell();
}

void AKTubularBellsDSP::trigger() {
    data->internalTrigger = 1;
}

void AKTubularBellsDSP::triggerFrequencyAmplitude(AUValue freq, AUValue amp)  {
    bool immediate = true;
    data->frequencyRamp.setTarget(freq, immediate);
    data->amplitudeRamp.setTarget(amp, immediate);
    trigger();
}

void AKTubularBellsDSP::destroy() {
    delete data->tubularBells;
}

void AKTubularBellsDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

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
                    data->tubularBells->noteOn(frequency, amplitude);
                }
                *out = data->tubularBells->tick();
            } else {
                *out = 0.0;
            }
        }
    }
    if (data->internalTrigger == 1) {
        data->internalTrigger = 0;
    }
}

