//
//  OCSMaxControl.h
//  Objective-C Sound
//
//  Auto-generated from database on 12/22/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSControl.h"
#import "OCSParameter+Operation.h"

/** Produces a signal that is the maximum of any number of input signals.
 
 Takes any number of control signals and outputs a control that is the maximum of all of the inputs.
 */

@interface OCSMaxControl : OCSControl

/// Finds the maximum audio signal from an array of sources
/// @param inputConrols Array of controls
- (id)initWithControls:(OCSArray *)inputControls;

@end