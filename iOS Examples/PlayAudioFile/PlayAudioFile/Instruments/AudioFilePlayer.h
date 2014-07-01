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

@property (nonatomic, strong) AKNoteProperty *speed;
- (instancetype)initWithSpeed:(float)speed;

@end
