//
//  CSDFileLength.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOpcode.h"

@interface CSDFileLength : CSDOpcode
{
    CSDFunctionTable * input;
    CSDParam * output;
}

@property (nonatomic, strong) CSDParam * output;

-(id) initWithInput:(CSDFunctionTable *)in;

@end
