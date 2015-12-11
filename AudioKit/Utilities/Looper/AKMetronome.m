//
//  AKMetronome.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/10/15.
//  Copyright © 2015 AudioKit. All rights reserved.
//

#import "AKMetronome.h"

@implementation AKMetronome

- (instancetype)initWithTempo:(float)tempo
{
    self = [super init];
    if (self) {
        AKLog *metronome = [[AKLog alloc] initWithMessage:@"tick"
                                                parameter:akp(tempo)
                                             timeInterval:1.0f / tempo];
        [self connect:metronome];
    }
    return self;
}

@end