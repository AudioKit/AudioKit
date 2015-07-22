//
//  AKMidiNote.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/21/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKMidiNote.h"

@implementation AKMidiNote

- (instancetype)init
{
    self = [super init];
    if (self) {
        _notenumber = [[AKNoteProperty alloc] init];
        [self addProperty:_notenumber];
        
        _velocity = [[AKNoteProperty alloc] init];
        [self addProperty:_velocity];
    }
    return self;
}
@end
