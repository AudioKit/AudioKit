//
//  UnitGenSoundGenerator.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/7/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"
#import "OCSFoscili.h"
#import "OCSLine.h"
#import "OCSLineSegment.h"
#import "OCSOutputStereo.h"

@interface UnitGenSoundGenerator : OCSInstrument
{
    OCSFoscili *myFMOscillator;
    OCSLine *myLine;
    OCSLineSegment *myLineSegment_a;
    OCSLineSegment *myLineSegment_b;
}

-(id)initWithOrchestra:(OCSOrchestra *)orch;

@end
