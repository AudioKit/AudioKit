//
//  SequenceViewController.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "SequenceViewController.h"

#import "OCSiOSTools.h"
#import "OCSFoundation.h"
#import "SeqInstrument.h"

@interface SequenceViewController () {
    SeqInstrument *instrument;
    OCSSequence *sequence;
    OCSOrchestra *orchestra;
    NSTimer *timer;
}

@end

@implementation SequenceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    orchestra = [[OCSOrchestra alloc] init];    
    instrument = [[SeqInstrument alloc] init];
    [orchestra addInstrument:instrument];
    [[OCSManager sharedOCSManager] runOrchestra:orchestra];
    
}

- (float)getDuration {
    return [OCSiOSTools scaleValueFromSlider:durationSlider minimum:0.05 maximum:0.2];
}

- (IBAction)playSequenceOfNotes:(id)sender 
{
    float duration = [self getDuration];
    
    sequence = [[OCSSequence alloc] init];
    
    for (int i = 0; i <= 12 ; i++) {
        
        // Create the note (not to be played yet)
        SeqInstrumentNote *note = [[SeqInstrumentNote alloc] init];
        // Create event to update the note
        OCSEvent *updateNote = [[OCSEvent alloc] initWithBlock:^{
            note.frequency.value = 440*(pow(2.0f,(float)i/12));
            [instrument playNote:note];
        }];
        
        [sequence addEvent:updateNote atTime:duration*i];
        
        OCSEvent *stopNote = [[OCSEvent alloc] initWithBlock:^{[note stop];}];
        [sequence addEvent:stopNote atTime:duration*(i+0.5)];
    }
    [sequence play];
}

- (IBAction)playSequenceOfNoteProperties:(id)sender
{
    float duration = [self getDuration];
    
    sequence = [[OCSSequence alloc] init];
    
    SeqInstrumentNote *note = [[SeqInstrumentNote alloc] initWithFrequency:440];
    
    for (int i = 0; i <=12 ; i++) {
        OCSEvent *update= [[OCSEvent alloc] initWithBlock:^{
            note.frequency.value = 440*(pow(2.0f,(float)i/12));
        }];
        [sequence addEvent:update atTime:duration*i];
    }

    OCSEvent *stopNote = [[OCSEvent alloc] initWithBlock:^{[note stop];}];
    [sequence addEvent:stopNote atTime:duration*(13)];
    
    [instrument playNote:note];
    [sequence play];
}


 
- (IBAction)playSequenceOfInstrumentProperties:(id)sender 
{
    float duration = [self getDuration];
    
    sequence = [[OCSSequence alloc] init];
    
    SeqInstrumentNote *note = [[SeqInstrumentNote alloc] initWithFrequency:440];
    
    OCSEvent *noteOn = [[OCSEvent alloc] initWithNote:note];
    [sequence addEvent:noteOn];
    
    for (int i = 0; i <=12 ; i++) {
        OCSEvent *update= [[OCSEvent alloc] initWithBlock:^{
            instrument.modulation.value = pow(2.0f,(float)i/12);
        }];
        [sequence addEvent:update atTime:duration*i];
    }
    
    for (int i = 0; i <=12 ; i++) {
        OCSEvent *update= [[OCSEvent alloc] initWithBlock:^{
            instrument.modulation.value = 3.0 - pow(2.0f,(float)i/12);
        }];
        [sequence addEvent:update atTime:duration*(i+13)];
    }
    
    OCSEvent *stopNote = [[OCSEvent alloc] initWithBlock:^{[note stop];}];
    [sequence addEvent:stopNote atTime:duration*(13)];
    
    [instrument playNote:note];
    [sequence play];
}

- (IBAction)moveDurationSlider:(id)sender 
{
    float duration  = [OCSiOSTools scaleValueFromSlider:durationSlider minimum:0.05 maximum:0.2];
    [durationValue setText:[NSString stringWithFormat:@"%g", duration]];
}


- (void)viewDidUnload {
    durationValue = nil;
    [super viewDidUnload];
}
@end
