//
//  AKGranularSynthesisTexture.m
//  AudioKit
//
//  Auto-generated on 1/3/15.
//  Customized by Aurelius Prochazka on 1/12/15, reversing random offset logic.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's grain:
//  http://www.csounds.com/manual/html/grain.html
//

#import "AKGranularSynthesisTexture.h"
#import "AKManager.h"

@implementation AKGranularSynthesisTexture
{
    AKConstant * _grainFunctionTable;
    AKConstant * _windowFunctionTable;
}

- (instancetype)initWithGrainFunctionTable:(AKConstant *)grainFunctionTable
                       windowFunctionTable:(AKConstant *)windowFunctionTable
                      maximumGrainDuration:(AKConstant *)maximumGrainDuration
                      averageGrainDuration:(AKParameter *)averageGrainDuration
                 maximumFrequencyDeviation:(AKParameter *)maximumFrequencyDeviation
                            grainFrequency:(AKParameter *)grainFrequency
                 maximumAmplitudeDeviation:(AKParameter *)maximumAmplitudeDeviation
                            grainAmplitude:(AKParameter *)grainAmplitude
                              grainDensity:(AKParameter *)grainDensity
                      useRandomGrainOffset:(BOOL)useRandomGrainOffset
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _grainFunctionTable = grainFunctionTable;
        _windowFunctionTable = windowFunctionTable;
        _maximumGrainDuration = maximumGrainDuration;
        _averageGrainDuration = averageGrainDuration;
        _maximumFrequencyDeviation = maximumFrequencyDeviation;
        _grainFrequency = grainFrequency;
        _maximumAmplitudeDeviation = maximumAmplitudeDeviation;
        _grainAmplitude = grainAmplitude;
        _grainDensity = grainDensity;
        _useRandomGrainOffset = useRandomGrainOffset;
    }
    return self;
}

- (instancetype)initWithGrainFunctionTable:(AKConstant *)grainFunctionTable
                       windowFunctionTable:(AKConstant *)windowFunctionTable
{
    self = [super initWithString:[self operationName]];
    if (self) {
        _grainFunctionTable = grainFunctionTable;
        _windowFunctionTable = windowFunctionTable;
        // Default Values
        _maximumGrainDuration = akp(0.5);
        _averageGrainDuration = akp(0.4);
        _maximumFrequencyDeviation = akp(0.5);
        _grainFrequency = akp(0.8);
        _maximumAmplitudeDeviation = akp(0.1);
        _grainAmplitude = akp(0.01);
        _grainDensity = akp(500);
        _useRandomGrainOffset = true;
    }
    return self;
}

+ (instancetype)textureWithGrainFunctionTable:(AKConstant *)grainFunctionTable
                          windowFunctionTable:(AKConstant *)windowFunctionTable
{
    return [[AKGranularSynthesisTexture alloc] initWithGrainFunctionTable:grainFunctionTable
                                                      windowFunctionTable:windowFunctionTable];
}

- (void)setOptionalMaximumGrainDuration:(AKConstant *)maximumGrainDuration {
    _maximumGrainDuration = maximumGrainDuration;
}
- (void)setOptionalAverageGrainDuration:(AKParameter *)averageGrainDuration {
    _averageGrainDuration = averageGrainDuration;
}
- (void)setOptionalMaximumFrequencyDeviation:(AKParameter *)maximumFrequencyDeviation {
    _maximumFrequencyDeviation = maximumFrequencyDeviation;
}
- (void)setOptionalGrainFrequency:(AKParameter *)grainFrequency {
    _grainFrequency = grainFrequency;
}
- (void)setOptionalMaximumAmplitudeDeviation:(AKParameter *)maximumAmplitudeDeviation {
    _maximumAmplitudeDeviation = maximumAmplitudeDeviation;
}
- (void)setOptionalGrainAmplitude:(AKParameter *)grainAmplitude {
    _grainAmplitude = grainAmplitude;
}
- (void)setOptionalGrainDensity:(AKParameter *)grainDensity {
    _grainDensity = grainDensity;
}
- (void)setOptionalUseRandomGrainOffset:(BOOL)useRandomGrainOffset {
    _useRandomGrainOffset = useRandomGrainOffset;
}

- (NSString *)stringForCSD {
    NSMutableString *csdString = [[NSMutableString alloc] init];
    
    [csdString appendFormat:@"%@ grain ", self];
    
    [csdString appendFormat:@"%@, ", _grainAmplitude];
    
    [csdString appendFormat:@"%@, ", _grainFrequency];
    
    [csdString appendFormat:@"%@, ", _grainDensity];
    
    if ([_maximumAmplitudeDeviation class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _maximumAmplitudeDeviation];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _maximumAmplitudeDeviation];
    }
    
    if ([_maximumFrequencyDeviation class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _maximumFrequencyDeviation];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _maximumFrequencyDeviation];
    }
    
    if ([_averageGrainDuration class] == [AKControl class]) {
        [csdString appendFormat:@"%@, ", _averageGrainDuration];
    } else {
        [csdString appendFormat:@"AKControl(%@), ", _averageGrainDuration];
    }
    
    [csdString appendFormat:@"%@, ", _grainFunctionTable];
    
    [csdString appendFormat:@"%@, ", _windowFunctionTable];
    
    [csdString appendFormat:@"%@, ", _maximumGrainDuration];
    
    [csdString appendFormat:@"%@", akpi(!_useRandomGrainOffset)];
    return csdString;
}

@end
