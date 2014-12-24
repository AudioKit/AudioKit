//
//  AKMandolin.m
//  AudioKit
//
//  Auto-generated on 12/24/14.
//  Customized by Aurelius Prochazka on 12/24/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's mandol:
//  http://www.csounds.com/manual/html/mandol.html
//

#import "AKMandolin.h"
#import "AKManager.h"
#import "AKSoundFileTable.h"

@implementation AKMandolin

- (instancetype)initWithFrequency:(AKParameter *)frequency
                        amplitude:(AKParameter *)amplitude
                         bodySize:(AKParameter *)bodySize
             pairedStringDetuning:(AKParameter *)pairedStringDetuning
                    pluckPosition:(AKParameter *)pluckPosition
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
- (void)setOptionalPluckPosition:(AKParameter *)pluckPosition {
    _pluckPosition = pluckPosition;
}
- (void)setOptionalLoopGain:(AKParameter *)loopGain {
    _loopGain = loopGain;
}

- (NSString *)stringForCSD {
    NSString *file;
    if ([[[AKManager sharedManager] fullPathToAudioKit] isKindOfClass:[NSString class]]) {
        file = [[AKManager sharedManager] fullPathToAudioKit];
        file = [file stringByAppendingPathComponent:@"AudioKit/Operations/Signal Generators/Physical Models/Mandolin/mandpluk.aif"];
    } else {
        file = [[NSBundle mainBundle] pathForResource:@"mandpluk" ofType:@"aif"];
    }
    AKSoundFileTable *_strikeImpulseTable;
    _strikeImpulseTable = [[AKSoundFileTable alloc] initWithFilename:file];
    
    return [NSString stringWithFormat:
            @"%@\n"
            @"%@ mandol AKControl(%@), AKControl(%@), %@, AKControl(%@), AKControl(%@), AKControl(2 * (1 - %@)), %@",
            [_strikeImpulseTable stringForCSD],
            self,
            _amplitude,
            _frequency,
            _pluckPosition,
            _pairedStringDetuning,
            _loopGain,
            _bodySize,
            _strikeImpulseTable];
}

@end
