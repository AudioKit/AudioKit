//
//  UnitGenSoundGenerator.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UnitGenSoundGenerator.h"

#import "CSDParamArray.h"
#import "CSDSineTable.h"

@implementation UnitGenSoundGenerator

-(id)initWithOrchestra:(CSDOrchestra *)newOrchestra
{
    self = [super initWithOrchestra:newOrchestra];
    if (self) {
        //H4Y - ARB: create sign function with variable partial strengths
        float partialStrengths[] = {1.0f, 0.5f, 1.0f};
        CSDParamArray * partialStrengthParamArray = [CSDParamArray paramFromFloats:partialStrengths count:3];
        
        CSDSineTable * iSine = [[CSDSineTable alloc] initWithOutput:@"iSine" TableSize:4096 PartialStrengths:partialStrengthParamArray];
        [self addFunctionStatement:iSine];
        
        //TODO: writing csound string "aLine is bad"
        myLine = [[CSDLine alloc] initWithOutput:[CSDParam paramWithString:@"aline"] iStartingValue:[CSDParam paramWithInt:110] iDuration:[CSDParam paramWithPValue:3] iTargetValue:[CSDParam paramWithInt:400]];
        
        //H4Y - ARB: create sign function with variable partial strengths
        //WORKING HERE
        myOscillator = [[CSDOscillator alloc] initWithOutput:FINAL_OUTPUT 
                                                   Amplitude:[CSDParam paramWithOpcode:myLine] kPitch:<#(CSDParam *)#> FunctionTable:iSine
        
    }
    return self;
}

@end
