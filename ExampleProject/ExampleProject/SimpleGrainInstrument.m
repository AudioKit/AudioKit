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
    
        CSDFileLength * fileLength = [[CSDFileLength alloc] initWithInput:fileTable];
        [self addOpcode:fileLength];
        
        CSDParamConstant * baseFreq = 
            [CSDParamConstant paramWithFormat:@"44100 / %@", fileLength];
        
        CSDParamArray * amplitudeSegmentArray = [CSDParamArray paramArrayFromParams:
                                    [CSDParamConstant paramWithFormat:@"%@ / 2", duration],
                                     [CSDParamConstant paramWithFloat:0.01], nil];
        
        CSDExpSegment *amplitudeExp = [[CSDExpSegment alloc] 
                    initWithFirstSegmentStartValue:[CSDParamConstant paramWithFloat:0.001f] 
                    FirstSegmentDuration:[CSDParamConstant paramWithFormat:@"%@ / 2", duration]
                FirstSegementTargetValue:[CSDParamConstant paramWithFloat:0.1f]
                                       SegmentArray:amplitudeSegmentArray];
        [self addOpcode:amplitudeExp];

        CSDLine * pitchLine = [[CSDLine alloc] initWithStartingValue:baseFreq 
                                                            Duration:duration 
                                                         TargetValue:[CSDParamConstant paramWithFormat:@"0.8 * %@", baseFreq]];
        [self addOpcode:pitchLine];
        
        CSDLine * grainDensityLine = [[CSDLine alloc] initWithStartingValue:[CSDParamConstant paramWithInt:600] 
                                                                   Duration:duration 
                                                                TargetValue:[CSDParamConstant paramWithInt:300]];
        [self addOpcode:grainDensityLine];
        
        CSDLine * ampOffsetLine = [[CSDLine alloc] initWithStartingValue:[CSDParamConstant paramWithInt:0] 
                                                                Duration:duration 
                                                             TargetValue:[CSDParamConstant paramWithFloat:0.1]];
        [self addOpcode:ampOffsetLine];
        
        CSDLine * pitchOffsetLine = [[CSDLine alloc] initWithStartingValue:[CSDParamConstant paramWithInt:0] Duration:duration TargetValue:[CSDParamConstant paramWithFormat:@"0.5 * %@", baseFreq]];
        [self addOpcode:pitchOffsetLine];   
        
        CSDLine * grainDurationLine = [[CSDLine alloc] initWithStartingValue:[CSDParamConstant paramWithFloat:0.1] Duration:duration TargetValue:[CSDParamConstant paramWithFloat:0.1]];
        [self addOpcode:grainDurationLine];
        
        CSDGrain * grainL = [[CSDGrain alloc] initWithAmplitude:[amplitudeExp output] 
                                                        pitch:[pitchLine output]
                                                  grainDensity:[grainDensityLine output]
                                               amplitudeOffset:[ampOffsetLine output]
                                                   pitchOffset:[pitchOffsetLine output] 
                                                 grainDuration:[grainDurationLine output]  maxGrainDuration:[CSDParamConstant paramWithFloat:0.5] 
                                                 grainFunction:fileTable 
                                                windowFunction:hamming 
                                    isRandomGrainFunctionIndex:NO];
        [self addOpcode:grainL];
        
        CSDGrain * grainR = [[CSDGrain alloc] initWithAmplitude:[amplitudeExp output] 
                                                         pitch:[pitchLine output]
                                                  grainDensity:[grainDensityLine output]
                                               amplitudeOffset:[ampOffsetLine output]
                                                   pitchOffset:[pitchOffsetLine output] 
                                                 grainDuration:[grainDurationLine output]  maxGrainDuration:[CSDParamConstant paramWithFloat:0.5] 
                                                 grainFunction:fileTable 
                                                windowFunction:hamming 
                                    isRandomGrainFunctionIndex:NO];
         [self addOpcode:grainR];
        // AUDIO OUTPUT ========================================================
        CSDOutputStereo *stereoOutput = [[CSDOutputStereo alloc] 
                initWithInputLeft:[grainL output] 
                       InputRight:[grainR output]]; 
        [self addOpcode:stereoOutput];
    }
    return self;
}

-(void)playNoteForDuration:(float)dur
{
    [self playNoteWithDuration:dur];
}


@end
