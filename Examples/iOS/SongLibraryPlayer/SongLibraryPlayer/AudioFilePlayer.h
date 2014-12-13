//
//  AudioFilePlayer.h
//  Song Library Player Example
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "AKFoundation.h"

@interface AudioFilePlayer : AKInstrument
@property (nonatomic, strong) AKInstrumentProperty *reverbAmount;
@property (nonatomic, strong) AKInstrumentProperty *mix;
@end
