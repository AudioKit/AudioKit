//
//  AKMinControl.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 12/22/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKControl.h"
#import "AKParameter+Operation.h"

/** Produces a signal that is the minimum of any number of input signals.
 
 Takes any number of control signals and outputs a control that is the minimum of all of the inputs.
 */

@interface AKMinControl : AKControl

/// Finds the minimum audio signal from an array of sources
/// @param inputControls Array of controls
- (instancetype)initWithControls:(AKArray *)inputControls;

@end