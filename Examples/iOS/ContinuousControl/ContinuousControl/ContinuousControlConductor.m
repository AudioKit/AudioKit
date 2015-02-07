//
//  ContinuousControlConductor.m
//  ContinuousControl
//
//  Created by Aurelius Prochazka on 8/4/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//

#import "ContinuousControlConductor.h"
#import "AKFoundation.h"

@implementation ContinuousControlConductor
{
    AKSequence *frequencySequence;
    AKSequence *modulationIndexSequence;
    AKEvent *randomizeFrequency;
    AKEvent *randomizeModulationIndex;
    
    NSTimer *frequencyTimer;
    NSTimer *modIndexTimer;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        frequencySequence = [[AKSequence alloc] init];
        modulationIndexSequence = [[AKSequence alloc] init];
        
        randomizeFrequency = [[AKEvent alloc] initWithBlock:^{
            [self.tweakableInstrument.frequency randomize];
            [frequencySequence addEvent:randomizeFrequency afterDuration:3.0];
        }];
        randomizeModulationIndex = [[AKEvent alloc] initWithBlock:^{
            [self.tweakableInstrument.modIndex randomize];
            [modulationIndexSequence addEvent:randomizeModulationIndex afterDuration:0.2];
        }];
        
        [frequencySequence addEvent:randomizeFrequency atTime:3.0];
        [modulationIndexSequence addEvent:randomizeModulationIndex atTime:0.2];

        self.tweakableInstrument = [[TweakableInstrument alloc] init];
        [AKOrchestra addInstrument:_tweakableInstrument];
    }
    
    return self;
}

- (void)start
{
    [self.tweakableInstrument play];
    [self.tweakableInstrument.frequency randomize];
    [frequencySequence play];
    [modulationIndexSequence play];
}

- (void)stop
{
    [self.tweakableInstrument stop];
    [frequencySequence stop];
    [modulationIndexSequence stop];
}

@end
