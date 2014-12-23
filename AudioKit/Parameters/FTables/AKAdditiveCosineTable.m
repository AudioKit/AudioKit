//
//  AKAdditiveCosineTable.m
//  AudioKit
//
//  Auto-generated on 12/14/14.
//  Copyright (c) 2014 Aurelius Prochazka. All rights reserved.
//
//  Implementation of Csound's GEN11:
//  http://www.csounds.com/manual/html/GEN11.html
//

#import "AKAdditiveCosineTable.h"

@implementation AKAdditiveCosineTable


- (instancetype)initWithSize:(int)size
           numberOfHarmonics:(int)numberOfHarmonics
              lowestHarmonic:(int)lowestHarmonic
           partialMultiplier:(float)partialMultiplier
{
    self = [super initWithType:11 parameters:[[AKArray alloc] init]];
    if (self) {
        self.size = size;
        self.numberOfHarmonics = numberOfHarmonics;
        self.lowestHarmonic = lowestHarmonic;
        self.partialMultiplier = partialMultiplier;
    
    }
    [self setParametersFromProperties];
    return self;
}

- (instancetype)init
{
    self = [super initWithType:11 parameters:[[AKArray alloc] init]];
    if (self) {
        // Default Values   
        self.size = 16384;
        self.numberOfHarmonics = 1;
        self.lowestHarmonic = 1;
        self.partialMultiplier = 1;
    }
    [self setParametersFromProperties];
    return self;
}



- (void)setOptionalSize:(int)size {
    self.size = size;

}

- (void)setOptionalNumberOfHarmonics:(int)numberOfHarmonics {
    self.numberOfHarmonics = numberOfHarmonics;
    [self setParametersFromProperties];
}

- (void)setOptionalLowestHarmonic:(int)lowestHarmonic {
    self.lowestHarmonic = lowestHarmonic;
    [self setParametersFromProperties];
}

- (void)setOptionalPartialMultiplier:(float)partialMultiplier {
    self.partialMultiplier = partialMultiplier;
    [self setParametersFromProperties];
}

- (void)setParametersFromProperties
{
    self.parameters = [[AKArray alloc] init];
    [self.parameters addConstant:akp(self.size)];
    [self.parameters addConstant:akp(self.numberOfHarmonics)];
    [self.parameters addConstant:akp(self.lowestHarmonic)];
    [self.parameters addConstant:akp(self.partialMultiplier)];
}

@end

