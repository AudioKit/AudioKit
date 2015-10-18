//
//  AKBeatClock.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/26/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKBeatClock.h"

@implementation AKBeatClock

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _tempo = [self createPropertyWithValue:400  minimum:10 maximum:10000];
        _numberOfBeats = [self createPropertyWithValue:16 minimum:1 maximum:1024];
        
        // Instrument Definition
        AKPhasor *phasor = [[AKPhasor alloc] initWithFrequency:[_tempo dividedBy:akp(4.0*60.0)]
                                                         phase:akp(0)];
        AKPhasor *beat = [[phasor scaledBy:_numberOfBeats] round];

        [self logChangesToParameter:beat withMessage:@"clock "];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(messageReceivedFromCsound:)
                                                     name:@"AKBeatClock"
                                                   object:nil];
    }
    return self;
}


- (void)messageReceivedFromCsound:(NSNotification *)notification
{
    int beat =  roundf([notification.userInfo[@"message"] floatValue]);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Beat" object:[NSNumber numberWithInt:beat]];
}


@end
