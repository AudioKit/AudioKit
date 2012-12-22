//
//  OCSMinControl.h
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 12/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSControl.h"
#import "OCSParameter+Operation.h"

/** Produces a signal that is the minimum of any number of input signals.
 
 Takes any number of control signals and outputs a control that is the minimum of all of the inputs.
 */

@interface OCSMinControl : OCSControl

/// Finds the minimum audio signal from an array of sources
/// @param inputConrols Array of controls
- (id)initWithControls:(OCSArray *)inputControls;

@end