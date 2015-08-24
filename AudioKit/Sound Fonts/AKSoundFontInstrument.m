//
//  AKSoundFontInstrument.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/29/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKSoundFontInstrument.h"
#import "AKSoundFont.h"

@implementation AKSoundFontInstrument

- (instancetype)initWithName:(NSString *)name
                      number:(NSUInteger)number
                   soundFont:(AKSoundFont *)soundFont
{
    self = [super init];
    if (self) {
        _name = name;
        _number = number;
        _soundFont = soundFont;
    }
    return self;
}

@end
