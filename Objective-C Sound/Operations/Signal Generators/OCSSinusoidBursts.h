//
//  OCSSinusoidBursts.h
//  OCS iPad Examples
//
//  Created by Aurelius Prochazka on 10/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSOperation.h"

#import "OCSSineTable.h"

/**
 Produces sinusoid bursts useful for formant and granular synthesis.
 */

@interface OCSSinusoidBursts : OCSOperation

-(id) initWithOverlaps:(OCSConstant *)numberOfOverlaps
             sineTable:(OCSSineTable *)sineburstSynthesisTable


@end
