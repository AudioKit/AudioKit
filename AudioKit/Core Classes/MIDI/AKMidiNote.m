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
        
        _frequency = [[AKNoteProperty alloc] init];
        [self addProperty:_frequency];
        
        _velocity = [[AKNoteProperty alloc] init];
        [self addProperty:_velocity];
   
        _modulation = [[AKControl alloc] init];
        [_modulation setParameterString:@"kMidiModulation"];
        
        _pitchBend = [[AKControl alloc] init];
        [_pitchBend setParameterString:@"kMidiPitchBend"];
        
        _aftertouch = [[AKControl alloc] init];
        [_aftertouch setParameterString:@"kMidiAftertouch"];
    }
    return self;
}
@end
