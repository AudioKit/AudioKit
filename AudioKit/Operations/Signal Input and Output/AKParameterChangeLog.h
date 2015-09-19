//
//  AKParameterChangeLog.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 8/26/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//


#import "AKParameter+Operation.h"

/** Prints the given parameter to the console log
 */
NS_ASSUME_NONNULL_BEGIN
@interface AKParameterChangeLog : AKParameter

/// Prints the message followed by the parameter value every time it changes
/// @param message      Text to print out before the parameter's value
/// @param parameter    Parameter to print
- (instancetype)initWithMessage:(NSString *)message
                      parameter:(AKParameter *)parameter;
@end
NS_ASSUME_NONNULL_END

