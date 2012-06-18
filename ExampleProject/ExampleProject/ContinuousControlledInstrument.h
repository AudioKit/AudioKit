//
//  ContinuousControlledInstrument.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/18/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDManager.h"
#import "CSDInstrument.h"

#import "CSDSineTable.h"
#import "CSDFoscili.h"

#import "CSDOutputMono.h"

@interface ContinuousControlledInstrument : CSDInstrument
{
    CSDContinuousManager *myContinuousManager;
}
@property (nonatomic, strong) CSDContinuousManager * myContinuousManager;

-(id)initWithOrchestra:(CSDOrchestra *)newOrchestra;
-(void) playNoteForDuration:(float)dur Pitch:(float)pitch;

@end
