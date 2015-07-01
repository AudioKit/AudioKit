//
//  AKSoundFontPreset.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 6/29/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKSoundFontPreset.h"

@implementation AKSoundFontPreset

static int currentID = 1;

+ (void)resetID {
    @synchronized(self) {
        currentID = 1;
    }
}

- (instancetype)initWithName:(NSString *)name
                      number:(NSUInteger)number
                     program:(NSUInteger)program
                        bank:(NSUInteger)bank
                   soundFont:(AKSoundFont *)soundFont
{
    self = [super init];
    if (self) {
        @synchronized([self class]) {
            currentID++;
        }
        
        _name = name;
        _number = number;
        _program = program;
        _bank = bank;
        _soundFont = soundFont;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"giSoundFontPreset%d", currentID];
}

- (NSString *)orchestraString
{
    return [NSString stringWithFormat:@"giSoundFontPreset%d sfpreset %lu, %lu, %@, %lu", currentID, (unsigned long)_program, (unsigned long)_bank, _soundFont, (unsigned long)_number];
}


@end
