//
//  UnitGenSoundGenerator.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDInstrument.h"

#import "CSDOscillator.h"
#import "CSDLine.h"
#import "CSDLIneSegment.h"

@interface UnitGenSoundGenerator : CSDInstrument
{
    CSDOscillator *myOscillator;
    CSDLine *myLine;
    CSDLineSegment *myLineSegmenet;
}

-(id)initWithOrchestra:(CSDOrchestra *)newOrchestra;

@end
