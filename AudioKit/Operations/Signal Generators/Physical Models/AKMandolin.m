//
//  AKMandolin.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's mandol:
//  http://www.csounds.com/manual/html/mandol.html
//

#import "AKMandolin.h"
#import "AKManager.h"

@implementation AKMandolin

- (instancetype)initWithBodySize:(AKParameter *)bodySize
                       frequency:(AKParameter *)frequency
                       amplitude:(AKParameter *)amplitude
            pairedStringDetuning:(AKParameter *)pairedStringDetuning
                   pluckPosition:(AKConstant *)pluckPosition
                        loopGain:(AKParameter *)loopGain
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _bodySize = bodySize;
        _frequency = frequency;
        _amplitude = amplitude;
        _pairedStringDetuning = pairedStringDetuning;
        _pluckPosition = pluckPosition;
        _loopGain = loopGain;
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _bodySize = akp(0.5);
        _frequency = akp(220);
        _amplitude = akp(1);
        _pairedStringDetuning = akp(1);
        _pluckPosition = akp(0.4);
        _loopGain = akp(0.99);
    }
    return self;
}

+ (instancetype)mandolin
{
    return [[AKMandolin alloc] init];
}

- (void)setOptionalBodySize:(AKParameter *)bodySize {
    _bodySize = bodySize;
}
- (void)setOptionalFrequency:(AKParameter *)frequency {
    _frequency = frequency;
}
- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
}
- (void)setOptionalPairedStringDetuning:(AKParameter *)pairedStringDetuning {
    _pairedStringDetuning = pairedStringDetuning;
}
- (void)setOptionalPluckPosition:(AKConstant *)pluckPosition {
    _pluckPosition = pluckPosition;
}
- (void)setOptionalLoopGain:(AKParameter *)loopGain {
    _loopGain = loopGain;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];

    // Constant Values  
    NSString *file = [[NSBundle mainBundle] pathForResource:@"mandpluk" ofType:@"aif"];
    if (!file) {
        file = @"CsoundLib64.framework/Sounds/mandpluk.aif";
    }

    AKSoundFile *_strikeImpulseTable;
    _strikeImpulseTable = [[AKSoundFile alloc] initWithFilename:file];
    [[[[AKManager sharedManager] orchestra] functionTables] addObject:_strikeImpulseTable];
            
    [csdString appendFormat:@"%@ mandol ", self];

    if ([_amplitude class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _amplitude];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _amplitude];
    }

    if ([_frequency class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _frequency];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _frequency];
    }

    [csdString appendFormat:@"%@, ", _pluckPosition];
    
    if ([_pairedStringDetuning class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _pairedStringDetuning];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _pairedStringDetuning];
    }

    if ([_loopGain class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _loopGain];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _loopGain];
    }

    if ([_bodySize class] == [AKControl class]) {
        [csdString appendFormat:@"2 * (1 - %@), ", _bodySize];
    } else {
        [csdString appendFormat:@"AKControl(2 * (1 - %@)), ", _bodySize];
    }

    [csdString appendFormat:@"%@", _strikeImpulseTable];
    return csdString;
}

@end
