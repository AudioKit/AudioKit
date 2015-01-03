//
//  AKMoogLadder.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's moogladder:
//  http://www.csounds.com/manual/html/moogladder.html
//

#import "AKMoogLadder.h"
#import "AKManager.h"

@implementation AKMoogLadder
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
        _cutoffFrequency = akp(100);
        _resonance = akp(0.5);
    }
    return self;
}

+ (instancetype)filterWithInput:(AKParameter *)input
{
    return [[AKMoogLadder alloc] initWithInput:input];
}

- (void)setOptionalCutoffFrequency:(AKParameter *)cutoffFrequency {
    _cutoffFrequency = cutoffFrequency;
}
- (void)setOptionalResonance:(AKParameter *)resonance {
    _resonance = resonance;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ moogladder ", self];

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
        [csdString appendFormat:@"%@", _resonance];
    } else {
        [csdString appendFormat:@"AKControl(%@)", _resonance];
    }
return csdString;
}

@end
