//
//  EffectsProcessor.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "EffectsProcessor.h"

@implementation EffectsProcessor
@synthesize input;

-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra
{
    self = [super initWithOrchestra:newOrchestra];
    if (self) {                                                   
        input = [CSDParam paramWithString:@"ReverbInput"];
    }
    return self;
}


@end
