// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#import "AKParameterAutomation.h"
#import "AKTimelineTap.h"

typedef struct AutomationPointInternal {
    AutomationPoint automation;
    AUParameterAddress address;
} AutomationPointInternal;

@implementation AKParameterAutomation
{
    AKTimelineTap *tap;
    AUAudioUnit *auAudioUnit;
    AVAudioUnit *avAudioUnit;
    Float64 lastRenderTime;
    AVAudioTime *anchorTime;
    AUEventSampleTime endTime;

    // currently a fixed buffer of automation points
    AutomationPointInternal automationPoints[MAX_NUMBER_OF_POINTS];
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
    // See: AKManager.renderToFile
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

    AKTimelineSetTimeAtTime(tap.timeline, 0, anchorTime.audioTimeStamp);
    AKTimelineStartAtTime(tap.timeline, anchorTime.audioTimeStamp);
}

- (void)stopAutomation {
    if (!AKTimelineIsStarted(tap.timeline)) {
        [self clear];
        return;
    }
    AKTimelineStop(tap.timeline);
    lastRenderTime = tap.timeline->lastRenderTime.mSampleTime;
    [self clear];

    // NSLog(@"stopping automation at time %f", tap.timeline->lastRenderTime.mSampleTime);
}

#pragma mark - Render Block

void scheduleAutomation(AUAudioUnit *au, AUEventSampleTime time, const AutomationPointInternal* point) {
    // set taper (mask = 1 << 63, taper is "value" parameter)
    au.scheduleParameterBlock(time, 0, point->address | ((AUParameterAddress)1 << 63), point->automation.taper);
    
    // set skew (mask = 1 << 62, skew is "value" parameter)
    au.scheduleParameterBlock(time, 0, point->address | ((AUParameterAddress)1 << 62), point->automation.skew);
    
    // set offset (mask = 1 << 61, offset is "duration" parameter)
    au.scheduleParameterBlock(time, point->automation.offset, point->address | ((AUParameterAddress)1 << 61), 0);
    
    // set value
    au.scheduleParameterBlock(time, point->automation.rampDuration, point->address, point->automation.value);
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

       // TODO: allow for a timed duration stop to end automation - don't use this:
       //AUEventSampleTime endTime = welf->endTime;

       for (int n = 0; n < inNumberFrames; n++) {
           AUEventSampleTime sampleTimeWithOffset = sampleTime + n;
           for (int p = 0; p < welf->numberOfPoints; p++) {
               AutomationPointInternal point = welf->automationPoints[p];
               if (point.automation.triggered) continue;

               if (point.automation.sampleTime == AUEventSampleTimeImmediate || point.automation.sampleTime < sampleTimeWithOffset) {
                   scheduleAutomation(welf->auAudioUnit, AUEventSampleTimeImmediate, &point);
                   welf->automationPoints[p].automation.triggered = true;
                   continue;
               }

               if (sampleTimeWithOffset == point.automation.sampleTime) {
                   scheduleAutomation(welf->auAudioUnit, AUEventSampleTimeImmediate + n, &point);
                   welf->automationPoints[p].automation.triggered = true;
               }
           }
       }
    };
}

#pragma mark - Add and remove points

- (void)addPoint:(NSString *)identifier
           value:(AUValue)value
      sampleTime:(AUEventSampleTime)sampleTime
      anchorTime:(AUEventSampleTime)anchorTime
    rampDuration:(AUAudioFrameCount)rampDuration {
    struct AutomationPoint point = {};
    point.identifier = identifier;
    point.value = value;
    point.sampleTime = sampleTime;
    point.anchorTime = anchorTime;
    point.rampDuration = rampDuration;
    point.taper = 1;

    [self addPoint:point];
}

- (void)addPoint:(NSString *)identifier
           value:(AUValue)value
      sampleTime:(AUEventSampleTime)sampleTime
      anchorTime:(AUEventSampleTime)anchorTime
    rampDuration:(AUAudioFrameCount)rampDuration
           taper:(AUValue)taper
            skew:(AUValue)skew
          offset:(AUAudioFrameCount)offset{
    struct AutomationPoint point = {};
    point.identifier = identifier;
    point.value = value;
    point.sampleTime = sampleTime;
    point.anchorTime = anchorTime;
    point.rampDuration = rampDuration;
    point.taper = taper;
    point.skew = skew;
    point.offset = offset;
    
    [self addPoint:point];
}

- (void)addPoint:(struct AutomationPoint)point {
    // add to the list of points

    if (numberOfPoints + 1 >= MAX_NUMBER_OF_POINTS) {
        NSLog(@"Max number of points was reached.");
        return;
    }
    
    AUParameter *param = [auAudioUnit.parameterTree valueForKey:point.identifier];
    
    AutomationPointInternal _point;
    _point.address = param.address;
    _point.automation = point;
    
    automationPoints[numberOfPoints] = _point;
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
        AutomationPointInternal point = automationPoints[i];

        if (point.automation.sampleTime == AUEventSampleTimeImmediate || point.automation.sampleTime == 0) {
            continue;
        }

        if (point.automation.sampleTime < sampleTime) {
            automationPoints[i].automation.sampleTime = sampleTime;
            printf("→→→ Adjusted late point's time to %f was %lld\n", sampleTime, point.automation.sampleTime);
        }
    }
}

#pragma mark - Deinit

- (void)dealloc {
    [self stopAutomation];
    tap = nil;
    auAudioUnit = nil;
    avAudioUnit = nil;
}

@end
