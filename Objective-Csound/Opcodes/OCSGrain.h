//
//  OCSGrain.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSInstrument.h"
#import "OCSParam.h"

@interface OCSGrain : OCSOpcode
{
    OCSParam * amplitude;
    OCSParam * pitch;
    OCSParam * grainDensity;
    OCSParamControl * amplitudeOffset;
    OCSParamControl * pitchOffset;
    OCSParamControl * grainDuration;
    OCSParamConstant * maxGrainDuration;
    OCSFunctionTable * grainFunction;
    OCSFunctionTable * windowFunction;
    BOOL isRandomGrainFunctionIndex;
    OCSParam * output;
}
@property (nonatomic, retain) OCSParam * output;

-(id)initWithAmplitude:(OCSParam *)amp
                 pitch:(OCSParam *)pch
          grainDensity:(OCSParam *)dens
       amplitudeOffset:(OCSParamControl *)ampOffset
           pitchOffset:(OCSParamControl *)pchOffset
         grainDuration:(OCSParamControl *)gdur
      maxGrainDuration:(OCSParamConstant *)maxgdur
         grainFunction:(OCSFunctionTable *)gFunction
        windowFunction:(OCSFunctionTable *)wFunction;

-(id)initWithAmplitude:(OCSParam *)amp
                 pitch:(OCSParam *)pch
          grainDensity:(OCSParam *)dens
       amplitudeOffset:(OCSParamControl *)ampOffset
           pitchOffset:(OCSParamControl *)pchOffset
         grainDuration:(OCSParamControl *)gdur
      maxGrainDuration:(OCSParamConstant *)maxgdur
         grainFunction:(OCSFunctionTable *)gFunction
        windowFunction:(OCSFunctionTable *)wFunction
isRandomGrainFunctionIndex:(BOOL)isRandGrainIndex;

@end
