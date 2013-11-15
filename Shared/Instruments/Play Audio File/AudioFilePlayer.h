//
//  AudioFilePlayer.h
//  Objective-C Sound Example
//
//  Created by Aurelius Prochazka on 6/16/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "OCSFoundation.h"

@interface AudioFilePlayer : OCSInstrument
@end


@interface AudioFilePlayerNote : OCSNote

#define kSpeedInit 1.0
#define kSpeedMin  0.5
#define kSpeedMax  2.0
@property (nonatomic, strong) OCSNoteProperty *speed;
- (instancetype)initWithSpeed:(float)speed;

@end
