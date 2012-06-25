//
//  UDOPitchShifter.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Pitch Shifter from Boulanger Labs' csGrain

#import "OCSUserDefinedOpcode.h"

/** Pitch shifter from Boulanger Labs' csGrain application.  
 Stereo audio input and output.  
 */
@interface UDOCsGrainPitchShifter : OCSUserDefinedOpcode 

/// Left channel output.
@property (nonatomic, strong) OCSParam *outputLeft;

//// Right channel output.
@property (nonatomic, strong) OCSParam *outputRight;

/** Instantiates the pitch shifter.
 
 @param leftInput                  Input to the left channel.
 @param rightInput                 Input to the right channel.
 @param basePitch                  The pitch to shift by in pitch notation.
 @param fineTuningOffsetFrequency  Frequency in Hz that will be added to the converted pitch frequency (a negative will detune). 
 @param feedbackLevel              Typically a value from 0.0 (no feedback to 1.0 (100% feedback).
 @return                           An instance of the pitch shifter.
 */
- (id)initWithInputLeft:(OCSParam *)leftInput
             InputRight:(OCSParam *)rightInput
                  Pitch:(OCSParamControl *)basePitch
        OffsetFrequency:(OCSParamControl *)fineTuningOffsetFrequency
               Feedback:(OCSParamControl *)feedbackLevel;

@end
