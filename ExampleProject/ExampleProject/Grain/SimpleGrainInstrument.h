//
//  SimpleGrainInstrument.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDInstrument.h"
#import "CSDSoundFileTable.h"
#import "CSDWindowsTable.h"
#import "CSDExpSegment.h"
#import "CSDLine.h"
#import "CSDFileLength.h"
#import "CSDProperty.h"
#import "CSDGrain.h"
#import "CSDOutputStereo.h"

@interface SimpleGrainInstrument : CSDInstrument
{
}

-(id)initWithOrchestra:(CSDOrchestra *)newOrchestra;

@end
