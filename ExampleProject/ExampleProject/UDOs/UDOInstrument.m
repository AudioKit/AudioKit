//
//  UDOInstrument.m
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 6/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOInstrument.h"

#import "UDOMSROscillator.h"
#import "UDOCsGrainCompressor.h"
#import "UDOCsGrainPitchShifter.h"

#import "OCSAudio.h"

@interface UDOInstrument () {
    OCSInstrumentProperty *frequency;
}
@end

@implementation UDOInstrument

@synthesize frequency;

- (id)init {
    self = [super init];
    if (self) {
        
        // INPUTS AND CONTROLS =================================================
        
        frequency = [[OCSInstrumentProperty alloc] initWithValue:220 minValue:kFrequencyMin  maxValue:kFrequencyMax];
        [frequency setConstant:[OCSConstant parameterWithString:@"Frequency"]]; 
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
        comp = [[UDOCsGrainCompressor alloc] initWithLeftInput:[ps leftOutput] 
                                                    rightInput:[ps rightOutput] 
                                                     threshold:ocsp(-2.0) 
                                              compressionRatio:ocsp(0.5) 
                                                    attackTime:ocsp(0.1) 
                                                   releaseTime:ocsp(0.2)];
        [self addUDO:comp];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudio *stereoOutput = [[OCSAudio alloc] initWithLeftInput:[ps leftOutput] 
                                                          rightInput:[ps rightOutput]]; 
        [self addOpcode:stereoOutput];
    }
    return self;
}

@end
