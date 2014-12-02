//
//  AKSineOscillator.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/2/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's oscils:
//  http://www.csounds.com/manual/html/oscils.html
//

#import "AKSineOscillator.h"
#import "AKManager.h"

@implementation AKSineOscillator

- (instancetype)initWithFrequency:(AKConstant *)frequency
                            phase:(AKConstant *)phase
{
    self = [super initWithString:[self operationName]];
    if (self) {
            _frequency = frequency;
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
            _phase = akp(0);            
    }
    return self;
}

+ (instancetype)audio
 {
    return [[AKSineOscillator alloc] init];
}

- (void)setOptionalFrequency:(AKConstant *)frequency {
    _frequency = frequency;
}

- (void)setOptionalPhase:(AKConstant *)phase {
    _phase = phase;
}

- (NSString *)stringForCSD {
        // Constant Values  
                    AKConstant *_amplitude = akp(1);        
        return [NSString stringWithFormat:
            @"%@ oscils %@, %@, %@",
            self,
            _amplitude,
            _frequency,
            _phase];
}


@end
