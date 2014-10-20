//
//  AKFTableLooper.h
//  AudioKit
//
//  Auto-generated from scripts by Aurelius Prochazka on 11/4/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKAudio.h"
#import "AKParameter+Operation.h"

/** Function-table-based crossfading looper.
 
 This opcode reads audio from a function table and plays it back in a loop with user-defined start time, duration and crossfade time. It also allows the pitch of the loop to be controlled, including reversed playback. It accepts non-power-of-two tables, such as deferred-allocation GEN01 tables.
 */

@interface AKFTableLooper : AKAudio

/// Instantiates the f table looper
/// @param fTable comment
/// @param startingPosition Loop start position in seconds
/// @param loopDuration Loop duration in seconds
/// @param crossfadeDuration Crossfade duration in seconds
/// @param transpositionRatio Pitch control, negative values play the loop in reverse.
/// @param amplitude Amplitude of loop
- (instancetype)initWithFTable:(AKFTable *)fTable
              startingPosition:(AKConstant *)startingPosition
                  loopDuration:(AKConstant *)loopDuration
             crossfadeDuration:(AKConstant *)crossfadeDuration
            transpositionRatio:(AKControl *)transpositionRatio
                     amplitude:(AKControl *)amplitude;

@end