//
//  UDOPitchShifter.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Pitch Shifter from Boulanger Labs' csGrain

#import "OCSUserDefinedOpcode.h"

@interface UDOPitchShifter : OCSUserDefinedOpcode {
    OCSParam *outputLeft;
    OCSParam *outputRight;
    OCSParam *inputLeft;
    OCSParam *inputRight;
    OCSParamControl *pitch;
    OCSParamControl *fine;
    OCSParamControl *feedback;
}

@property (nonatomic, strong) OCSParam *outputLeft;
@property (nonatomic, strong) OCSParam *outputRight;

- (id)initWithInputLeft:(OCSParam *)inL
             InputRight:(OCSParam *)inR
                  Pitch:(OCSParamControl *)pch
                   Fine:(OCSParamControl *)fin 
               Feedback:(OCSParamControl *)fbk;

@end
