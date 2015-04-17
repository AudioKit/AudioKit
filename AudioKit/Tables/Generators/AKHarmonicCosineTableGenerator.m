//
//  AKHarmonicCosineTableGenerator.m
//  AudioKit
//
//  Auto-generated on 12/14/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's GEN11:
//  http://www.csounds.com/manual/html/GEN11.html
//

#import "AKHarmonicCosineTableGenerator.h"

@implementation AKHarmonicCosineTableGenerator

- (int)generationRoutineNumber {
    return -11;
}

- (instancetype)initWithNumberOfHarmonics:(int)numberOfHarmonics
                           lowestHarmonic:(int)lowestHarmonic
                        partialMultiplier:(float)partialMultiplier
{
    self = [super init];
    if (self) {
        self.numberOfHarmonics = numberOfHarmonics;
        self.lowestHarmonic = lowestHarmonic;
        self.partialMultiplier = partialMultiplier;
        
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Default Values
        self.numberOfHarmonics = 1;
        self.lowestHarmonic = 1;
        self.partialMultiplier = 1;
    }
    return self;
}

- (void)setOptionalNumberOfHarmonics:(int)numberOfHarmonics {
    self.numberOfHarmonics = numberOfHarmonics;
}

- (void)setOptionalLowestHarmonic:(int)lowestHarmonic {
    self.lowestHarmonic = lowestHarmonic;
}

- (void)setOptionalPartialMultiplier:(float)partialMultiplier {
    self.partialMultiplier = partialMultiplier;
}

- (NSArray *)parametersWithSize:(NSUInteger)size
{
    return @[[NSNumber numberWithInt:_numberOfHarmonics],
             [NSNumber numberWithInt:_lowestHarmonic],
             [NSNumber numberWithFloat:_partialMultiplier]];
}

@end

