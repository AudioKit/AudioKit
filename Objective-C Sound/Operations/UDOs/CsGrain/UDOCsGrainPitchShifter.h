//
//  UDOPitchShifter.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 6/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Pitch Shifter from Boulanger Labs' csGrain

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/** Pitch shifter from Boulanger Labs' csGrain application.  
 Stereo audio input and output.  
 */
@interface UDOCsGrainPitchShifter : OCSAudio 

/// @name Properties

/// Left channel output.
@property (nonatomic, strong) OCSAudio *leftOutput;

//// Right channel output.
@property (nonatomic, strong) OCSAudio *rightOutput;

/// @name Initialization

/** Instantiates the pitch shifter.
 
 @param leftInput                  Input to the left channel.
 @param rightInput                 Input to the right channel.
 @param basePitch                  The pitch to shift by in pitch notation.
 @param fineTuningOffsetFrequency  Frequency in Hz that will be added to the converted pitch frequency (a negative will detune). 
 @param feedbackLevel              Typically a value from 0.0 (no feedback to 1.0 (100% feedback).
 @return                           An instance of the pitch shifter.
 */
- (id)initWithLeftInput:(OCSAudio *)leftInput
             rightInput:(OCSAudio *)rightInput
              basePitch:(OCSControl *)basePitch
        offsetFrequency:(OCSControl *)fineTuningOffsetFrequency
          feedbackLevel:(OCSControl *)feedbackLevel;

- (NSString *) udoFile;

@end
