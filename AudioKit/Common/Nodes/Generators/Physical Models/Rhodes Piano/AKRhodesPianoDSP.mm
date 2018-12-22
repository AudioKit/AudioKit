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

extern "C" AKDSPRef createRhodesPianoDSP(int nChannels, double sampleRate) {
    AKRhodesPianoDSP *dsp = new AKRhodesPianoDSP();
    dsp->init(nChannels, sampleRate);
    return dsp;
}

// AKRhodesPianoDSP method implementations

struct AKRhodesPianoDSP::_Internal
{
    float internalTrigger = 0;
    stk::Rhodey *rhodesPiano;

    AKLinearParameterRamp frequencyRamp;
    AKLinearParameterRamp amplitudeRamp;
    AKLinearParameterRamp detuningOffsetRamp;
    AKLinearParameterRamp detuningMultiplierRamp;
};

AKRhodesPianoDSP::AKRhodesPianoDSP() : _private(new _Internal)
{
    _private->frequencyRamp.setTarget(110, true);
    _private->frequencyRamp.setDurationInSamples(10000);
    _private->amplitudeRamp.setTarget(0.5, true);
    _private->amplitudeRamp.setDurationInSamples(10000);
}

AKRhodesPianoDSP::~AKRhodesPianoDSP() = default;

/** Uses the ParameterAddress as a key */
void AKRhodesPianoDSP::setParameter(AUParameterAddress address, float value, bool immediate)  {
    switch (address) {
        case AKRhodesPianoParameterFrequency:
            _private->frequencyRamp.setTarget(value, immediate);
            break;
        case AKRhodesPianoParameterAmplitude:
            _private->amplitudeRamp.setTarget(value, immediate);
            break;
        case AKRhodesPianoParameterRampDuration:
            _private->frequencyRamp.setRampDuration(value, _sampleRate);
            _private->amplitudeRamp.setRampDuration(value, _sampleRate);
            break;
    }
}

/** Uses the ParameterAddress as a key */
float AKRhodesPianoDSP::getParameter(AUParameterAddress address)  {
    switch (address) {
        case AKRhodesPianoParameterFrequency:
            return _private->frequencyRamp.getTarget();
        case AKRhodesPianoParameterAmplitude:
            return _private->amplitudeRamp.getTarget();
        case AKRhodesPianoParameterRampDuration:
            return _private->frequencyRamp.getRampDuration(_sampleRate);
    }
    return 0;
}

void AKRhodesPianoDSP::init(int _channels, double _sampleRate)  {
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
    _private->rhodesPiano = new stk::Rhodey();
}

void AKRhodesPianoDSP::trigger() {
    _private->internalTrigger = 1;
}

void AKRhodesPianoDSP::triggerFrequencyAmplitude(AUValue freq, AUValue amp)  {
    bool immediate = true;
    _private->frequencyRamp.setTarget(freq, immediate);
    _private->amplitudeRamp.setTarget(amp, immediate);
    trigger();
}

void AKRhodesPianoDSP::destroy() {
    delete _private->rhodesPiano;
}

void AKRhodesPianoDSP::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {

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
                    _private->rhodesPiano->noteOn(frequency, amplitude);
                }
                *out = _private->rhodesPiano->tick();
            } else {
                *out = 0.0;
            }
        }
    }
    if (_private->internalTrigger == 1) {
        _private->internalTrigger = 0;
    }
}

