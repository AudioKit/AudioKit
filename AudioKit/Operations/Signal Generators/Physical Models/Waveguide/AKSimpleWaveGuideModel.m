//
//  AKSimpleWaveGuideModel.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's wguide1:
//  http://www.csounds.com/manual/html/wguide1.html
//

#import "AKSimpleWaveGuideModel.h"
#import "AKManager.h"

@implementation AKSimpleWaveGuideModel
{
    AKParameter * _input;
}

- (instancetype)initWithInput:(AKParameter *)input
                    frequency:(AKParameter *)frequency
                       cutoff:(AKParameter *)cutoff
                     feedback:(AKParameter *)feedback
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        _frequency = frequency;
        _cutoff = cutoff;
        _feedback = feedback;
    }
    return self;
}

- (instancetype)initWithInput:(AKParameter *)input
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _input = input;
        // Default Values
        _frequency = akp(440);
        _cutoff = akp(3000);
        _feedback = akp(0.8);
    }
    return self;
}

+ (instancetype)modelWithInput:(AKParameter *)input
{
    return [[AKSimpleWaveGuideModel alloc] initWithInput:input];
}

- (void)setOptionalFrequency:(AKParameter *)frequency {
    _frequency = frequency;
}
- (void)setOptionalCutoff:(AKParameter *)cutoff {
    _cutoff = cutoff;
}
- (void)setOptionalFeedback:(AKParameter *)feedback {
    _feedback = feedback;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ wguide1 ", self];

    if ([_input class] == [AKAudio class]) {
        [csdString appendFormat:@"%@, ", _input];
    } else {
        [csdString appendFormat:@"AKAudio(%@), ", _input];
    }

    [csdString appendFormat:@"%@, ", _frequency];
    
    if ([_cutoff class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _cutoff];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _cutoff];
    }

    if ([_feedback class] == [AKControl class]) {
        [csdString appendFormat:@"%@", _feedback];
    } else {
        [csdString appendFormat:@"AKControl(%@)", _feedback];
    }
return csdString;
}

@end
