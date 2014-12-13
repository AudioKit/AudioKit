//
//  AKGuiro.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/27/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's guiro:
//  http://www.csounds.com/manual/html/guiro.html
//

#import "AKGuiro.h"
#import "AKManager.h"

@implementation AKGuiro

- (instancetype)initWithCount:(AKConstant *)count
        mainResonantFrequency:(AKConstant *)mainResonantFrequency
       firstResonantFrequency:(AKConstant *)firstResonantFrequency
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _count = count;
        _mainResonantFrequency = mainResonantFrequency;
        _firstResonantFrequency = firstResonantFrequency;
        
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {

        // Default Values
        _count = akp(128);
        _mainResonantFrequency = akp(2500);
        _firstResonantFrequency = akp(4000);
    }
    return self;
}

+ (instancetype)audio
{
    return [[AKGuiro alloc] init];
}

- (void)setOptionalCount:(AKConstant *)count {
    _count = count;
}

- (void)setOptionalMainResonantFrequency:(AKConstant *)mainResonantFrequency {
    _mainResonantFrequency = mainResonantFrequency;
}

- (void)setOptionalFirstResonantFrequency:(AKConstant *)firstResonantFrequency {
    _firstResonantFrequency = firstResonantFrequency;
}

- (NSString *)stringForCSD {
    // Constant Values
    AKConstant *_energyReturn = akp(0);
    AKConstant *_maximumDuration = akp(1.0);
    AKConstant *_amplitude = akp(1.0);
    AKConstant *_dampingFactor = akp(0);
    return [NSString stringWithFormat:
            @"%@ guiro %@, %@, %@, %@, %@, %@, %@",
            self,
            _amplitude,
            _maximumDuration,
            _count,
            _dampingFactor,
            _energyReturn,
            _mainResonantFrequency,
            _firstResonantFrequency];
}


@end
