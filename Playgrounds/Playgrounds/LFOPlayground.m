//
//  LFOPlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/12/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"

@interface LFOInstrument : AKInstrument
@property AKInstrumentProperty *lfo;
@end

@implementation LFOInstrument
- (instancetype)init
{
    self = [super init];
    if (self) {
        _lfo = [self createPropertyWithValue:0.0 minimum:0.0 maximum:30.0];

        AKLowFrequencyOscillator *lfo = [AKLowFrequencyOscillator oscillator];
        lfo.waveformType = [AKLowFrequencyOscillator waveformTypeForSawtooth];
        lfo.amplitude = akp(30);
        lfo.frequency = akp(1);

        [self setParameter:_lfo to:lfo];
    }
    return self;
}

@end

@implementation Playground {
    LFOInstrument *myInstrument;
}

- (void)run
{
    [super run];
    myInstrument = [[LFOInstrument alloc] init];
    [AKOrchestra addInstrument:myInstrument];
    [myInstrument start];


    [self addButtonWithTitle:@"Poll" block:^{
        NSLog(@"LFO Current: %f", myInstrument.lfo.value);
    }];
}


@end
