//
//  GrainBirdsReverb.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/25/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"
#import "GrainBirds.h"

@interface GrainBirdsReverb : OCSInstrument


- (id)initWithGrainBirds:(GrainBirds *) grainBirds;
- (void)start;

@end
