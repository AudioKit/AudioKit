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
        [self addNoteProperty:_note.frequency];
        [self addNoteProperty:_note.velocity];
        [self connect:_note.modulation];
        [self connect:_note.pitchBend];
        [self connect:_note.aftertouch];
        
        AKMidiInput *midiInput = [[AKMidiInput alloc] initWithNoteNumber:_note.notenumber
                                                               frequency:_note.frequency
                                                                velocity:_note.velocity
                                                              modulation:_note.modulation
                                                               pitchBend:_note.pitchBend
                                                              aftertouch:_note.aftertouch];
        [self connect:midiInput];

        
    }
    return self;
}

- (void)startListeningOnAllMidiChannels
{
    NSString *updateString = [NSString stringWithFormat:@"massign 0, %@", @(self.instrumentNumber)];
    NSLog(@"%@", updateString);
    [[[AKManager sharedManager] engine] updateOrchestra:updateString];
}

- (void)startListeningOnMidiChannel:(int)channelNumber
{
    NSString *updateString = [NSString stringWithFormat:@"massign 0,0\nmassign %d, %@", channelNumber, @(self.instrumentNumber)];
    NSLog(@"%@", updateString);
    [[[AKManager sharedManager] engine] updateOrchestra:updateString];
}
@end
