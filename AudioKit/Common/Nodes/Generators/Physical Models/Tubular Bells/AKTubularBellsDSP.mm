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

extern "C" AKDSPRef createTubularBellsDSP(int nChannels, double sampleRate) {
    AKTubularBellsDSP *dsp = new AKTubularBellsDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

// AKTubularBellsDSP method implementations

struct AKTubularBellsDSP::_Internal
{
    float internalTrigger = 0;
    stk::TubeBell *TubularBells;

    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp amplitudeRamp;
    AKLinearParameterRamp detuningOffsetRamp;
    AKLinearParameterRamp detuningMultiplierRamp;
};

AKTubularBellsDSP::AKTubularBellsDSP() : _private(new _Internal)
{
    _private->frequencyRamp.setTarget(110, true);
    _private->frequencyRamp.setDurationInSamples(10000);
    _private->amplitudeRamp.setTarget(0.5, true);
    _private->amplitudeRamp.setDurationInSamples(10000);
}

AKTubularBellsDSP::~AKTubularBellsDSP() = default;

/** Uses the ParameterAddress as a key */
void AKTubularBellsDSP::setParameter(AUParameterAddress address, float value, bool immediate)  {
    switch (address) {
        case AKTubularBellsParameterFrequency:
            _private->frequencyRamp.setTarget(value, immediate);
            break;
        case AKTubularBellsParameterAmplitude:
            _private->amplitudeRamp.setTarget(value, immediate);
            break;
        case AKTubularBellsParameterRampDuration:
            _private->frequencyRamp.setRampDuration(value, _sampleRate);
            _private->amplitudeRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

/** Uses the ParameterAddress as a key */
float AKTubularBellsDSP::getParameter(AUParameterAddress address)  {
    switch (address) {
        case AKTubularBellsParameterFrequency:
            return _private->frequencyRamp.getTarget();
        case AKTubularBellsParameterAmplitude:
            return _private->amplitudeRamp.getTarget();
        case AKTubularBellsParameterRampDuration:
            return _private->frequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKTubularBellsDSP::init(int _channels, double _sampleRate)  {
    AKDSPBase::init(_channels, _sampleRate);

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


    stk::Stk::setSampleRate(_sampleRate);
    _private->TubularBells = new stk::TubeBell();
}

void AKTubularBellsDSP::trigger() {
    _private->internalTrigger = 1;
}

void AKTubularBellsDSP::triggerFrequencyAmplitude(AUValue freq, AUValue amp)  {
    bool immediate = true;
    _private->frequencyRamp.setTarget(freq, immediate);
    _private->amplitudeRamp.setTarget(amp, immediate);
    trigger();
}

void AKTubularBellsDSP::destroy() {
    delete _private->TubularBells;
}

void AKTubularBellsDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        int frameOffset = int(frameIndex + bufferOffset);

        // do ramping every 8 samples
        if ((frameOffset & 0x7) == 0) {
            _private->frequencyRamp.advanceTo(_now + frameOffset);
            _private->amplitudeRamp.advanceTo(_now + frameOffset);
        }
        float frequency = _private->frequencyRamp.getValue();
        float amplitude = _private->amplitudeRamp.getValue();

        for (int channel = 0; channel < _nChannels; ++channel) {
            float *out = (float *)_outBufferListPtr->mBuffers[channel].mData + frameOffset;

            if (_playing) {
                if (_private->internalTrigger == 1) {
                    _private->TubularBells->noteOn(frequency, amplitude);
                }
                *out = _private->TubularBells->tick();
            } else {
                *out = 0.0;
            }
        }
    }
    if (_private->internalTrigger == 1) {
        _private->internalTrigger = 0;
    }
}

