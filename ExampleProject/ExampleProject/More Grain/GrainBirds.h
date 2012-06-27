//
//  GrainBirds.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"
#import "OCSWindowsTable.h"
#import "OCSSoundFileTable.h"
#import "OCSReverbSixParallelComb.h"
#import "OCSPitchClassToFreq.h"
#import "OCSSegmentArray.h"
#import "OCSFilterLowPassButterworth.h"
#import "OCSGrain.h"

@interface GrainBirds : OCSInstrument
{
    OCSProperty *grainDensity;
    OCSProperty *grainDuration;
    OCSProperty *pitchClass;
    OCSProperty *pitchOffsetStartValue;
    OCSProperty *pitchOffsetFirstTarget;
    OCSProperty *reverbSend;
    
    OCSParam *auxilliaryOutput;
}
@property (nonatomic, retain) OCSProperty *grainDensity;
@property (nonatomic, retain) OCSProperty *grainDuration;
@property (nonatomic, retain) OCSProperty *pitchClass;
@property (nonatomic, retain) OCSProperty *pitchOffsetStartValue;
@property (nonatomic, retain) OCSProperty *pitchOffsetFirstTarget;
@property (nonatomic, retain) OCSProperty *reverbSend;

@property (readonly) OCSParam *auxilliaryOutput;

@end
