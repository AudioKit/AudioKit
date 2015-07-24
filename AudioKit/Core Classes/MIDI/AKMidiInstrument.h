//
//  AKMidiInstrument.h
//  AudioKit
//
//  Created by Aurelius Prochazka on 7/21/15.
//  Copyright (c) 2015 AudioKit. All rights reserved.
//

#import "AKInstrument.h"
#import "AKMidiNote.h"

@interface AKMidiInstrument : AKInstrument

@property int midiChannel;
@property AKMidiNote *note;

- (void)startListeningOnAllMidiChannels;
- (void)startListeningOnMidiChannel:(int)channelNumber;

@end
