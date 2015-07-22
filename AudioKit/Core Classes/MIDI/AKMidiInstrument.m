//
//  AKMidiInstrument.m
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/21/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKMidiInstrument.h"

#import "AKFoundation.h"

#import "AKMidiInput.h"

@implementation AKMidiInstrument

- (instancetype)init
{
    self = [super init];
    if (self) {
        _note = [[AKMidiNote alloc] init];
        [self addNoteProperty:_note.notenumber];
        [self addNoteProperty:_note.velocity];
        
        AKMidiInput *midiInput = [[AKMidiInput alloc] initWithNoteNumber:_note.notenumber
                                                                Velocity:_note.velocity];
        [self connect:midiInput];

        
    }
    return self;
}
@end
