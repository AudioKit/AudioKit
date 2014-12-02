//
//  AKOscillator.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/1/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's oscili:
//  http://www.csounds.com/manual/html/oscili.html
//

#import "AKOscillator.h"
#import "AKManager.h"

@implementation AKOscillator

- (instancetype)initWithFrequency:(AKParameter *)frequency
                           fTable:(AKFTable *)fTable
                            phase:(AKConstant *)phase
{
    self = [super initWithString:[self operationName]];
    if (self) {
            _frequency = frequency;
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

- (void)setOptionalFTable:(AKFTable *)fTable {
    _fTable = fTable;
}

- (void)setOptionalPhase:(AKConstant *)phase {
    _phase = phase;
}

- (NSString *)stringForCSD {
        // Constant Values  
                    AKConstant *_amplitude = akp(1);        
        return [NSString stringWithFormat:
            @"%@ oscili %@, %@, %@, %@",
            self,
            _amplitude,
            _frequency,
            _fTable,
            _phase];
}


@end
