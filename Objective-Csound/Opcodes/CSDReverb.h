//
//  CSDReverb.h
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "CSDOpcode.h"
#import "CSDParamControl.h"

//aoutL, aoutR reverbsc ainL, ainR, kfblvl, kfco[, israte[, ipitchm[, iskip]]] 
//aL, aR  reverbsc a1, a2, 0.85, 12000, sr, 0.5, 1

@interface CSDReverb : CSDOpcode {
    CSDParam * outputLeft;
    CSDParam * outputRight;
    CSDParam * inputLeft;
    CSDParam * inputRight;
    CSDParamControl * feedbackLevel;
    CSDParamControl * cutoffFrequency;
}

@property (nonatomic, strong) CSDParam * outputLeft;
@property (nonatomic, strong) CSDParam * outputRight;

-(NSString *) convertToCsd;

-(id) initWithInputLeft:(CSDParam *) inLeft
             InputRight:(CSDParam *) inRight
          FeedbackLevel:(CSDParamControl *) feedback
        CutoffFrequency:(CSDParamControl *) cutoff;

@end
