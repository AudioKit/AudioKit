//
//  OCSPitchClassToFreq.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/// Wrapper for converting pitch class to frequency.  Has to be a better way. AOP
@interface OCSPitchClassToFreq : OCSOpcode

/// The output is either control or constant.
@property (nonatomic, strong) OCSParam *output;

/// Initialization Statement
/// @param pitch Pitch to be converted.
-(id) initWithPitch:(OCSParam *)pitch;


@end
