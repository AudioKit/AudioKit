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

#import "OCSAudioOutput.h"

@implementation UDOInstrument

- (UDOInstrumentNote *)createNote {
    return [[UDOInstrumentNote alloc] initWithInstrument:self];
}


- (id)init {
    self = [super init];
    if (self) {
        
        // NOTE BASED CONTROL ==================================================
        UDOInstrumentNote *note = [self createNote];
        [self addNoteProperty:note.frequency];
        
        // INSTRUMENT DEFINITION ===============================================
        
        UDOMSROscillator *msrOsc;
        msrOsc = [[UDOMSROscillator alloc] initWithType:kMSROscillatorTypeTriangle
                                              frequency:note.frequency
                                              amplitude:ocsp(0.5)];
        [self addUDO:msrOsc];
        
        UDOCsGrainPitchShifter * ps;
        ps = [[UDOCsGrainPitchShifter alloc] initWithLeftInput:msrOsc
                                                    rightInput:msrOsc
                                                     basePitch:ocsp(2.7) 
                                               offsetFrequency:ocsp(0) 
                                                 feedbackLevel:ocsp(0.9)];
        [self addUDO:ps];
        
        UDOCsGrainCompressor * comp;
        comp = [[UDOCsGrainCompressor alloc] initWithLeftInput:ps.leftOutput
                                                    rightInput:ps.rightOutput
                                                     threshold:ocsp(-2.0) 
                                              compressionRatio:ocsp(0.5) 
                                                    attackTime:ocsp(0.1) 
                                                   releaseTime:ocsp(0.2)];
        [self addUDO:comp];
        
        // AUDIO OUTPUT ========================================================
        
        OCSAudioOutput *stereoOutput = [[OCSAudioOutput alloc] initWithLeftInput:comp.leftOutput
                                                                      rightInput:comp.rightOutput];
        [self connect:stereoOutput];
    }
    return self;
}

@end

@implementation UDOInstrumentNote

@synthesize frequency;

- (id)initWithInstrument:(OCSInstrument *)anInstrument {
    self = [super initWithInstrument:anInstrument];
    if (self) {
        frequency = [[OCSNoteProperty alloc] initWithValue:kFrequencyInit
                                                  minValue:kFrequencyMin
                                                  maxValue:kFrequencyMax];
        [self addProperty:frequency];
    }
    return self;
}

@end
