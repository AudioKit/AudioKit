//
//  FMGameObject.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
//  Create a new instrument - define opcodes with properties connected to game behavior
//  connect everything to an orchestra which can be managed at gameLevel (manager)
//     orchestra needs visible method to grab text interpretation of this instrument
//
//

#import "CSDConstants.h"

#import "CSDManager.h"
#import "CSDInstrument.h"
#import "CSDParam.h"
#import "CSDOutputMono.h"
#import "CSDSineTable.h"

#import "CSDFoscili.h"

@interface FMGameObject : CSDInstrument
{
    //ares foscili xamp, kcps, xcar, xmod, kndx, ifn [, iphs]
    //Opcodes
    CSDFoscili * myFoscilOpcode;
}

-(id) initWithOrchestra:(CSDOrchestra *)newOrchestra;
-(void) playNoteForDuration:(float)dur Frequency:(float)freq Modulation:(float)mod;

@end
