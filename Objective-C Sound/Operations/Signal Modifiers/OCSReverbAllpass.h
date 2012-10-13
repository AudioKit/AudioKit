//
//  OCSReverbAllpass.h
//  Sonification
//
//  Created by Adam Boulanger on 10/12/12.
//  Copyright (c) 2012 Adam Boulanger. All rights reserved.
//

#import "OCSAudio.h"
#import "OCSParameter+Operation.h"

/**
 This reverb consists of a single allpass filter with a flat frequency response.
 
 This filter reiterates the input with an echo density determined by loop time. The attenuation rate is independent and is determined by the reverberation time (defined as the time in seconds for a signal to decay to 1/1000, or 60dB down from its original amplitude). Output immediately follows input in time.
 */

@interface OCSReverbAllpass : OCSAudio

///@name Initialization

///@param input The input to the alpass reverb.
///@param reverberationTime The time in seconds for a signal to decay to 1/1000, or 60dB down from its original amplitude
///@param loopTime The loop time in seconds, which determines the “echo density” of the reverberation. This in turn characterizes the “color” of the filter whose frequency response curve will contain ilpt * sr/2 peaks spaced evenly between 0 and sr/2 (the Nyquist frequency). Loop time can be as large as available memory will permit. The space required for an n second loop is 4n*sr bytes.
-(id)initWithInput:(OCSAudio *)input
 reverberationTime:(OCSControl *)reverberationTime
          loopTime:(OCSConstant *)loopTime;

///@param input The input to the alpass reverb.
///@param reverberationTime The time in seconds for a signal to decay to 1/1000, or 60dB down from its original amplitude
///@param loopTime The loop time in seconds, which determines the “echo density” of the reverberation. This in turn characterizes the “color” of the filter whose frequency response curve will contain ilpt * sr/2 peaks spaced evenly between 0 and sr/2 (the Nyquist frequency). Loop time can be as large as available memory will permit. The space required for an n second loop is 4n*sr bytes.
///@param initialDelayTime The initial disposition of internal data space. Since reverberation incorporates a feedback loop of previous output, the initial status of the storage space used is significant. A zero value will clear the space; a non-zero value will allow previous information to remain. The default value is 0.
///@param delayAmount The number of samples to delay by.
-(id)initWithInput:(OCSAudio *)input
 reverberationTime:(OCSControl *)reverberationTime
          loopTime:(OCSConstant *)loopTime
  initialDelayTime:(OCSConstant *)initialDelayTime
       delayAmount:(OCSConstant *)delayAmount;

@end
