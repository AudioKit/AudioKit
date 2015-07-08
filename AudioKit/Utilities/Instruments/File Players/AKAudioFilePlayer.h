//
//  AKAudioFilePlayer.h
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKFoundation.h"

@interface AKAudioFilePlayer : AKInstrument

@property (readonly) AKAudio *output;

@property AKInstrumentProperty *speed;
@property AKInstrumentProperty *scaling;
@property AKInstrumentProperty *sampleMix;
@end

