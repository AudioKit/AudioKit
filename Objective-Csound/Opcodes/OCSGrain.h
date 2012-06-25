//
//  OCSGrain.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/21/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/**  Generates granular synthesis textures.
*/

@interface OCSGrain : OCSOpcode
@property (nonatomic, retain) OCSParam *output;

/// Initialization Statement
- (id)initWithAmplitude:(OCSParam *)amp
                  Pitch:(OCSParam *)pch
           GrainDensity:(OCSParam *)dens
        AmplitudeOffset:(OCSParamControl *)ampOffset
            PitchOffset:(OCSParamControl *)pchOffset
          GrainDuration:(OCSParamControl *)gdur
       MaxGrainDuration:(OCSParamConstant *)maxgdur
          GrainFunction:(OCSFunctionTable *)gFunction
         WindowFunction:(OCSFunctionTable *)wFunction;

/// Initialization Statement
- (id)initWithAmplitude:(OCSParam *)amp
                 Pitch:(OCSParam *)pch
          GrainDensity:(OCSParam *)dens
       AmplitudeOffset:(OCSParamControl *)ampOffset
           PitchOffset:(OCSParamControl *)pchOffset
         GrainDuration:(OCSParamControl *)gdur
      MaxGrainDuration:(OCSParamConstant *)maxgdur
         GrainFunction:(OCSFunctionTable *)gFunction
        WindowFunction:(OCSFunctionTable *)wFunction
IsRandomGrainFunctionIndex:(BOOL)isRandGrainIndex;

@end
