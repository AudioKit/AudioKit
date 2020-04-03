//
//  AKParameterAutomation.m
//  AudioKit
//
//  Created by Ryan Francesconi on 9/9/19.
//  Copyright © 2019 AudioKit. All rights reserved.
//

#import "AKParameterAutomation.h"
#import "AKTimelineTap.h"

@implementation AKParameterAutomation
{
    AKTimelineTap *tap;
    AUAudioUnit *auAudioUnit;
    AVAudioUnit *avAudioUnit;
    Float64 lastRenderTime;
    AVAudioTime *anchorTime;
    AUEventSampleTime endTime;

    // currently a fixed buffer of automation points
    AutomationPoint automationPoints[MAX_NUMBER_OF_POINTS];
    int numberOfPoints;
}

#pragma mark - Init

- (instancetype _Nullable)init:(AUAudioUnit *)auAudioUnit avAudioUnit:(AVAudioUnit *)avAudioUnit {
    self = [super init];

    if (self) {
        tap = [[AKTimelineTap alloc]initWithNode:avAudioUnit timelineBlock:[self timelineBlock]];
        tap.preRender = true;

        self->auAudioUnit = auAudioUnit;
        self->avAudioUnit = avAudioUnit;
    }
    return self;
}

#pragma mark - Control

- (void)startAutomationAt:(AVAudioTime *)audioTime
                 duration:(AVAudioTime *_Nullable)duration {
    if (AKTimelineIsStarted(tap.timeline)) {
        NSLog(@"startAutomationAt() Timeline is already running");
        return;
    }

    // Note: offline rendering is only available in 10.13+
    // See: AudioKit.renderToFile
    if (@available(iOS 11.0, macOS 10.13, tvOS 11.0, *)) {
        if ([[avAudioUnit engine] manualRenderingMode] == AVAudioEngineManualRenderingModeOffline) {
            AudioTimeStamp zero = { 0 };
            tap.timeline->lastRenderTime = zero;
        }
    }

    Float64 sampleRate = tap.timeline->format.mSampleRate;
    lastRenderTime = tap.timeline->lastRenderTime.mSampleTime;

    AUEventSampleTime offsetTime = audioTime.audioTimeStamp.mSampleTime + lastRenderTime;
    anchorTime = [[AVAudioTime alloc]initWithHostTime:audioTime.hostTime sampleTime:offsetTime atRate:sampleRate];

    endTime = 0;
    if (duration != nil) {
        endTime = duration.audioTimeStamp.mSampleTime;
    }
    // not needed at the moment
    //[self validatePoints:audioTime];

    NSLog(@"starting automation at time %lld, lastRenderTime %f, duration %lld", offsetTime, lastRenderTime, endTime);

    AKTimelineSetTimeAtTime(tap.timeline, 0, anchorTime.audioTimeStamp);
    AKTimelineStartAtTime(tap.timeline, anchorTime.audioTimeStamp);
}

- (void)stopAutomation {
    if (!AKTimelineIsStarted(tap.timeline)) {
        // AKLog(@"stopAutomation() Timeline isn't running");
        [self clear];
        return;
    }
    AKTimelineStop(tap.timeline);
    lastRenderTime = tap.timeline->lastRenderTime.mSampleTime;
    [self clear];

    // NSLog(@"stopping automation at time %f", tap.timeline->lastRenderTime.mSampleTime);
}

#pragma mark - Render Block

- (AKTimelineBlock)timelineBlock {
    // Use untracked pointer and ivars to avoid Obj methods + ARC.
    __unsafe_unretained AKParameterAutomation *welf = self;

    return ^(AKTimeline *timeline,
             AudioTimeStamp *timeStamp,
             UInt32 offset,
             UInt32 inNumberFrames,
             AudioBufferList *ioData) {
               AUEventSampleTime sampleTime = timeStamp->mSampleTime;

               // TODO: allow for a timed duration stop to end automation - don't use this:
               //AUEventSampleTime endTime = welf->endTime;

               for (int n = 0; n < inNumberFrames; n++) {
                   AUEventSampleTime sampleTimeWithOffset = sampleTime + n;

                   // TODO: allow for a timed duration stop to end automation - don't use this:
//                   if (welf->endTime != 0 && sampleTimeWithOffset == welf->endTime) {
//                       printf("🛑 auto stop at at %lld\n", sampleTimeWithOffset);
//                       [welf stopAutomation];
//                       return;
//                   }

                   for (int p = 0; p < welf->numberOfPoints; p++) {
                       AutomationPoint point = welf->automationPoints[p];

                       if (point.triggered) {
                           continue;
                       }

                       if (point.sampleTime == AUEventSampleTimeImmediate || point.sampleTime < sampleTimeWithOffset) {
//                           printf("👉 Triggering AUEventSampleTimeImmediate: %lld: %f, sampleTime: %lld, sampleTimeWithOffset: %lld, rampDuration: %d\n",
//                                  AUEventSampleTimeImmediate, point.value, point.sampleTime, sampleTimeWithOffset, point.rampDuration);
                           welf->auAudioUnit.scheduleParameterBlock(AUEventSampleTimeImmediate,
                                                                    point.rampDuration,
                                                                    point.address,
                                                                    point.value);
                           welf->automationPoints[p].triggered = true;
                           continue;
                       }

                       if (sampleTimeWithOffset == point.sampleTime) {
//                           printf("👉 Triggering scheduled: %f, sampleTime: %lld, sampleTimeWithOffset: %lld, rampDuration: %d\n",
//                                  point.value, point.sampleTime, sampleTimeWithOffset, point.rampDuration);
                           welf->auAudioUnit.scheduleParameterBlock(AUEventSampleTimeImmediate + n,
                                                                    point.rampDuration,
                                                                    point.address,
                                                                    point.value);
                           welf->automationPoints[p].triggered = true;
                       }
                   }
               }
    };
}

#pragma mark - Add and remove points

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

    if (numberOfPoints + 1 >= MAX_NUMBER_OF_POINTS) {
        NSLog(@"Max number of points was reached.");
        return;
    }

    automationPoints[numberOfPoints] = point;
    // NSLog(@"addPoint %i at time %lld, value %f", numberOfPoints, point.sampleTime, point.value);

    numberOfPoints++;
}

- (void)clear {
    // clear all points
    memset(self->automationPoints, 0, sizeof(AutomationPoint) * MAX_NUMBER_OF_POINTS);
    numberOfPoints = 0;
}

// currently unused
- (void)validatePoints:(AVAudioTime *)audioTime {
    Float64 sampleTime = audioTime.audioTimeStamp.mSampleTime;

    for (int i = 0; i <= numberOfPoints; i++) {
        AutomationPoint point = automationPoints[i];

        if (point.sampleTime == AUEventSampleTimeImmediate || point.sampleTime == 0) {
            continue;
        }

        if (point.sampleTime < sampleTime) {
            automationPoints[i].sampleTime = sampleTime;
            printf("→→→ Adjusted late point's time to %f was %lld\n", sampleTime, point.sampleTime);
        }
    }
}

#pragma mark - Deinit

- (void)dealloc {
    // AKLog(@"* { AKParameterAutomation.dealloc }");
    [self stopAutomation];
    tap = nil;
    auAudioUnit = nil;
    avAudioUnit = nil;
}

@end
