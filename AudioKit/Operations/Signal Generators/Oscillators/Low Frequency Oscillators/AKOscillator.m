//
//  AKOscillator.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/2/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's oscili:
//  http://www.csounds.com/manual/html/oscili.html
//

#import "AKOscillator.h"
#import "AKManager.h"

@implementation AKOscillator

- (instancetype)initWithFrequency:(AKParameter *)frequency
                        amplitude:(AKParameter *)amplitude
                           fTable:(AKFTable *)fTable
                            phase:(AKConstant *)phase
{
    self = [super initWithString:[self operationName]];
    if (self) {
            _frequency = frequency;
                _amplitude = amplitude;
                _fTable = fTable;
                _phase = phase;
        
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        
    // Default Values   
            _frequency = akp(440);        
            _amplitude = akp(1);        
           _fTable = [AKManager standardSineTable];
            
            _phase = akp(0);            
    }
    return self;
}

+ (instancetype)audio
 {
    return [[AKOscillator alloc] init];
}

- (void)setOptionalFrequency:(AKParameter *)frequency {
    _frequency = frequency;
}

- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
}

- (void)setOptionalFTable:(AKFTable *)fTable {
    _fTable = fTable;
}

- (void)setOptionalPhase:(AKConstant *)phase {
    _phase = phase;
}

- (NSString *)stringForCSD {
        return [NSString stringWithFormat:
            @"%@ oscili %@, %@, %@, %@",
            self,
            _amplitude,
            _frequency,
            _fTable,
            _phase];
}


@end
