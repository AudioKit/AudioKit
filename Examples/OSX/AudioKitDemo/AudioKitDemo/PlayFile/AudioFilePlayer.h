//
//  AudioFilePlayer.h
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Aurelius Prochazka. All rights reserved.
//

#import "AKFoundation.h"

@interface AudioFilePlayer : AKInstrument
@end

// -----------------------------------------------------------------------------
#  pragma mark - Instrument Note
// -----------------------------------------------------------------------------

@interface AudioFilePlayerNote : AKNote

@property AKNoteProperty *speed;
- (instancetype)initWithSpeed:(float)speed;

@end
