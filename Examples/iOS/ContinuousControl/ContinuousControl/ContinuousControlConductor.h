//
//  ContinuousControlConductor.h
//  ContinuousControl
//
//  Created by Aurelius Prochazka on 8/4/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TweakableInstrument.h"

@interface ContinuousControlConductor : NSObject
@property (nonatomic, strong) TweakableInstrument *tweakableInstrument;

- (void)start;
- (void)stop;

@end
