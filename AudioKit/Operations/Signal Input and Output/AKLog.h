//
//  AKLog.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 2/26/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "AKParameter+Operation.h"

/** Prints the given parameter to the console log
 */
NS_ASSUME_NONNULL_BEGIN
@interface AKLog : AKParameter

/// Prints the message followed by the parameter value every timeInterval seconds
/// @param message      Text to print out before the parameter's value
/// @param parameter    Parameter to print
/// @param timeInterval How often to print, in seconds.
- (instancetype)initWithMessage:(NSString *)message
                      parameter:(AKParameter *)parameter
                   timeInterval:(NSTimeInterval)timeInterval;
@end
NS_ASSUME_NONNULL_END

