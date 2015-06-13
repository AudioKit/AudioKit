//
//  AKSoundFontPlayer.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/12/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKSoundFontPlayer.h"

@implementation AKSoundFontPlayer
{
    AKSoundFont * _soundFont;
}

- (instancetype)initWithSoundFont:(AKSoundFont *)soundFont
{
    self = [super initWithString:[self operationName]];
    if (self) {
        [self setUpConnections];
    }
    return self;
}

- (void)setUpConnections
{
    self.state = @"connectable";
    self.dependencies = @[];
}

@end
