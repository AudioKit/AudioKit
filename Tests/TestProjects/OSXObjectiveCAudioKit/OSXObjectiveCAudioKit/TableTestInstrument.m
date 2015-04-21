//
//  TableTestInstrument.m
//  iOSObjectiveCAudioKit
//
//  Created by Aurelius Prochazka on 4/18/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "TableTestInstrument.h"

@implementation TableTestInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        _tableValue = [self createPropertyWithValue:0 minimum:-10000.0 maximum:10000.0];
        // Tables
        _sine            = [AKTable standardSineWave];
        _square          = [AKTable standardSquareWave];
        _triangle        = [AKTable standardTriangleWave];
        _sawtooth        = [AKTable standardSawtoothWave];
        _reverseSawtooth = [AKTable standardReverseSawtoothWave];
        _array           = [[AKTable alloc] initWithArray:@[@123, @456]];
        
        AKTableValue *tableValue = [[AKTableValue alloc] initWithTable:_sine atFractionOfTotalWidth:akp(0.25)];
        AKAssignment *assignment = [[AKAssignment alloc] initWithOutput:_tableValue input:tableValue];
        [self connect:assignment];
        
        _hamming  = [AKTable table];
        _hann     = [AKTable table];
        _gaussian = [AKTable table];
        _kaiser   = [AKTable table];
        _cosine   = [AKTable table];
        _random   = [AKTable table];
        
        [_hamming  populateTableWithGenerator:[AKWindowTableGenerator hammingWindow]];
        [_hann     populateTableWithGenerator:[AKWindowTableGenerator hannWindow]];
        [_gaussian populateTableWithGenerator:[AKWindowTableGenerator gaussianWindow]];
        [_kaiser   populateTableWithGenerator:[AKWindowTableGenerator kaiserWindow]];
        
        [_cosine populateTableWithGenerator:[[AKHarmonicCosineTableGenerator alloc] initWithNumberOfHarmonics:10
                                                                                               lowestHarmonic:1
                                                                                            partialMultiplier:0.7]];
        
        [_random populateTableWithGenerator:[AKRandomDistributionTableGenerator gaussianDistribution]];
        
        AKExponentialTableGenerator *generator;
        generator = [[AKExponentialTableGenerator alloc] initWithValue:0.1];
        [generator addValue:1 atIndex:1];
        [generator appendValue:0.1 afterNumberOfElements:1];
        [generator appendValue:1   afterNumberOfElements:1];
        [generator addValue:0.1 atIndex:4];
        
        _exponential = [[AKTable alloc] initWithSize:16384];
        [_exponential populateTableWithGenerator:generator];
        
        
        
    }
    return self;
}
@end
