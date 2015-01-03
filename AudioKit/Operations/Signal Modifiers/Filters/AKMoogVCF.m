//
//  AKMoogVCF.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's moogvcf2:
//  http://www.csounds.com/manual/html/moogvcf2.html
//

#import "AKMoogVCF.h"
#import "AKManager.h"

@implementation AKMoogVCF
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
              cutoffFrequency:(AKParameter *)cutoffFrequency
                    resonance:(AKParameter *)resonance
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _cutoffFrequency = cutoffFrequency;
        _resonance = resonance;
    }
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _cutoffFrequency = akp(1000);
        _resonance = akp(0.5);
    }
    return self;
}

+ (instancetype)filterWithInput:(AKParameter *)input
{
    return [[AKMoogVCF alloc] initWithInput:input];
}

- (void)setOptionalCutoffFrequency:(AKParameter *)cutoffFrequency {
    _cutoffFrequency = cutoffFrequency;
}
- (void)setOptionalResonance:(AKParameter *)resonance {
    _resonance = resonance;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ moogvcf2 ", self];

    if ([_input class] == [AKAudio class]) {
        [csdString appendFormat:@"%@, ", _input];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _input];
    }

    [csdString appendFormat:@"%@, ", _cutoffFrequency];
    
    [csdString appendFormat:@"%@", _resonance];
    return csdString;
}

@end
