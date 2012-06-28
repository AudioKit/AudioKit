//
//  ConvolutionInstrument.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/27/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ConvolutionInstrument.h"
#import "OCSSoundFileTable.h"
#import "OCSLoopingOscillator.h"
#import "OCSConvolution.h"
#import "OCSAudio.h"

@implementation ConvolutionInstrument

- (id)init 
{
    self = [super init];
    if (self) { 
        // INSTRUMENT DEFINITION ===============================================
        
        NSString *file;
        file = [[NSBundle mainBundle] pathForResource:@"808loop" ofType:@"wav"];
        OCSSoundFileTable * fileTable;
        fileTable = [[OCSSoundFileTable alloc] initWithFilename:file];
        [self addFunctionTable:fileTable];
        
        OCSLoopingOscillator *loop;
        loop = [[OCSLoopingOscillator alloc] initWithSoundFileTable:fileTable];
        [self addOpcode:loop];
        
        NSString *dishL;
        dishL = [[NSBundle mainBundle] pathForResource:@"dishL" ofType:@"wav"];
        /*
        NSString *dishR = [[NSBundle mainBundle] pathForResource:@"dishR" ofType:@"wav"];
        NSString *wellL = [[NSBundle mainBundle] pathForResource:@"StairwellL" ofType:@"wav"];
        NSString *wellR = [[NSBundle mainBundle] pathForResource:@"StairwellR" ofType:@"wav"];
         */
        
        OCSConvolution *conv;
        conv  = [[OCSConvolution alloc] initWithInputAudio:[loop output1] 
                                       impulseResponseFile:dishL];
        [self addOpcode:conv];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudio *audio = [[OCSAudio alloc] initWithMonoInput:[conv output]];
        [self addOpcode:audio];
    }
    return self;
}


@end
