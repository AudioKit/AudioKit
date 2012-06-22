//
//  CSDGrain.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDInstrument.h"
#import "CSDParam.h"

@interface CSDGrain : CSDOpcode
{
    CSDParam * amplitude;
    CSDParam * pitch;
    CSDParam * grainDensity;
    CSDParamControl * amplitudeOffset;
    CSDParamControl * pitchOffset;
    CSDParamControl * grainDuration;
    CSDParamConstant * maxGrainDuration;
    CSDFunctionTable * grainFunction;
    CSDFunctionTable * windowFunction;
    BOOL isRandomGrainFunctionIndex;
    CSDParam * output;
}
@property (nonatomic, retain) CSDParam * output;

-(id)initWithAmplitude:(CSDParam *)amp
                 pitch:(CSDParam *)pch
          grainDensity:(CSDParam *)dens
       amplitudeOffset:(CSDParamControl *)ampOffset
           pitchOffset:(CSDParamControl *)pchOffset
         grainDuration:(CSDParamControl *)gdur
      maxGrainDuration:(CSDParamConstant *)maxgdur
         grainFunction:(CSDFunctionTable *)gFunction
        windowFunction:(CSDFunctionTable *)wFunction;

-(id)initWithAmplitude:(CSDParam *)amp
                 pitch:(CSDParam *)pch
          grainDensity:(CSDParam *)dens
       amplitudeOffset:(CSDParamControl *)ampOffset
           pitchOffset:(CSDParamControl *)pchOffset
         grainDuration:(CSDParamControl *)gdur
      maxGrainDuration:(CSDParamConstant *)maxgdur
         grainFunction:(CSDFunctionTable *)gFunction
        windowFunction:(CSDFunctionTable *)wFunction
isRandomGrainFunctionIndex:(BOOL)isRandGrainIndex;

@end
