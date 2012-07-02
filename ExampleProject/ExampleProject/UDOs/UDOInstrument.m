//
//  UDOInstrument.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOInstrument.h"

#import "UDOMSROscillator.h"
#import "UDOCsGrainCompressor.h"
#import "UDOCsGrainPitchShifter.h"

#import "OCSAudio.h"

@implementation UDOInstrument

@synthesize frequency;

- (id)init {
    self = [super init];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
        
        frequency = [[OCSProperty alloc] init];
        [frequency setConstant:[OCSConstantParam paramWithString:@"Frequency"]]; 
        [self addProperty:frequency];
        
        // INSTRUMENT DEFINITION ===============================================
        
        UDOMSROscillator *osc;
        osc = [[UDOMSROscillator alloc] initWithType:kMSROscillatorTypeTriangle
                                           frequency:[frequency constant]
                                           amplitude:ocsp(0.5)];
        [self addUDO:osc];
        
        UDOCsGrainPitchShifter * ps;
        ps = [[UDOCsGrainPitchShifter alloc] initWithLeftInput:[osc output] 
                                                    rightInput:[osc output] 
                                                     basePitch:ocsp(2.7) 
                                               offsetFrequency:ocsp(0) 
                                                 feedbackLevel:ocsp(0.9)];
        [self addUDO:ps];
        
        UDOCsGrainCompressor * comp;
        comp = [[UDOCsGrainCompressor alloc] initWithLeftInput:[ps outputLeft] 
                                                    rightInput:[ps outputRight] 
                                                     threshold:ocsp(-2.0) 
                                              compressionRatio:ocsp(0.5) 
                                                    attackTime:ocsp(0.1) 
                                                   releaseTime:ocsp(0.2)];
        [self addUDO:comp];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudio *stereoOutput = [[OCSAudio alloc] initWithLeftInput:[ps outputLeft] 
                                                          rightInput:[ps outputRight]]; 
        [self addOpcode:stereoOutput];
    }
    return self;
}

- (void)playNoteForDuration:(float)dur Frequency:(float)freq {
    frequency.value = freq;
    [self playNoteForDuration:dur];
}


@end
