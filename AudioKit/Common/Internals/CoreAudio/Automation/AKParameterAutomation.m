//
//  AKParameterAutomation.m
//  AudioKit
//
//  Created by Ryan Francesconi on 9/9/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

//#include <vector>
#import "AKParameterAutomation.h"
#import "AKTimelineTap.h"

@implementation AKParameterAutomation
{
    AKTimelineTap *tap;
    AUAudioUnit *auAudioUnit;
    AVAudioUnit *avAudioUnit;
    Float64 lastRenderTime;

    AVAudioTime *anchorTime;

    AutomationPoint *automationPoints;
    int numberOfPoints;

    //std::vector<AutomationPoint> automationPoints;
}

- (void)initAutomation:(AUAudioUnit *)auAudioUnit avAudioUnit:(AVAudioUnit *)avAudioUnit {
    tap = [[AKTimelineTap alloc]initWithNode:avAudioUnit timelineBlock:[self timelineBlock]];
    tap.preRender = true;

    self->auAudioUnit = auAudioUnit;
    self->avAudioUnit = avAudioUnit;

    [self clear];
}

- (void)startAutomationAt:(AVAudioTime *)audioTime {
    anchorTime = audioTime;

    lastRenderTime = avAudioUnit.lastRenderTime.audioTimeStamp.mSampleTime;

    [self validatePoints:audioTime];

    NSLog(@"starting automation at time %f, lastRenderTime %f", audioTime.audioTimeStamp.mSampleTime, lastRenderTime);

    //
    //AKTimelineSetTimeAtTime(tap.timeline, 0, audioTime.audioTimeStamp);

    //AKTimelineStartAtTime(tap.timeline, audioTime.audioTimeStamp);

    //tap.timeline->waitStart = audioTime.audioTimeStamp;

//    AKTimelineSetTime(tap.timeline, 0);
//    //AKTimelineSetState(tap.timeline, 0, 0, 0, audioTime.audioTimeStamp);
//
//    tap.timeline->waitStart = audioTime.audioTimeStamp;
//    AKTimelineSetState(tap.timeline, tap.timeline->idleTime, tap.timeline->loopStart, tap.timeline->loopEnd, audioTime.audioTimeStamp);
//
    //AKTimelineStartAtTime(tap.timeline, audioTime.audioTimeStamp);

    AKTimelineSetTime(tap.timeline, 0);
    AKTimelineStart(tap.timeline);
}

- (void)stopAutomation {
    AKTimelineStop(tap.timeline);

    lastRenderTime = avAudioUnit.lastRenderTime.audioTimeStamp.mSampleTime;

    [self clear];
    NSLog(@"stopping automation at time %f", lastRenderTime);
}

- (AKTimelineBlock)timelineBlock {
    // Use untracked pointer and ivars to avoid Obj methods + ARC.
    __unsafe_unretained AKParameterAutomation *welf = self;

    return ^(AKTimeline *timeline,
             AudioTimeStamp *timeStamp,
             UInt32 offset,
             UInt32 inNumberFrames,
             AudioBufferList *ioData) {
               AUEventSampleTime sampleTime = timeStamp->mSampleTime;
               //Float64 lastRenderTime = welf->lastRenderTime;

               if (sampleTime + inNumberFrames >= welf->anchorTime.audioTimeStamp.mSampleTime) {
                   for (int i = 0; i <= welf->numberOfPoints; i++) {
                       AutomationPoint point = welf->automationPoints[i];

                       if (point.triggered) {
                           continue;
                       }

                       if (point.sampleTime == AUEventSampleTimeImmediate) {
                           printf("👍 triggering address %lld value %f AUEventSampleTimeImmediate at %lld\n", point.address, point.value,  sampleTime);
                           welf->auAudioUnit.scheduleParameterBlock(AUEventSampleTimeImmediate,
                                                                    point.rampDuration,
                                                                    point.address,
                                                                    point.value);
                           welf->automationPoints[i].triggered = true;
                           //continue;
                       }

                       for (int j = 0; j < inNumberFrames; j++) {
                           if (sampleTime + j == point.sampleTime) {
                               printf("👉 triggering address %lld value %f at %lld\n", point.address, point.value,  point.sampleTime);

                               welf->auAudioUnit.scheduleParameterBlock(AUEventSampleTimeImmediate + j,
                                                                        point.rampDuration,
                                                                        point.address,
                                                                        point.value);
                               welf->automationPoints[i].triggered = true;
                           }
                       }
                   }
               }

               printf("timeStamp %lld lastRenderTime %f\n", sampleTime, lastRenderTime);
    };
}

- (void)addPoint:(AUParameterAddress)address
           value:(AUValue)value
      sampleTime:(AUEventSampleTime)sampleTime
      anchorTime:(AUEventSampleTime)anchorTime
    rampDuration:(AUAudioFrameCount)rampDuration {
    struct AutomationPoint point = {};
    point.address = address;
    point.value = value;
    point.sampleTime = sampleTime;
    point.anchorTime = anchorTime;
    point.rampDuration = rampDuration;

    [self addPoint:point];
}

- (void)addPoint:(struct AutomationPoint)point {
    // add to the list of points

    if (numberOfPoints + 1 > 255) {
        NSLog(@"Max number of points was reached.");
        return;
    }

    automationPoints[numberOfPoints] = point;

    numberOfPoints++;

    NSLog(@"addPoint %i at time %lld", numberOfPoints, point.sampleTime);
}

- (void)clear {
    // clear all points

    if (automationPoints != nil) {
        free(automationPoints);
    }
    automationPoints = malloc(256 * sizeof(AutomationPoint));
    //memset(self->automationPoints, 0, sizeof(AutomationPoint));
    numberOfPoints = 0;
}

- (void)validatePoints:(AVAudioTime *)audioTime {
    Float64 sampleTime = audioTime.audioTimeStamp.mSampleTime;

    for (int i = 0; i <= numberOfPoints; i++) {
        AutomationPoint point = automationPoints[i];

        if (point.sampleTime <= 0 || sampleTime == 0) {
            continue;
        }

        if (point.sampleTime < sampleTime) {
            automationPoints[i].sampleTime = sampleTime;
            printf("→→→ Adjusted late point's time to %f was %lld\n", sampleTime, point.sampleTime);
        }
    }
}

- (void)dispose {
    //[self stopAutomation];
}

//------------------------------------------------------------------------------
#pragma mark - Dealloc
//------------------------------------------------------------------------------

- (void)dealloc
{
    NSLog(@"* { AKParameterAutomation.dealloc }");

    tap = nil;
    auAudioUnit = nil;
    avAudioUnit = nil;
    if (automationPoints != nil) {
        free(automationPoints);
    }
}

@end
