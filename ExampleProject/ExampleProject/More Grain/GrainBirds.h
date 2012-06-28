//
//  GrainBirds.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"

@interface GrainBirds : OCSInstrument

@property (nonatomic, retain) OCSProperty *grainDensity;
@property (nonatomic, retain) OCSProperty *grainDuration;
@property (nonatomic, retain) OCSProperty *pitchClass;
@property (nonatomic, retain) OCSProperty *pitchOffsetStartValue;
@property (nonatomic, retain) OCSProperty *pitchOffsetFirstTarget;
@property (nonatomic, retain) OCSProperty *reverbSend;

@property (readonly) OCSParam *auxilliaryOutput;

@end
