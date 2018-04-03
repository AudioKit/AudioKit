//
//  AKMandolinDSPKernel.cpp
//  AudioKit
//
//  Created by Stéphane Peter, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKMandolinDSPKernel.hpp"

#include "Mandolin.h"
#include "mand_raw.h"

struct AKMandolinDSPKernel::_Internal
{
    stk::Mandolin *mandolins[4];
    float detune = 1;
    float bodySize = 1;
};

AKMandolinDSPKernel::AKMandolinDSPKernel() : _private(new _Internal) { }

AKMandolinDSPKernel::~AKMandolinDSPKernel() = default;

void AKMandolinDSPKernel::init(int _channels, double _sampleRate) {
    AKDSPKernel::init(_channels, _sampleRate);
    
    // Create temporary raw files
    NSError *error = nil;
    NSURL *directoryURL = [NSURL fileURLWithPath:[NSTemporaryDirectory()
                                                  stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]]
                                     isDirectory:YES];
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager createDirectoryAtURL:directoryURL withIntermediateDirectories:YES attributes:nil error:&error] == YES) {
        NSURL *mand1URL = [directoryURL URLByAppendingPathComponent:@"mand1.raw"];
        if ([manager fileExistsAtPath:mand1URL.path] == NO) { // Create files once
            [[NSData dataWithBytesNoCopy:mand1 length:mand1_len freeWhenDone:NO] writeToURL:mand1URL atomically:YES];
            [[NSData dataWithBytesNoCopy:mand2 length:mand2_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand2.raw"] atomically:YES];
            [[NSData dataWithBytesNoCopy:mand3 length:mand3_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand3.raw"] atomically:YES];
            [[NSData dataWithBytesNoCopy:mand4 length:mand4_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand4.raw"] atomically:YES];
            [[NSData dataWithBytesNoCopy:mand5 length:mand5_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand5.raw"] atomically:YES];
            [[NSData dataWithBytesNoCopy:mand6 length:mand6_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand6.raw"] atomically:YES];
            [[NSData dataWithBytesNoCopy:mand7 length:mand7_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand7.raw"] atomically:YES];
            [[NSData dataWithBytesNoCopy:mand8 length:mand8_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand8.raw"] atomically:YES];
            [[NSData dataWithBytesNoCopy:mand9 length:mand9_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand9.raw"] atomically:YES];
            [[NSData dataWithBytesNoCopy:mand10 length:mand10_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand10.raw"] atomically:YES];
            [[NSData dataWithBytesNoCopy:mand11 length:mand11_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand11.raw"] atomically:YES];
            [[NSData dataWithBytesNoCopy:mand12 length:mand12_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand12.raw"] atomically:YES];
            [[NSData dataWithBytesNoCopy:mandpluk length:mandpluk_len freeWhenDone:NO] writeToURL:[directoryURL URLByAppendingPathComponent:@"mandpluk.raw"] atomically:YES];
        }
    } else {
        NSLog(@"Failed to create temporary directory at path %@ with error %@", directoryURL, error);
    }
    
    stk::Stk::setRawwavePath(directoryURL.fileSystemRepresentation);
    for (int i=0; i <= 3; i++)
        _private->mandolins[i] = new stk::Mandolin(100);
    stk::Stk::setSampleRate(sampleRate);
}

void AKMandolinDSPKernel::destroy() {
    for (int i=0; i <= 3; i++)
        delete _private->mandolins[i];
}

void AKMandolinDSPKernel::reset() {
    resetted = true;
}

void AKMandolinDSPKernel::setDetune(float value) {
    _private->detune = clamp(value, 0.0f, 10.0f);
    detuneRamper.setImmediate(_private->detune);
}

void AKMandolinDSPKernel::setBodySize(float value) {
    _private->bodySize = clamp(value, 0.0f, 3.0f);
    bodySizeRamper.setImmediate(_private->bodySize);
}

void AKMandolinDSPKernel::setFrequency(float frequency, int course) {
    _private->mandolins[course]->setFrequency(frequency);
}

void AKMandolinDSPKernel::pluck(int course, float position, int velocity) {
    started = true;
    _private->mandolins[course]->pluck((float)velocity/127.0, position);
}

void AKMandolinDSPKernel::mute(int course) {
    // How to stop?
}

void AKMandolinDSPKernel::setParameter(AUParameterAddress address, AUValue value) {
    switch (address) {
        case detuneAddress:
            detuneRamper.setUIValue(clamp(value, 0.0f, 10.0f));
            break;
            
        case bodySizeAddress:
            bodySizeRamper.setUIValue(clamp(value, 0.0f, 3.0f));
            break;
    }
}

AUValue AKMandolinDSPKernel::getParameter(AUParameterAddress address) {
    switch (address) {
        case detuneAddress:
            return detuneRamper.getUIValue();
            
        case bodySizeAddress:
            return bodySizeRamper.getUIValue();
            
        default: return 0.0f;
    }
}

void AKMandolinDSPKernel::startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) {
    switch (address) {
        case detuneAddress:
            detuneRamper.startRamp(clamp(value, 0.0f, 10.0f), duration);
            break;
            
        case bodySizeAddress:
            bodySizeRamper.startRamp(clamp(value, 0.0f, 3.0f), duration);
            break;
    }
}

void AKMandolinDSPKernel::process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) {
    
    for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {
        
        int frameOffset = int(frameIndex + bufferOffset);
        
        _private->detune = detuneRamper.getAndStep();
        _private->bodySize = bodySizeRamper.getAndStep();
        
        for (auto & mandolin : _private->mandolins) {
            mandolin->setDetune(_private->detune);
            mandolin->setBodySize(1 / _private->bodySize);
        }
        
        for (int channel = 0; channel < channels; ++channel) {
            float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
            if (started) {
                *out = _private->mandolins[0]->tick();
                *out += _private->mandolins[1]->tick();
                *out += _private->mandolins[2]->tick();
                *out += _private->mandolins[3]->tick();
            } else {
                *out = 0.0;
            }
        }
    }
}

