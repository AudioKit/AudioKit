//
//  AKOscillator.m
//  AudioKit
//
//  Auto-generated on 12/21/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's oscili:
//  http://www.csounds.com/manual/html/oscili.html
//

#import "AKOscillator.h"
#import "AKManager.h"

@implementation AKOscillator

- (instancetype)initWithFTable:(AKFTable *)fTable
                     frequency:(AKParameter *)frequency
                     amplitude:(AKParameter *)amplitude
                         phase:(AKConstant *)phase
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _fTable = fTable;
        _frequency = frequency;
        _amplitude = amplitude;
        _phase = phase;
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _fTable = [AKManager standardSineTable];
        
        _frequency = akp(440);    
        _amplitude = akp(1);    
        _phase = akp(0);    
    }
    return self;
}

+ (instancetype)audio
{
    return [[AKOscillator alloc] init];
}

- (void)setOptionalFTable:(AKFTable *)fTable {
    _fTable = fTable;
}
- (void)setOptionalFrequency:(AKParameter *)frequency {
    _frequency = frequency;
}
- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
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
