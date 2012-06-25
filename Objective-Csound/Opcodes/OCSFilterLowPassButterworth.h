//
//  OCSFilterLowPassButter.h
//  ExampleProject
//
//  Created by Adam Boulanger on 6/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOpcode.h"

@interface OCSFilterLowPassButterworth : OCSOpcode {
    OCSParam *output;
    OCSParam *input;
    OCSParamControl *cutoff;
    
    BOOL isInitSkipped;
}
@property (nonatomic, retain) OCSParam *output;

/// Initialization Statement
-(id)initWithInput:(OCSParam *)i Cutoff:(OCSParamControl *)freq;

/// Initialization Statement
-(id)initWithInput:(OCSParam *)i Cutoff:(OCSParamControl *)freq SkipInit:(BOOL)isSkipped;

@end
