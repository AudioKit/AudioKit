//
//  AKAssignment.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKParameter+Operation.h"

/// Simply a wrapper for the equal sign
@interface AKAssignment : AKParameter

/// Initialization Statement with both sides
/// @param output The left side of the equal sign.
/// @param input  The right side of the equal sign.
- (instancetype)initWithOutput:(AKParameter *)output
                         input:(AKParameter *)input;

/// Initialization Statement
/// @param input The right side of the equal sign.
- (instancetype)initWithInput:(AKParameter *)input;


@end

