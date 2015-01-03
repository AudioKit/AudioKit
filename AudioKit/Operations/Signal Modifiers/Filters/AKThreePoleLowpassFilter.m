//
//  AKThreePoleLowpassFilter.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's lpf18:
//  http://www.csounds.com/manual/html/lpf18.html
//

#import "AKThreePoleLowpassFilter.h"
#import "AKManager.h"

@implementation AKThreePoleLowpassFilter
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
                   distortion:(AKParameter *)distortion
              cutoffFrequency:(AKParameter *)cutoffFrequency
                    resonance:(AKParameter *)resonance
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _distortion = distortion;
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
        _distortion = akp(0.5);
        _cutoffFrequency = akp(1500);
        _resonance = akp(0.5);
    }
    return self;
}

+ (instancetype)filterWithInput:(AKParameter *)input
{
    return [[AKThreePoleLowpassFilter alloc] initWithInput:input];
}

- (void)setOptionalDistortion:(AKParameter *)distortion {
    _distortion = distortion;
}
- (void)setOptionalCutoffFrequency:(AKParameter *)cutoffFrequency {
    _cutoffFrequency = cutoffFrequency;
}
- (void)setOptionalResonance:(AKParameter *)resonance {
    _resonance = resonance;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ lpf18 ", self];

    if ([_input class] == [AKAudio class]) {
        [csdString appendFormat:@"%@, ", _input];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _input];
    }

    if ([_cutoffFrequency class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _cutoffFrequency];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _cutoffFrequency];
    }

    if ([_resonance class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _resonance];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _resonance];
    }

    if ([_distortion class] == [AKControl class]) {
        [csdString appendFormat:@"%@", _distortion];
    } else {
        [csdString appendFormat:@"AKControl(%@)", _distortion];
    }
return csdString;
}

@end
