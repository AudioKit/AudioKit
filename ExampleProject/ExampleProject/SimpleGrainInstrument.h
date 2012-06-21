//
//  SimpleGrainInstrument.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDInstrument.h"
#import "CSDSineTable.h"
#import "CSDProperty.h"
#import "CSDGrain.h"

@interface SimpleGrainInstrument : CSDInstrument
{
}

-(id)initWithOrchestra:(CSDOrchestra *)newOrchestra;
-(void)playNoteWithDuration:(float)duration;

@end
