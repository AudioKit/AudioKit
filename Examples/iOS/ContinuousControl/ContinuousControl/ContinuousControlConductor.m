//
//  ContinuousControlConductor.m
//  ContinuousControl
//
//  Created by Aurelius Prochazka on 8/4/14.
//  Copyright (c) 2014 h4y. All rights reserved.
//

#import "ContinuousControlConductor.h"
#import "AKFoundation.h"

@implementation ContinuousControlConductor
{
    NSTimer *frequencyTimer;
    NSTimer *modIndexTimer;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.tweakableInstrument = [[TweakableInstrument alloc] init];
        [AKOrchestra addInstrument:_tweakableInstrument];
        [AKOrchestra start];
    }
    return self;
}

- (id)schedule:(SEL)selector
    afterDelay:(float)delayTime;
{
    return [NSTimer scheduledTimerWithTimeInterval:delayTime
                                            target:self
                                          selector:selector
                                          userInfo:nil
                                           repeats:YES];
}

- (void)start
{
    [self.tweakableInstrument play];
    [self.tweakableInstrument.frequency randomize];
    
    if (frequencyTimer) {
        return;
    } else {
        frequencyTimer = [self schedule:@selector(randomizeFrequency:) afterDelay:3.0f];
        modIndexTimer  = [self schedule:@selector(randomizeModIndex:)  afterDelay:0.2f];
#if TARGET_OS_IPHONE
#elif TARGET_OS_MAC
        [[NSRunLoop currentRunLoop] addTimer:frequencyTimer forMode:NSEventTrackingRunLoopMode];
        [[NSRunLoop currentRunLoop] addTimer:modIndexTimer  forMode:NSEventTrackingRunLoopMode];
#endif
    }
}

- (void)stop
{
    [self.tweakableInstrument stop];
    [frequencyTimer invalidate];
    frequencyTimer = nil;
    [modIndexTimer invalidate];
    modIndexTimer = nil;
}

- (void)randomizeFrequency:(NSTimer *)timer {
    [self.tweakableInstrument.frequency randomize];
}

- (void)randomizeModIndex:(NSTimer *)timer {
    [self.tweakableInstrument.modIndex randomize];
}

@end
