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
    //CSDContinuousManager *myContinuousManager;
    
    //maintain reference to continuous params so they can be referenced from controlling game logic 
    CSDContinuous *amplitudeContinuous;
    CSDContinuous *modulationContinuous;
    CSDContinuous *modIndexContinuous;
}
//@property (nonatomic, strong) CSDContinuousManager * myContinuousManager;
@property (nonatomic, strong) CSDContinuous * amplitudeContinuous;
@property (nonatomic, strong) CSDContinuous * modulationContinuous;
@property (nonatomic, strong) CSDContinuous * modIndexContinuous;

-(id)initWithOrchestra:(CSDOrchestra *)newOrchestra;
-(void) playNoteForDuration:(float)dur Pitch:(float)pitch;

@end
