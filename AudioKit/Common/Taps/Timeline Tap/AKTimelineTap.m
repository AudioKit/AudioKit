//
//  AKTimelineTap.m
//  AudioKit
//
//  Created by David O'Neill, revision history on GitHub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

#import "AKTimelineTap.h"
#import <AudioKit/AudioKit-Swift.h>

@implementation AKTimelineTap {
    AKRenderTap *renderTap;
    AudioStreamBasicDescription asbd;
    AKTimelineBlock _block;
    AudioUnitRenderActionFlags actionFlags;
}

-(instancetype _Nullable )initWithAudioUnit:(AudioUnit _Nonnull)audioUnit
                              timelineBlock:(AKTimelineBlock _Nullable )block {
    self = [super init];
    if (self) {
        UInt32 propSize = sizeof(AudioStreamBasicDescription);
        OSStatus status = AudioUnitGetProperty(audioUnit,
                                               kAudioUnitProperty_StreamFormat,
                                               kAudioUnitScope_Output,
                                               0,
                                               &asbd,
                                               &propSize);
        if (status) {
            NSLog(@"AKTimingTap initWithAudioUnit get kAudioUnitProperty_StreamFormat status = %i", (int)status);
            return nil;
        }
        actionFlags = kAudioUnitRenderAction_PostRender;
        _block = block;
        AKTimelineInit(&_timeline, asbd, TimingCallback, (__bridge void *)self);
        renderTap = [[AKRenderTap alloc]initWithAudioUnit:audioUnit renderNotify:[self renderNotify]];
    }
    return self;
}

-(AKRenderNotifyBlock)renderNotify {

    AKTimeline *timeline = &_timeline;

    return ^(AudioUnitRenderActionFlags *ioActionFlags,
             const AudioTimeStamp       *inTimeStamp,
             UInt32                     inBusNumber,
             UInt32                     inNumberFrames,
             AudioBufferList            *ioData) {

        if ((*ioActionFlags & actionFlags)) {
            AKTimelineRender(timeline, inTimeStamp, inNumberFrames, ioData);
        }
    };
}

-(void)setPreRender:(BOOL)preRender {
    actionFlags = preRender ? kAudioUnitRenderAction_PreRender : kAudioUnitRenderAction_PostRender;
}

-(BOOL)preRender {
    return actionFlags == kAudioUnitRenderAction_PreRender;
}

-(AKTimeline *)timeline {
    return &_timeline;
}

-(instancetype _Nullable )initWithNode:(AVAudioNode * _Nonnull)node timelineBlock:(AKTimelineBlock _Nullable )block {
    AVAudioUnit *avAudioUnit = (AVAudioUnit *)node;
    if (![avAudioUnit respondsToSelector:@selector(audioUnit)]) {
        NSLog(@"%@ doesn't have an accessible audioUnit, can't set render notify!", NSStringFromClass(node.class));
        return nil;
    }
    return [self initWithAudioUnit:avAudioUnit.audioUnit timelineBlock:block];
}

static void TimingCallback(void *refCon,
                           AudioTimeStamp *timeStamp,
                           UInt32 inNumberFrames,
                           UInt32 renderStartOffset,
                           AudioBufferList *ioData) {

    __unsafe_unretained AKTimelineTap *self = (__bridge AKTimelineTap *)refCon;
    __unsafe_unretained AKTimelineBlock timelineBlock = self->_block;

    if (timelineBlock) {
        timelineBlock(&self->_timeline, timeStamp, renderStartOffset, inNumberFrames, ioData);
    }
}
@end
