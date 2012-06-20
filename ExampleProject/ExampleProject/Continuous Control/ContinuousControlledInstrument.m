//
//  ContinuousControlledInstrument.m
//  ExampleProject
//
//  Created by Adam Boulanger on 6/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ContinuousControlledInstrument.h"
#import "CSDAssignment.h"

typedef enum { kDurationArg, kFrequencyArg } ExpressionToneGeneratorArguments;

@implementation ContinuousControlledInstrument
//@synthesize myContinuousManager;
@synthesize amplitude;
@synthesize modulation;
@synthesize modIndex;

-(id)initWithOrchestra:(CSDOrchestra *)newOrchestra
{
    self = [super initWithOrchestra:newOrchestra];
    if (self) {
        CSDSineTable *sineTable = [[CSDSineTable alloc] init];
        [self addFunctionTable:sineTable];
        
        //myContinuousManager = [[CSDContinuousManager alloc] init];
        amplitude = [[CSDContinuous alloc] initWithValue:0.1f Min:0.0f Max:1.0f isControlRate:YES];
        [self addContinuous:amplitude];
        //[myContinuousManager addContinuousParam:amplitude forControllerNumber:12];
        
        modulation = [[CSDContinuous alloc] initWithValue:0.5f Min:0.25f Max:2.2f isControlRate:YES];
        [self addContinuous:modulation];
        //[myContinuousManager addContinuousParam:modulationContinuous forControllerNumber:13];
        
        modIndex = [[CSDContinuous alloc] initWithValue:1.0f Min:0.0f Max:25.0f isControlRate:YES];
        [self addContinuous:modIndex];
        //[myContinuousManager addContinuousParam:modIndexContinuous forControllerNumber:14];
        
        /*
         CSDFoscili *myFoscili = [[CSDFoscili alloc] 
         initFMOscillatorWithAmplitude: [CSDParamConstant paramWithFloat:0.2]
         Pitch:[CSDParamConstant paramWithInt:440]
         Carrier:[CSDParamConstant paramWithInt:1] 
         Modulation:[CSDParamConstant paramWithFloat:0.5]
         ModIndex:[CSDParamConstant paramWithFloat:15.0]
         FunctionTable:sineTable 
         AndOptionalPhase:nil];
         [self addOpcode:myFoscili];
         */
        
        CSDFoscili *myFoscili = 
        [[CSDFoscili alloc] initFMOscillatorWithAmplitude:[CSDParam paramWithContinuous:amplitude]
                                                Frequency:[CSDParamConstant paramWithPValue:kFrequencyArg] 
                                                  Carrier:[CSDParamConstant paramWithInt:1] 
                                               Modulation:[CSDParamControl paramWithContinuous:modulation]
                                                 ModIndex:[CSDParamControl paramWithContinuous:modIndex]
                                            FunctionTable:sineTable 
                                         AndOptionalPhase:nil];
        [self addOpcode:myFoscili];
        
        CSDOutputStereo *monoOutput = [[CSDOutputStereo alloc] initWithInputLeft:[myFoscili output] InputRight:[myFoscili output]];
        [self addOpcode:monoOutput];
    }
    return self;
}
//
//-(void) playNoteForDuration:(float)dur Pitch:(float)pitch
//{
//    int instrumentNumber = [[orchestra instruments] indexOfObject:self] + 1;
//    
//    NSString * note = [NSString stringWithFormat:@"%0.2f %0.2f", dur, pitch];
//    [[CSDManager sharedCSDManager] playNote:note OnInstrument:instrumentNumber];
//}
-(void) playNoteForDuration:(float)dur Frequency:(float)freq {
    [self playNote:[NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithFloat:dur],  [NSNumber numberWithInt:kDurationArg],
                    [NSNumber numberWithFloat:freq], [NSNumber numberWithInt:kFrequencyArg],nil]];
}


@end
