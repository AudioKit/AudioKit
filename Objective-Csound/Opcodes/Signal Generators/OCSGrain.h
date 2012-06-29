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

/// The output is an audio signal.
@property (nonatomic, retain) OCSParam *output;

/// Instantiates the grain synthesis with the given parameters.
/// @param amplitude              Amplitude of each grain.
/// @param grainPitch             To use the original frequency of the input sound, divide the original sample rate of the grain waveform by the length of the grain function table.
/// @param grainDensity           Density of grains measured in grains per second. If this is constant then the output is synchronous granular synthesis. If grainDensity has a random element (like added noise), then the result is more like asynchronous granular synthesis.
/// @param maxAmplitudeDeviation  Maximum amplitude deviation from `amplitude`. If it is set to zero then there is no random amplitude for each grain.
/// @param maxPitchDeviation      Maximum pitch deviation from grainPitch in Hz.
/// @param grainDuration          Grain duration in seconds. 
/// @param maxGrainDuration       Maximum grain duration in seconds.
/// @param grainFunction          The grain waveform. This can be just a sine wave or a sampled sound.
/// @param windowFunction         The amplitude envelope used for the grains.
- (id)initWithGrainFunction:(OCSFunctionTable *)grainFunction
             WindowFunction:(OCSFunctionTable *)windowFunction
           MaxGrainDuration:(OCSParamConstant *)maxGrainDuration
                  Amplitude:(OCSParam *)amplitude
             GrainFrequency:(OCSParam *)grainFrequency
               GrainDensity:(OCSParam *)grainDensity  
              GrainDuration:(OCSParamControl *)grainDuration
      MaxAmplitudeDeviation:(OCSParamControl *)maxAmplitudeDeviation
          MaxPitchDeviation:(OCSParamControl *)maxPitchDeviation;

- (void) turnOffGrainOffsetRandomnes;

@end
