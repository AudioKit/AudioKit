//
//  UDOCompressor.h
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//
// This is the compressor from Boulanger Labs' csGrain

#import "OCSOpcode.h"

@interface UDOCompressor : OCSOpcode {
    OCSParam *outputLeft;
    OCSParam *outputRight;
    OCSParam *inputLeft;
    OCSParam *inputRight;
    OCSParamControl *threshold;
    OCSParamControl *ratio;
    OCSParamControl *attack;
    OCSParamControl *release;
}

@property (nonatomic, strong) OCSParam *outputLeft;
@property (nonatomic, strong) OCSParam *outputRight;

- (id)initWithInputLeft:(OCSParam *) inLeft
             InputRight:(OCSParam *) inRight
              Threshold:(OCSParamControl *) thr
                  Ratio:(OCSParamControl *) rat 
                 Attack:(OCSParamControl *)atk
                Release:(OCSParamControl *)rel;
@end
