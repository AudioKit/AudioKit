//
//  AKMandolin.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 12/10/14.
//  Customized by Aurelius Prochazka on 12/10/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's mandol:
//  http://www.csounds.com/manual/html/mandol.html
//

#import "AKMandolin.h"
#import "AKManager.h"
#import "AKSoundFileTable.h"

@implementation AKMandolin

- (instancetype)initWithFrequency:(AKControl *)frequency
                         bodySize:(AKControl *)bodySize
             pairedStringDetuning:(AKControl *)pairedStringDetuning
                    pluckPosition:(AKControl *)pluckPosition
                         loopGain:(AKControl *)loopGain
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _frequency = frequency;
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

- (void)setOptionalFrequency:(AKControl *)frequency {
    _frequency = frequency;
}

- (void)setOptionalBodySize:(AKControl *)bodySize {
    _bodySize = bodySize;
}

- (void)setOptionalPairedStringDetuning:(AKControl *)pairedStringDetuning {
    _pairedStringDetuning = pairedStringDetuning;
}

- (void)setOptionalPluckPosition:(AKControl *)pluckPosition {
    _pluckPosition = pluckPosition;
}

- (void)setOptionalLoopGain:(AKControl *)loopGain {
    _loopGain = loopGain;
}
- (NSString *)stringForCSD {
    // Constant Values
    AKConstant *_amplitude = akp(1);
    
    NSString *file;
    if ([[[AKManager sharedAKManager] fullPathToAudioKit] isKindOfClass:[NSString class]]) {
        file = [[AKManager sharedAKManager] fullPathToAudioKit];
        file = [file stringByAppendingPathComponent:@"AudioKit/Operations/Signal Generators/Physical Models/Mandolin/mandpluk.aif"];
    } else {
        file = [[NSBundle mainBundle] pathForResource:@"mandpluk" ofType:@"aif"];
    }
    AKSoundFileTable *_strikeImpulseTable;
    _strikeImpulseTable = [[AKSoundFileTable alloc] initWithFilename:file];
    
    return [NSString stringWithFormat:
            @"%@\n"
            @"%@ mandol %@, %@, %@, %@, %@, 2 - (2 * %@), %@",
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
