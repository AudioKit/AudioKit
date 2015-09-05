//
//  AKInstrument.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 9/4/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKInstrument.h"
#import "AKFMOscillator.h"

@implementation AKInstrument {
    AKFMOscillator *fmOscillator;
    AKFMOscillator *fmOscillatorDefault;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _operations = [NSMutableArray array];
        
        fmOscillatorDefault = [[AKFMOscillator alloc] initWithBaseFrequency:akp(0.1)
                                                          carrierMultiplier:akp(10)
                                                       modulatingMultiplier:akp(3)
                                                            modulationIndex:akp(20)
                                                                  amplitude:akp(440)];
        
        fmOscillator = [[AKFMOscillator alloc] initWithBaseFrequency:fmOscillatorDefault
                                                   carrierMultiplier:akp(1)
                                                modulatingMultiplier:akp(0.1)
                                                     modulationIndex:akp(1)
                                                           amplitude:akp(0.6)];
        
        // Kind of like our old connect, will have to be cleaned up
        [_operations addObject:fmOscillatorDefault];
        [_operations addObject:fmOscillator];
    }
    return self;
}

@end
