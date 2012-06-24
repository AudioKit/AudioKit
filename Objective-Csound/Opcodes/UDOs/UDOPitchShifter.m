//
//  UDOPitchShifter.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/23/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "UDOPitchShifter.h"

@implementation UDOPitchShifter

@synthesize outputLeft;
@synthesize outputRight;

- (NSString *)csdDefinition 
{
    return @""
    "opcode PitchShifter, aa, aakkk"
    
    "aL, aR, kpitch, kfine, kfeedback xin"
    "setksmps    64"
    "ifftsize    =           1024"
    "ihopsize    =           256"
    "kscal       =           octave((int(kpitch)/12)+kfine)"
    
    "aOutL       init        0"		
    "aOutR       init        0"
    
    "fsig1L      pvsanal     aL + (aOutL * kfeedback), ifftsize, ihopsize, ifftsize, 0"
    "fsig1R      pvsanal     aR + (aOutR * kfeedback), ifftsize, ihopsize, ifftsize, 0"
    "fsig2L      pvscale     fsig1L, kscal"
    "fsig2R      pvscale     fsig1R, kscal"
    "aOutL       pvsynth     fsig2L"
    "aOutR       pvsynth     fsig2R"
    
    "xout        aOutL, aOutR";
}

- (id)initWithInputLeft:(OCSParam *)inL
             InputRight:(OCSParam *)inR
                  Pitch:(OCSParamControl *)pch
                   Fine:(OCSParamControl *)fin 
               Feedback:(OCSParamControl *)fbk
{
    self = [super init];
    if (self) {
        outputLeft  = [OCSParam paramWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"L"]];
        outputRight = [OCSParam paramWithString:[NSString stringWithFormat:@"%@%@",[self opcodeName], @"R"]];
        inputLeft   = inL;
        inputRight  = inR;
        pitch       = pch;
        fine        = fin;
        feedback    = fbk;
    }
    return self; 
}

- (NSString *)stringForCSD
{
    return [NSString stringWithFormat:
            @"%@, %@ reverbsc %@, %@, %@, %@, %@\n",
            outputLeft, outputRight, inputLeft, inputRight, pitch, fine, feedback];
}

@end
