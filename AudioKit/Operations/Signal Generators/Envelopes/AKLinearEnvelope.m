//
//  AKLinearEnvelope.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Customized by Aurelius Prochazka on 1/15/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's linen:
//  http://www.csounds.com/manual/html/linen.html
//

#import "AKLinearEnvelope.h"
#import "AKManager.h"

@implementation AKLinearEnvelope {
    BOOL _decayNoteAfterStop;
}

- (instancetype)initWithRiseTime:(AKConstant *)riseTime
                       decayTime:(AKConstant *)decayTime
                   totalDuration:(AKConstant *)totalDuration
                       amplitude:(AKParameter *)amplitude
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _riseTime = riseTime;
        _decayTime = decayTime;
        _totalDuration = totalDuration;
        _amplitude = amplitude;
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _riseTime = akp(0.33);
        _decayTime = akp(0.33);
        _totalDuration = akp(1);
        _amplitude = akp(1);
    }
    return self;
}

+ (instancetype)envelope
{
    return [[AKLinearEnvelope alloc] init];
}

- (void)setOptionalRiseTime:(AKConstant *)riseTime {
    _riseTime = riseTime;
}
- (void)setOptionalDecayTime:(AKConstant *)decayTime {
    _decayTime = decayTime;
}
- (void)setOptionalTotalDuration:(AKConstant *)totalDuration {
    _totalDuration = totalDuration;
}
- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
}

- (void)decayOnlyOnRelease:(BOOL)decayOnRelease
{
    _decayNoteAfterStop = decayOnRelease;
}

- (NSString *)stringForCSD {
    
    NSString *opcode = @"linen";
    if (_decayNoteAfterStop) opcode = @"linenr";
    
    NSMutableString *csdString = [[NSMutableString alloc] init];

    [csdString appendFormat:@"%@ %@ ", self, opcode];

    if ([_amplitude class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _amplitude];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _amplitude];
    }

    [csdString appendFormat:@"%@, ", _riseTime];
    
    [csdString appendFormat:@"%@, ", _totalDuration];
    
    [csdString appendFormat:@"%@", _decayTime];
    return csdString;
}

@end
