//
//  AudioFilePlayer.h
//  AudioKit Example
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "AKFoundation.h"

@interface AudioFilePlayer : AKInstrument
@end


@interface AudioFilePlayerNote : AKNote

#define kSpeedInit 1.0
#define kSpeedMin  0.5
#define kSpeedMax  2.0
@property (nonatomic, strong) AKNoteProperty *speed;
- (instancetype)initWithSpeed:(float)speed;

@end
