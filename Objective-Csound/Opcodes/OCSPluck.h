//
//  OCSPluck.h
//
//  Created by Adam Boulanger on 6/1/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

//ARB - NOTE: started using weight in signatures for things that tend to be 0-1 and scaler/factor for >1
//ARB - NOTE: trying to deal with(hide) strange paramter that switches between different decay initializations which then 
//   recycles optional parameters for different init functions
//ARB - TODO: ival parameters don't need to be strings

@interface OCSPluck : OCSOpcode {
    OCSParamControl *amplitude;
    OCSParamControl *resamplingFrequency;
    OCSParamConstant *pitchDecayFrequency;
    OCSFunctionTable *cyclicDecayFunction;
    OCSParamConstant *decayMethod;
    OCSParamConstant *roughness;
    OCSParamConstant *stretchFactor;
    OCSParamConstant *currentSampleWeight;
    OCSParamConstant *previousSampleWeight;
    
    OCSParam *output;
}
@property (nonatomic, strong) OCSParam *output;

- (id)initWithAmplitude:(OCSParamControl *)amp
   ResamplingFrequency:(OCSParamControl *)freq
   PitchDecayFrequency:(OCSParamConstant *)pchDecayFreq
CyclicDecayFunctionTable:(OCSFunctionTable *)f
        RecursiveDecay:(BOOL)orSimpleDecay;

- (id)initWithAmplitude:(OCSParamControl *)amp
   ResamplingFrequency:(OCSParamControl *)freq
   PitchDecayFrequency:(OCSParamConstant *)pchDecayFreq
CyclicDecayFunctionTable:(OCSFunctionTable *)f  
StretchedAveragingDecay:(OCSParamConstant *)stretchScaler;

- (id)initWithAmplitude:(OCSParamControl *)amp
   ResamplingFrequency:(OCSParamControl *)freq
   PitchDecayFrequency:(OCSParamConstant *)pchDecayFreq
CyclicDecayFunctionTable:(OCSFunctionTable *)f
       SimpleDrumDecay:(OCSParamConstant *)roughWeight;

- (id)initWithAmplitude:(OCSParamControl *)amp
   ResamplingFrequency:(OCSParamControl *)freq
   PitchDecayFrequency:(OCSParamConstant *)pchDecayFreq
CyclicDecayFunctionTable:(OCSFunctionTable *)f
    StretchedDrumDecay:(OCSParamConstant *)roughWeight
         StretchFactor:(OCSParamConstant *)stretchScaler;

- (id)initWithAmplitude:(OCSParamControl *)amp
   ResamplingFrequency:(OCSParamControl *)freq
   PitchDecayFrequency:(OCSParamConstant *)pchDecayFreq
CyclicDecayFunctionTable:(OCSFunctionTable *)f
  WeightedAverageDecay:(OCSParamConstant *)currSampleWeight
         StretchFactor:(OCSParamConstant *)prevSampleWeight;

@end
