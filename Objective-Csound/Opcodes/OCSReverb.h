//
//  OCSReverb.h
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

/** 8 delay line stereo FDN reverb, with feedback matrix based upon physical 
 modeling scattering junction of 8 lossless waveguides of equal characteristic impedance.
 */

//aoutL, aoutR reverbsc ainL, ainR, kfblvl, kfco[, israte[, ipitchm[, iskip]]] 
//aL, aR  reverbsc a1, a2, 0.85, 12000, sr, 0.5, 1

@interface OCSReverb : OCSOpcode 

@property (nonatomic, strong) OCSParam *outputLeft;
@property (nonatomic, strong) OCSParam *outputRight;

/// Initialization Statement
- (id)initWithMonoInput:(OCSParam *) in
          FeedbackLevel:(OCSParamControl *) feedback
        CutoffFrequency:(OCSParamControl *) cutoff;

/// Initialization Statement
- (id)initWithInputLeft:(OCSParam *) inLeft
             InputRight:(OCSParam *) inRight
          FeedbackLevel:(OCSParamControl *) feedback
        CutoffFrequency:(OCSParamControl *) cutoff;

@end
