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
        NSString * file = [[NSBundle mainBundle] pathForResource:@"beats" ofType:@"wav"];
        CSDSoundFileTable *fileTable = [[CSDSoundFileTable alloc] initWithFilename:file];
        [self addFunctionTable:fileTable];
        
        
        CSDFunctionTable *hamming = [[CSDWindowsTable alloc] initWithTableSize:512 
                                                                   WindowType:kWindowHanning];
        [self addFunctionTable:hamming];
        
        CSDGrain *grain = [[CSDGrain alloc] initWithAmplitude:[CSDParamConstant  paramWith pitch:<#(CSDParam *)#> grainDensity:<#(CSDParam *)#> amplitudeOffset:<#(CSDParamControl *)#> pitchOffset:<#(CSDParamControl *)#> grainDuration:<#(CSDParamControl *)#> maxGrainDuration:[CSDParamConstant paramWithFloat:0.5] grainFunction:fileTable windowFunction:hamming isRandomGrainFunctionIndex:NO]
        // AUDIO OUTPUT ========================================================
    }
}


@end
