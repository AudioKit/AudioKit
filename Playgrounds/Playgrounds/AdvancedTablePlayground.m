//
//  AdvancedTablePlayground.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 3/17/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "Playground.h"

@implementation Playground

- (void)run
{
    [super run];

    AKInstrument *instrument = [[AKInstrument alloc] initWithNumber:1];
    AKOscillator *oscillator = [AKOscillator oscillator];
    [instrument setAudioOutput:oscillator];
    [AKOrchestra addInstrument:instrument];

    [self makeSection:@"Standard Triangle"];
    AKTable *table = [AKTable standardTriangleWave];
    [self addTablePlot:table];

    [self makeSection:@"Inverted Triangle"];
    [table scaleBy:-1];
    [self addTablePlot:table];

    [self makeSection:@"Absolute Value"];
    [table absoluteValue];
    [self addTablePlot:table];

    [self makeSection:@"Custom Math"];
    [table operateOnTableWithFunction:^(float y) {
        return sinf(powf(y, 2.0f)) - 0.3f;
    }];
    [self addTablePlot:table];

    [self makeSection:@"Custom Math"];
    [table populateTableWithFractionalWidthFunction:^(float y) {
        return sinf(30.0 * y) * sinf(powf(y, 2.0f));
    }];
    [self addTablePlot:table];

    [self makeSection:@"Generators"];

    [self makeSection:@"Exponential Table"];
    AKExponentialTableGenerator *gen = [[AKExponentialTableGenerator alloc] initWithValue:0.1];
    [gen addValue:1 atIndex:1];
    [gen addValue:0.1 atIndex:2];
    [gen addValue:3 atIndex:3];
    [gen addValue:0.1 atIndex:4];
    [table populateTableWithGenerator:gen];
    [self addTablePlot:table];

    [self makeSection:@"Fourier Table"];
    AKFourierSeriesTableGenerator *fourierSeries = [[AKFourierSeriesTableGenerator alloc] init];
    [fourierSeries addSinusoidWithPartialNumber:2 strength:0.5];
    [fourierSeries addSinusoidWithPartialNumber:7 strength:0.2];
    [table populateTableWithGenerator:fourierSeries];
    [self addTablePlot:table];
    [self makeSection:@"Cauchy Random Distribution"];
    [table populateTableWithGenerator:[[AKRandomDistributionTableGenerator alloc] initCauchyDistribution]];
    [self addTablePlot:table];

    [self makeSection:@"Gaussian Random Distribution"];
    [table populateTableWithGenerator:[[AKRandomDistributionTableGenerator alloc] initGaussianDistribution]];
    [self addTablePlot:table];

    [self makeSection:@"Uniform Random Distribution"];
    [table populateTableWithGenerator:[[AKRandomDistributionTableGenerator alloc] initUniformDistribution]];
    [self addTablePlot:table];

}

@end
