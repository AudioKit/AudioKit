//
//  AKTestTriggers.m
//  AudioKit
//
//  Created by David O'Neill, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKTestTriggers.h"
#import <AudioKit/AudioKit.h>
#include <CoreAudio/CoreAudioTypes.h>

@implementation AKTrigger
-(instancetype)initWithSampleTime:(Float64)sampleTime andBlock:(dispatch_block_t)block {
    self = [super init];
    if (self) {
        self.sampleTime = sampleTime;
        self.block = block;
    }
    return self;
}
@end

@implementation AKTestTriggers{
    NSArray <AKTrigger *> *_triggers;
    AKTimelineTap *tap;
}
-(instancetype)initWithNode:(AVAudioNode * _Nonnull) node {
    self = [super init];
    if (self) {
        tap = [[AKTimelineTap alloc]initWithNode:node timelineBlock:self.timlineBlock];
        tap.preRender = true;
    }
    return self;
}
-(NSArray <AKTrigger *> *)triggers {
    return _triggers;
}
-(void)setTriggers:(NSArray<AKTrigger *> *)triggers {
    _triggers = triggers;
}
-(void)start{
    AudioTimeStamp timestamp = {0};
    timestamp.mFlags = kAudioTimeStampSampleTimeValid | kAudioTimeStampHostTimeValid;
    AKTimelineStartAtTime(tap.timeline, timestamp);
}
-(AKTimelineBlock)timlineBlock {
    return ^(AKTimeline         *timeline,
             AudioTimeStamp     *timeStamp,
             UInt32             offset,
             UInt32             inNumberFrames,
             AudioBufferList    *ioData) {

        Float64 startSample = timeStamp->mSampleTime;
        Float64 endSample = startSample + inNumberFrames;

        for (AKTrigger *trigger in self.triggers) {
            if(startSample <= trigger.sampleTime && trigger.sampleTime < endSample) {
                trigger.block();
            }
        }
    };
}
@end
