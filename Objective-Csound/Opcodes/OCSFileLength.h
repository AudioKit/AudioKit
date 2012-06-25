//
//  OCSFileLength.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

@interface OCSFileLength : OCSOpcode
{
    OCSFunctionTable *input;
    OCSParam *output;
}

@property (nonatomic, strong) OCSParam *output;

/// Initialization Statement
- (id)initWithInput:(OCSFunctionTable *)in;

@end
