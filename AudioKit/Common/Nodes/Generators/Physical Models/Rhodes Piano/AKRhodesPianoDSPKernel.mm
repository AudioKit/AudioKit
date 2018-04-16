//
//  AKRhodesPianoDSPKernel.cpp
//  AudioKit
//
//  Created by Stéphane Peter, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKRhodesPianoDSPKernel.hpp"

#include "Rhodey.h"

#include "sinewave_raw.h"
#include "fwavblnk_raw.h"

struct AKRhodesPianoDSPKernel::_Internal {
    float internalTrigger = 0;
    
    stk::Rhodey *rhodesPiano;
    
    float frequency = 110;
    float amplitude = 0.5;
};

AKRhodesPianoDSPKernel::AKRhodesPianoDSPKernel() : _private(new _Internal) {}

AKRhodesPianoDSPKernel::~AKRhodesPianoDSPKernel() = default;

void AKRhodesPianoDSPKernel::init(int _channels, double _sampleRate) {
    AKDSPKernel::init(_channels, _sampleRate);
    
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
    _private->rhodesPiano = new stk::Rhodey();
}

void AKRhodesPianoDSPKernel::start() {
    started = true;
}

void AKRhodesPianoDSPKernel::stop() {
    started = false;
}

void AKRhodesPianoDSPKernel::destroy() {
    delete _private->rhodesPiano;
}

void AKRhodesPianoDSPKernel::reset() {
    resetted = true;
}

void AKRhodesPianoDSPKernel::setFrequency(float freq) {
    _private->frequency = freq;
    frequencyRamper.setImmediate(freq);
}

void AKRhodesPianoDSPKernel::setAmplitude(float amp) {
    _private->amplitude = amp;
    amplitudeRamper.setImmediate(amp);
}

void AKRhodesPianoDSPKernel::trigger() {
    _private->internalTrigger = 1;
}

void AKRhodesPianoDSPKernel::setParameter(AUParameterAddress address, AUValue value) {
    switch (address) {
        case frequencyAddress:
            frequencyRamper.setUIValue(clamp(value, (float)0, (float)22000));
            break;
            
        case amplitudeAddress:
            amplitudeRamper.setUIValue(clamp(value, (float)0, (float)1));
            break;
            
    }
}

AUValue AKRhodesPianoDSPKernel::getParameter(AUParameterAddress address) {
    switch (address) {
        case frequencyAddress:
            return frequencyRamper.getUIValue();
            
        case amplitudeAddress:
            return amplitudeRamper.getUIValue();
            
        default: return 0.0f;
    }
}

void AKRhodesPianoDSPKernel::startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration)
{
    switch (address) {
        case frequencyAddress:
            frequencyRamper.startRamp(clamp(value, (float)0, (float)22000), duration);
            break;
            
        case amplitudeAddress:
            amplitudeRamper.startRamp(clamp(value, (float)0, (float)1), duration);
            break;
            
    }
}

void AKRhodesPianoDSPKernel::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset)
{    
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        
        int frameOffset = int(frameIndex + bufferOffset);
        
        _private->frequency = frequencyRamper.getAndStep();
        _private->amplitude = amplitudeRamper.getAndStep();
        
        for (int channel = 0; channel < channels; ++channel) {
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
            if (started) {
                if (_private->internalTrigger == 1) {
                    _private->rhodesPiano->noteOn(_private->frequency, _private->amplitude);
                }
            } else {
                *out = 0.0;
            }
            *out = _private->rhodesPiano->tick();
        }
    }
    if (_private->internalTrigger == 1) {
        _private->internalTrigger = 0;
    }
}
