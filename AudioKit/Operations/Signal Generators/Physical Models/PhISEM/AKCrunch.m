//
//  AKCrunch.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/11/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's crunch:
//  http://www.csounds.com/manual/html/crunch.html
//

#import "AKCrunch.h"
#import "AKManager.h"

@implementation AKCrunch

- (instancetype)initWithIntensity:(AKConstant *)intensity
                    dampingFactor:(AKConstant *)dampingFactor
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _intensity = intensity;
        _dampingFactor = dampingFactor;
        
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        
        // Default Values
        _intensity = akp(100);
        _dampingFactor = akp(0.1);
    }
    return self;
}

+ (instancetype)audio
{
    return [[AKCrunch alloc] init];
}

- (void)setOptionalIntensity:(AKConstant *)intensity {
    _intensity = intensity;
}

- (void)setOptionalDampingFactor:(AKConstant *)dampingFactor {
    _dampingFactor = dampingFactor;
}
- (NSString *)stringForCSD {
    // Constant Values
    AKConstant *_maximumDuration = akp(1);
    AKConstant *_energyReturn = akp(0);
    AKConstant *_amplitude = akp(1);
    return [NSString stringWithFormat:
            @"%@ crunch %@, %@, %@, (1 - %@), %@",
            self,
            _amplitude,
            _maximumDuration,
            _intensity,
            _dampingFactor,
            _energyReturn];
}


@end
