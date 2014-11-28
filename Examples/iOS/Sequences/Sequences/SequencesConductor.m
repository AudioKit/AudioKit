//
//  SequencesConductor.m
//  Sequences
//
//  Created by Aurelius Prochazka on 8/4/14.
//  Copyright (c) 2014 h4y. All rights reserved.
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
        [AKOrchestra start];
    }
    return self;
}

- (void)playSequenceOfNotesOfDuration:(float)duration
{
    sequence = [[AKSequence alloc] init];
    
    for (int i = 0; i <= 12 ; i++) {
        
        // Create the note (not to be played yet)
        SeqInstrumentNote *note = [[SeqInstrumentNote alloc] init];
        // Create event to update the note
        AKEvent *updateNote = [[AKEvent alloc] initWithBlock:^{
            note.frequency.value = 440*(pow(2.0f,(float)i/12));
            [instrument playNote:note];
        }];
        
        [sequence addEvent:updateNote atTime:duration*i];
        
        AKEvent *stopNote = [[AKEvent alloc] initWithBlock:^{[note stop];}];
        [sequence addEvent:stopNote atTime:duration*(i+0.5)];
    }
    [sequence play];
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
    
    AKEvent *noteOn = [[AKEvent alloc] initWithNote:note];
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
        [sequence addEvent:update atTime:duration*(i+13)];
    }
    
    AKEvent *stopNote = [[AKEvent alloc] initWithBlock:^{[note stop];}];
    [sequence addEvent:stopNote atTime:duration*(13)];
    
    [instrument playNote:note];
    [sequence play];
}


@end
