//
//  CSDGrain.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDInstrument.h"
#import "CSDParam.h"

@interface CSDGrain : CSDInstrument
{
    CSDParam * output;
}

//ares grain xamp, xpitch, xdens, kampoff, kpitchoff, kgdur, igfn, iwfn, imgdur [, igrnd]
@property (nonatomic, retain) CSDParam * amplitude;
@property (nonatomic, retain) CSDParam * pitch;
@property (nonatomic, retain) CSDParam * grainDensity;
@property (nonatomic, retain) CSDParamControl * amplitudeOffset;
@property (nonatomic, retain) CSDParamControl * pitchOffset;
@property (nonatomic, retain) CSDParamControl * grainDuration;
@property (nonatomic, retain) CSDParamConstant * maxGrainDuration;
@property (nonatomic, retain) CSDFunctionTable * grainFunction;
@property (nonatomic, retain) CSDFunctionTable * windowFunction;
@property (readwrite) BOOL isRandomGrainFunctionIndex;

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
