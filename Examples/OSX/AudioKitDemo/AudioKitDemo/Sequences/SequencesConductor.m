//
//  SequencesConductor.m
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 2/14/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "SequencesConductor.h"
#import "AKFoundation.h"
#import "SeqInstrument.h"

@implementation SequencesConductor
{
    SeqInstrument *instrument;
    AKSequence *sequence;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        instrument = [[SeqInstrument alloc] init];
        [AKOrchestra addInstrument:instrument];
    }
    return self;
}

- (void)playPhraseOfNotesOfDuration:(float)duration
{
    AKPhrase *phrase = [[AKPhrase alloc] init];
    for (int i = 0; i <= 12 ; i++) {
        SeqInstrumentNote *note = [[SeqInstrumentNote alloc] init];
        note.frequency.value = 440*(pow(2.0f,(float)i/12));
        note.duration.value = duration;
        [phrase addNote:note atTime:i*duration];
    }
    [instrument playPhrase:phrase];
}

- (void)playSequenceOfNotePropertiesOfDuration:(float)duration
{
    sequence = [[AKSequence alloc] init];
    
    SeqInstrumentNote *note = [[SeqInstrumentNote alloc] initWithFrequency:440];
    
    for (int i = 0; i <=12 ; i++) {
        AKEvent *update= [[AKEvent alloc] initWithBlock:^{
            note.frequency.value = 440*(pow(2.0f,(float)i/12));
        }];
        [sequence addEvent:update atTime:duration*i];
    }
    
    AKEvent *stopNote = [[AKEvent alloc] initWithBlock:^{[note stop];}];
    [sequence addEvent:stopNote atTime:duration*(13)];
    
    [instrument playNote:note];
    [sequence play];
}



- (void)playSequenceOfInstrumentPropertiesOfDuration:(float)duration
{
    sequence = [[AKSequence alloc] init];
    
    SeqInstrumentNote *note = [[SeqInstrumentNote alloc] initWithFrequency:440];
    
    AKEvent *noteOn = [[AKEvent alloc] initWithBlock:^{
        [instrument playNote:note];
    }];
    
    [sequence addEvent:noteOn];
    
    for (int i = 0; i <=12 ; i++) {
        AKEvent *update= [[AKEvent alloc] initWithBlock:^{
            instrument.modulation.value = pow(2.0f,(float)i/12);
        }];
        [sequence addEvent:update atTime:duration*i];
    }
    
    for (int i = 0; i <=12 ; i++) {
        AKEvent *update= [[AKEvent alloc] initWithBlock:^{
            instrument.modulation.value = 3.0 - pow(2.0f,(float)i/12);
        }];
        [sequence addEvent:update atTime:duration*(i+12)];
    }
    
    AKEvent *stopNote = [[AKEvent alloc] initWithBlock:^{[note stop];}];
    [sequence addEvent:stopNote atTime:duration*(25)];
    
    [instrument playNote:note];
    [sequence play];
}


@end