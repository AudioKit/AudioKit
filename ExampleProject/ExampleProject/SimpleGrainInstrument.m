//
//  SimpleGrainInstrument.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "SimpleGrainInstrument.h"

@implementation SimpleGrainInstrument

-(id)initWithOrchestra:(CSDOrchestra *)newOrchestra
{
    self = [super initWithOrchestra:newOrchestra];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
        
        // INSTRUMENT DEFINITION ===============================================
        CSDFunctionTable *sineTable = [[CSDSineTable alloc] initWithTableSize:4096 PartialStrengths:nil];
        [self addFunctionTable:sineTable];
        
        CSDGrain *grain = [[CSDGrain alloc] initWithAmplitude:[CSDParamConstant paramWith pitch:<#(CSDParam *)#> grainDensity:<#(CSDParam *)#> amplitudeOffset:<#(CSDParamControl *)#> pitchOffset:<#(CSDParamControl *)#> grainDuration:<#(CSDParamControl *)#> maxGrainDuration:<#(CSDParamConstant *)#> grainFunction:sineTable windowFunction:<#(CSDFunctionTable *)#> isRandomGrainFunctionIndex:NO]
        // AUDIO OUTPUT ========================================================
    }
}

@end
