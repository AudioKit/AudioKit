//
//  AKSandPaper.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/11/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's sandpaper:
//  http://www.csounds.com/manual/html/sandpaper.html
//

#import "AKSandPaper.h"
#import "AKManager.h"

@implementation AKSandPaper

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
        _intensity = akp(128);
        _dampingFactor = akp(0.9);
    }
    return self;
}

+ (instancetype)audio
{
    return [[AKSandPaper alloc] init];
}

- (void)setOptionalIntensity:(AKConstant *)intensity {
    _intensity = intensity;
}

- (void)setOptionalDampingFactor:(AKConstant *)dampingFactor {
    _dampingFactor = dampingFactor;
}
- (NSString *)stringForCSD {
    // Constant Values
    AKConstant *_amplitude = akp(1);
    AKConstant *_energyReturn = akp(0);
    AKConstant *_maximumDuration = akp(1);
    return [NSString stringWithFormat:
            @"%@ sandpaper %@, %@, %@, (1 - %@), %@",
            self,
            _amplitude,
            _maximumDuration,
            _intensity,
            _dampingFactor,
            _energyReturn];
}


@end
