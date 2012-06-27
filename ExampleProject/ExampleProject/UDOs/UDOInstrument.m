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
        [frequency setConstant:[OCSParamConstant paramWithString:@"Frequency"]]; 
        [self addProperty:frequency];
        
        // INSTRUMENT DEFINITION ===============================================
        
        UDOMSROscillator * osc  = [[UDOMSROscillator alloc] initWithAmplitude:ocsp(0.5)
                                                                    Frequency:[frequency constant]
                                                                         Type:kMSROscillatorTypeTriangle];
        [self addUDO:osc];
        
        UDOCsGrainPitchShifter * ps;
        ps = [[UDOCsGrainPitchShifter alloc] initWithInputLeft:[osc output] 
                                                    InputRight:[osc output] 
                                                         Pitch:ocsp(2.7) 
                                               OffsetFrequency:ocsp(0) 
                                                      Feedback:ocsp(0.9)];
        [self addUDO:ps];
        
        UDOCsGrainCompressor * comp;
        comp = [[UDOCsGrainCompressor alloc] initWithInputLeft:[ps outputLeft] 
                                                    InputRight:[ps outputRight] 
                                                     Threshold:ocsp(-2.0) 
                                              CompressionRatio:ocsp(0.5) 
                                                    AttackTime:ocsp(0.1) 
                                                   ReleaseTime:ocsp(0.2)];
        [self addUDO:comp];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudio *stereoOutput = [[OCSAudio alloc] initWithLeftInput:[ps outputLeft] 
                                                          RightInput:[ps outputRight]]; 
        [self addOpcode:stereoOutput];
    }
    return self;
}

- (void)playNoteForDuration:(float)dur Frequency:(float)freq {
    frequency.value = freq;
    [self playNoteForDuration:dur];
}


@end
