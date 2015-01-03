//
//  AKCrunch.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's crunch:
//  http://www.csounds.com/manual/html/crunch.html
//

#import "AKCrunch.h"
#import "AKManager.h"

@implementation AKCrunch

- (instancetype)initWithIntensity:(AKConstant *)intensity
                    dampingFactor:(AKConstant *)dampingFactor
                        amplitude:(AKConstant *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _intensity = intensity;
        _dampingFactor = dampingFactor;
        _amplitude = amplitude;
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
        _amplitude = akp(1);
    }
    return self;
}

+ (instancetype)crunch
{
    return [[AKCrunch alloc] init];
}

- (void)setOptionalIntensity:(AKConstant *)intensity {
    _intensity = intensity;
}
- (void)setOptionalDampingFactor:(AKConstant *)dampingFactor {
    _dampingFactor = dampingFactor;
}
- (void)setOptionalAmplitude:(AKConstant *)amplitude {
    _amplitude = amplitude;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    // Constant Values  
    AKConstant *_maximumDuration = akp(1);        
    AKConstant *_energyReturn = akp(0);        
    [csdString appendFormat:@"%@ crunch ", self];

    [csdString appendFormat:@"%@, ", _amplitude];
    
    [csdString appendFormat:@"%@, ", _maximumDuration];
    
    [csdString appendFormat:@"%@, ", _intensity];
    
    [csdString appendFormat:@"(1 - %@), ", _dampingFactor];
    
    [csdString appendFormat:@"%@", _energyReturn];
    return csdString;
}

@end
