//
//  AKFMOscillator.m
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/26/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//
//  Implementation of Csound's foscili:
//  http://www.csounds.com/manual/html/foscili.html
//

#import "AKFMOscillator.h"
#import "AKManager.h"

@implementation AKFMOscillator

- (instancetype)initWithFTable:(AKFTable *)fTable
                 baseFrequency:(AKControl *)baseFrequency
             carrierMultiplier:(AKParameter *)carrierMultiplier
          modulatingMultiplier:(AKParameter *)modulatingMultiplier
               modulationIndex:(AKControl *)modulationIndex
                     amplitude:(AKParameter *)amplitude
                         phase:(AKConstant *)phase
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _fTable = fTable;
        _baseFrequency = baseFrequency;
        _carrierMultiplier = carrierMultiplier;
        _modulatingMultiplier = modulatingMultiplier;
        _modulationIndex = modulationIndex;
        _amplitude = amplitude;
        _phase = phase;
        
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        
        // Default Values
        _fTable = [AKManager sharedAKManager].standardSineTable;
        
        _baseFrequency = akp(440);
        _carrierMultiplier = akp(1);
        _modulatingMultiplier = akp(1);
        _modulationIndex = akp(1);
        _amplitude = akp(0.5);
        _phase = akp(0);
    }
    return self;
}

+ (instancetype)audio
{
    return [[AKFMOscillator alloc] init];
}

- (void)setOptionalFTable:(AKFTable *)fTable {
    _fTable = fTable;
}

- (void)setOptionalBaseFrequency:(AKControl *)baseFrequency {
    _baseFrequency = baseFrequency;
}

- (void)setOptionalCarrierMultiplier:(AKParameter *)carrierMultiplier {
    _carrierMultiplier = carrierMultiplier;
}

- (void)setOptionalModulatingMultiplier:(AKParameter *)modulatingMultiplier {
    _modulatingMultiplier = modulatingMultiplier;
}

- (void)setOptionalModulationIndex:(AKControl *)modulationIndex {
    _modulationIndex = modulationIndex;
}

- (void)setOptionalAmplitude:(AKParameter *)amplitude {
    _amplitude = amplitude;
}

- (void)setOptionalPhase:(AKConstant *)phase {
    _phase = phase;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ foscili %@, %@, %@, %@, %@, %@, %@",
            self,
            _amplitude,
            _baseFrequency,
            _carrierMultiplier,
            _modulatingMultiplier,
            _modulationIndex,
            _fTable,
            _phase];
}


@end
