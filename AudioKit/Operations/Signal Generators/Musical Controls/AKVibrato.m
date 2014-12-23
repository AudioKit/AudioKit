//
//  AKVibrato.m
//  AudioKit
//
//  Auto-generated on 12/23/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's vibrato:
//  http://www.csounds.com/manual/html/vibrato.html
//

#import "AKVibrato.h"
#import "AKManager.h"

@implementation AKVibrato

- (instancetype)initWithVibratoShapeTable:(AKFTable *)vibratoShapeTable
                         averageFrequency:(AKParameter *)averageFrequency
                      frequencyRandomness:(AKParameter *)frequencyRandomness
               minimumFrequencyRandomness:(AKParameter *)minimumFrequencyRandomness
               maximumFrequencyRandomness:(AKParameter *)maximumFrequencyRandomness
                         averageAmplitude:(AKParameter *)averageAmplitude
                       amplitudeDeviation:(AKParameter *)amplitudeDeviation
               minimumAmplitudeRandomness:(AKParameter *)minimumAmplitudeRandomness
               maximumAmplitudeRandomness:(AKParameter *)maximumAmplitudeRandomness
                                    phase:(AKConstant *)phase
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _vibratoShapeTable = vibratoShapeTable;
        _averageFrequency = averageFrequency;
        _frequencyRandomness = frequencyRandomness;
        _minimumFrequencyRandomness = minimumFrequencyRandomness;
        _maximumFrequencyRandomness = maximumFrequencyRandomness;
        _averageAmplitude = averageAmplitude;
        _amplitudeDeviation = amplitudeDeviation;
        _minimumAmplitudeRandomness = minimumAmplitudeRandomness;
        _maximumAmplitudeRandomness = maximumAmplitudeRandomness;
        _phase = phase;
    }
    return self;
}

- (instancetype)init
{
    self = [super initWithString:[self operationName]];
    if (self) {
        // Default Values
        _vibratoShapeTable = [AKManager standardSineTable];
        
        _averageFrequency = akp(2);    
        _frequencyRandomness = akp(0);    
        _minimumFrequencyRandomness = akp(0);    
        _maximumFrequencyRandomness = akp(60);    
        _averageAmplitude = akp(1);    
        _amplitudeDeviation = akp(0);    
        _minimumAmplitudeRandomness = akp(0);    
        _maximumAmplitudeRandomness = akp(0);    
        _phase = akp(0);    
    }
    return self;
}

+ (instancetype)control
{
    return [[AKVibrato alloc] init];
}

- (void)setOptionalVibratoShapeTable:(AKFTable *)vibratoShapeTable {
    _vibratoShapeTable = vibratoShapeTable;
}
- (void)setOptionalAverageFrequency:(AKParameter *)averageFrequency {
    _averageFrequency = averageFrequency;
}
- (void)setOptionalFrequencyRandomness:(AKParameter *)frequencyRandomness {
    _frequencyRandomness = frequencyRandomness;
}
- (void)setOptionalMinimumFrequencyRandomness:(AKParameter *)minimumFrequencyRandomness {
    _minimumFrequencyRandomness = minimumFrequencyRandomness;
}
- (void)setOptionalMaximumFrequencyRandomness:(AKParameter *)maximumFrequencyRandomness {
    _maximumFrequencyRandomness = maximumFrequencyRandomness;
}
- (void)setOptionalAverageAmplitude:(AKParameter *)averageAmplitude {
    _averageAmplitude = averageAmplitude;
}
- (void)setOptionalAmplitudeDeviation:(AKParameter *)amplitudeDeviation {
    _amplitudeDeviation = amplitudeDeviation;
}
- (void)setOptionalMinimumAmplitudeRandomness:(AKParameter *)minimumAmplitudeRandomness {
    _minimumAmplitudeRandomness = minimumAmplitudeRandomness;
}
- (void)setOptionalMaximumAmplitudeRandomness:(AKParameter *)maximumAmplitudeRandomness {
    _maximumAmplitudeRandomness = maximumAmplitudeRandomness;
}
- (void)setOptionalPhase:(AKConstant *)phase {
    _phase = phase;
}

- (NSString *)stringForCSD {
    return [NSString stringWithFormat:
            @"%@ vibrato AKControl(%@), AKControl(%@), AKControl(%@), AKControl(%@), AKControl(%@), AKControl(%@), AKControl(%@), AKControl(%@), %@, %@",
            self,
            _averageAmplitude,
            _averageFrequency,
            _amplitudeDeviation,
            _frequencyRandomness,
            _minimumAmplitudeRandomness,
            _maximumAmplitudeRandomness,
            _minimumFrequencyRandomness,
            _maximumFrequencyRandomness,
            _vibratoShapeTable,
            _phase];
}

@end
