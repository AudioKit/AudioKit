//
//  AKMicrophoneTrackerEngine.m
//  AudioKit
//
//  Created by Aurelius Prochazka, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AKMicrophoneTrackerEngine.h"

#import "soundpipe.h"

@implementation AKMicrophoneTrackerEngine {
    EZMicrophone *ezmic;
    sp_ptrack *ptrack;
    sp_data *sp;
}

- (instancetype)initWithHopSize:(UInt32)hopSize peakCount:(UInt32)peakCount {
    self = [super init];
    if (self) {

        sp_create(&sp);
        sp->sr = 44100;
        sp->nchan = 1;

        sp_ptrack_create(&ptrack);
        sp_ptrack_init(sp, ptrack, hopSize, peakCount);

        ezmic = [EZMicrophone microphoneWithDelegate:self];
    }
    return self;
}

- (instancetype)init {
    return [self initWithHopSize: 4096 peakCount: 20];
}

- (void)start {
    [ezmic startFetchingAudio];
}
- (void)stop {
    [ezmic stopFetchingAudio];
}

- (void)microphone:(EZMicrophone *)microphone hasBufferList:(AudioBufferList *)bufferList withBufferSize:(UInt32)bufferSize withNumberOfChannels:(UInt32)numberOfChannels {

    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        float trackedAmplitude = 0.0;
        float trackedFrequency = 0.0;
        for (int frameIndex = 0; frameIndex < bufferSize; ++frameIndex) {

            for (int channel = 0; channel < 1; ++channel) {
                float *in  = (float *)bufferList->mBuffers[channel].mData  + frameIndex;
                sp_ptrack_compute(sp, ptrack, in, &trackedFrequency, &trackedAmplitude);
            }
        }
        weakSelf.frequency = trackedFrequency;
        weakSelf.amplitude = trackedAmplitude;
    });
}

@end
