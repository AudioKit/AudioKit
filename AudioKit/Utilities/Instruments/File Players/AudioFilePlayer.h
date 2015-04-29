//
//  AudioFilePlayer.h
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKFoundation.h"

@interface AudioFilePlayer : AKInstrument

@property (readonly) AKAudio *auxilliaryOutput;

@property AKInstrumentProperty *speed;
@property AKInstrumentProperty *scaling;
@property AKInstrumentProperty *sampleMix;
@end

