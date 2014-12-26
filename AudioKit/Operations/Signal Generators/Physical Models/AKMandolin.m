//
//  AKMandolin.m
//  AudioKit
//
//  Auto-generated on 12/25/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's mandol:
//  http://www.csounds.com/manual/html/mandol.html
//

#import "AKMandolin.h"
#import "AKManager.h"

@implementation AKMandolin

- (instancetype)initWithFrequency:(AKParameter *)frequency
                        amplitude:(AKParameter *)amplitude
                         bodySize:(AKParameter *)bodySize
             pairedStringDetuning:(AKParameter *)pairedStringDetuning
                    pluckPosition:(AKConstant *)pluckPosition
                         loopGain:(AKParameter *)loopGain
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _frequency = frequency;
        _amplitude = amplitude;
        _bodySize = bodySize;
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
        _frequency = akp(220);
        _amplitude = akp(1);
        _bodySize = akp(0.5);
        _pairedStringDetuning = akp(1);
        _pluckPosition = akp(0.4);
        _loopGain = akp(0.99);
    }
    return self;
}

+ (instancetype)audio
{
    return [[AKMandolin alloc] init];
}

- (void)setOptionalFrequency:(AKParameter *)frequency {
    _frequency = frequency;
}
- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
}
- (void)setOptionalBodySize:(AKParameter *)bodySize {
    _bodySize = bodySize;
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
    NSString *file;
    AKSoundFileTable *fileTable;
    fileTable = [[AKSoundFileTable alloc] initWithFilename:file];

    if ([[[AKManager sharedManager] fullPathToAudioKit] isKindOfClass:[NSString class]]) {
        file = [[AKManager sharedManager] fullPathToAudioKit];
        file = [file stringByAppendingPathComponent:@"AudioKit/Libraries/Sound Files/mandpluk.aif"];
    } else {
        file = [[NSBundle mainBundle] pathForResource:@"mandpluk" ofType:@"aif"];
    }
    AKSoundFileTable *_strikeImpulseTable;
    _strikeImpulseTable = [[AKSoundFileTable alloc] initWithFilename:file];
    [csdString appendFormat:@"%@\n", [_strikeImpulseTable stringForCSD]];
            
    [csdString appendFormat:@"%@ mandol ", self];

    if ([_amplitude isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _amplitude];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _amplitude];
    }

    if ([_frequency isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _frequency];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _frequency];
    }

    [csdString appendFormat:@"%@, ", _pluckPosition];
    
    if ([_pairedStringDetuning isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _pairedStringDetuning];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _pairedStringDetuning];
    }

    if ([_loopGain isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"%@, ", _loopGain];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _loopGain];
    }

    if ([_bodySize isKindOfClass:[AKControl class]] ) {
        [csdString appendFormat:@"2 * (1 - %@), ", _bodySize];
    } else {
        [csdString appendFormat:@"AKControl(2 * (1 - %@)), ", _bodySize];
    }

    [csdString appendFormat:@"%@", _strikeImpulseTable];
    return csdString;
}

@end
