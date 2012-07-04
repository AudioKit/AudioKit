//
//  OCSHeader.h
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 7/3/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OCSHeader : NSObject

/// Determines the value from which to scale all other amplitudes in Csound
@property (nonatomic, assign) float zeroDBFullScaleValue;

@end
