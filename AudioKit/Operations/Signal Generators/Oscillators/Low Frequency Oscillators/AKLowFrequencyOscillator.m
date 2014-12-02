//
//  AKLowFrequencyOscillator.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/2/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's lfo:
//  http://www.csounds.com/manual/html/lfo.html
//

#import "AKLowFrequencyOscillator.h"
#import "AKManager.h"

@implementation AKLowFrequencyOscillator

- (instancetype)initWithFrequency:(AKControl *)frequency
                             type:(AKConstant *)type
{
    self = [super initWithString:[self operationName]];
    if (self) {
            _frequency = frequency;
                _type = type;
        
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        
    // Default Values   
            _frequency = akp(440);        
            _type = akp(0);            
    }
    return self;
}

+ (instancetype)audio
 {
    return [[AKLowFrequencyOscillator alloc] init];
}

- (void)setOptionalFrequency:(AKControl *)frequency {
    _frequency = frequency;
}

- (void)setOptionalType:(AKConstant *)type {
    _type = type;
}

- (NSString *)stringForCSD {
        // Constant Values  
                    AKConstant *_amplitude = akp(1);        
        return [NSString stringWithFormat:
            @"%@ lfo %@, %@, %@",
            self,
            _amplitude,
            _frequency,
            _type];
}


@end
