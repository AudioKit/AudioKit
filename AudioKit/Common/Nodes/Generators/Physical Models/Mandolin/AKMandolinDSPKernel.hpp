//
//  AKMandolinDSPKernel.hpp
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on Github.
//  Copyright © 2017 AudioKit. All rights reserved.
//

#pragma once
#import "AKDSPKernel.hpp"
#import "ParameterRamper.hpp"

#import <AudioKit/AudioKit-Swift.h>

#include "Mandolin.h"

#include "mand_raw.h"

enum {
    detuneAddress = 0,
    bodySizeAddress = 1,
};

static inline double noteToHz(int noteNumber)
{
    return 440. * exp2((noteNumber - 69)/12.);
}

class AKMandolinDSPKernel : public AKDSPKernel, public AKOutputBuffered {
public:
    // MARK: Member Functions

    AKMandolinDSPKernel() {}

    void init(int _channels, double _sampleRate) override {
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
                [[NSData dataWithBytesNoCopy:mand1 length:mand1_len] writeToURL:mand1URL atomically:YES];
                [[NSData dataWithBytesNoCopy:mand2 length:mand2_len] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand2.raw"] atomically:YES];
                [[NSData dataWithBytesNoCopy:mand3 length:mand3_len] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand3.raw"] atomically:YES];
                [[NSData dataWithBytesNoCopy:mand4 length:mand4_len] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand4.raw"] atomically:YES];
                [[NSData dataWithBytesNoCopy:mand5 length:mand5_len] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand5.raw"] atomically:YES];
                [[NSData dataWithBytesNoCopy:mand6 length:mand6_len] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand6.raw"] atomically:YES];
                [[NSData dataWithBytesNoCopy:mand7 length:mand7_len] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand7.raw"] atomically:YES];
                [[NSData dataWithBytesNoCopy:mand8 length:mand8_len] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand8.raw"] atomically:YES];
                [[NSData dataWithBytesNoCopy:mand9 length:mand9_len] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand9.raw"] atomically:YES];
                [[NSData dataWithBytesNoCopy:mand10 length:mand10_len] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand10.raw"] atomically:YES];
                [[NSData dataWithBytesNoCopy:mand11 length:mand11_len] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand11.raw"] atomically:YES];
                [[NSData dataWithBytesNoCopy:mand12 length:mand12_len] writeToURL:[directoryURL URLByAppendingPathComponent:@"mand12.raw"] atomically:YES];
                [[NSData dataWithBytesNoCopy:mandpluk length:mandpluk_len] writeToURL:[directoryURL URLByAppendingPathComponent:@"mandpluk.raw"] atomically:YES];
            }
        } else {
            NSLog(@"Failed to create temporary directory at path %@ with error %@", directoryURL, error);
        }
        
        stk::Stk::setRawwavePath(directoryURL.fileSystemRepresentation);
        for (int i=0; i <= 3; i++)
            mandolins[i] = new stk::Mandolin(100);
        stk::Stk::setSampleRate(sampleRate);
    }

    void destroy() {
        for (int i=0; i <= 3; i++) delete mandolins[i];
    }

    void reset() {
        resetted = true;
    }

    void setDetune(float value) {
        detune = clamp(value, 0.0f, 10.0f);
        detuneRamper.setImmediate(detune);
    }

    void setBodySize(float value) {
        bodySize = clamp(value, 0.0f, 3.0f);
        bodySizeRamper.setImmediate(bodySize);
    }

    void setFrequency(float frequency, int course) {
        mandolins[course]->setFrequency(frequency);
    }
    void pluck(int course, float position, int velocity) {
        started = true;
        mandolins[course]->pluck((float)velocity/127.0, position);
    }
    void mute(int course) {
        // How to stop?
    }

    void setParameter(AUParameterAddress address, AUValue value) {
        switch (address) {
            case detuneAddress:
                detuneRamper.setUIValue(clamp(value, 0.0f, 10.0f));
                break;

            case bodySizeAddress:
                bodySizeRamper.setUIValue(clamp(value, 0.0f, 3.0f));
                break;
        }
    }

    AUValue getParameter(AUParameterAddress address) {
        switch (address) {
            case detuneAddress:
                return detuneRamper.getUIValue();

            case bodySizeAddress:
                return bodySizeRamper.getUIValue();

            default: return 0.0f;
        }
    }

    void startRamp(AUParameterAddress address, AUValue value, AUAudioFrameCount duration) override {
        switch (address) {
            case detuneAddress:
                detuneRamper.startRamp(clamp(value, 0.0f, 10.0f), duration);
                break;

            case bodySizeAddress:
                bodySizeRamper.startRamp(clamp(value, 0.0f, 3.0f), duration);
                break;
        }
    }

    void process(AUAudioFrameCount frameCount, AUAudioFrameCount bufferOffset) override {

        for (int frameIndex = 0; frameIndex < frameCount; ++frameIndex) {

            int frameOffset = int(frameIndex + bufferOffset);

            detune = detuneRamper.getAndStep();
            bodySize = bodySizeRamper.getAndStep();

            for (auto & mandolin : mandolins) {
                mandolin->setDetune(detune);
                mandolin->setBodySize(1 / bodySize);
            }

            for (int channel = 0; channel < channels; ++channel) {
                float *out = (float *)outBufferListPtr->mBuffers[channel].mData + frameOffset;
                if (started) {
                    *out = mandolins[0]->tick();
                    *out += mandolins[1]->tick();
                    *out += mandolins[2]->tick();
                    *out += mandolins[3]->tick();
                } else {
                    *out = 0.0;
                }
            }
        }
    }

    // MARK: Member Variables

private:

    stk::Mandolin *mandolins[4];
    float detune = 1;
    float bodySize = 1;

public:
    bool started = false;
    bool resetted = false;

    ParameterRamper detuneRamper = 1;
    ParameterRamper bodySizeRamper = 1;
};


