//
//  OCSTrackedPitchSchouten.h
//  SocialMedia Sounds
//
//  Created by Adam Boulanger on 9/18/13.
//  Copyright (c) 2013 Adam Boulanger. All rights reserved.
//

#import "OCSParameter+Operation.h"
#import "OCSControl.h"
#import "OCSFSignal.h"

/**
 Track the pitch and amplitude of a PVS signal as k-rate variables.
 
 The pitch detection algorithm implemented by pvspitch is based upon J. F. Schouten's hypothesis of the neural processes of the brain used to determine the pitch of a sound after the frequency analysis of the basilar membrane. Except for some further considerations, pvspitch essentially seeks out the highest common factor of an incoming sound's spectral peaks to find the pitch that may be attributed to it.
 
 */

@interface OCSTrackedPitchSchouten : OCSControl

/// Initialize the tracked frequency.
/// @param input Input mono F-Signal.
/// @param amplitude amplitude threshold (0-1). Higher values will eliminate low-amplitude spectral components from being included in the analysis.
-(id)initWithFSignalSource:(OCSFSignal *)fSignalSource
  amplitudeThreshold:(OCSControl *)amplitude;

@end
