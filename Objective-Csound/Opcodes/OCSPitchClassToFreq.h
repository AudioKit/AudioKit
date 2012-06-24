//
//  OCSPitchClassToFreq.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

@interface OCSPitchClassToFreq : OCSOpcode
{
    OCSParam *output;
    OCSParam *input;
}

@property (nonatomic, strong) OCSParam *output;

-(id) initWithInput:(OCSParam *)i;


@end
