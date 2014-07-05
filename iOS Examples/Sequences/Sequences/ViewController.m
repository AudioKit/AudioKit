//
//  ViewController.m
//  Sequences
//
//  Created by Aurelius Prochazka on 6/30/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "ViewController.h"

#import "AKiOSTools.h"
#import "AKFoundation.h"
#import "SeqInstrument.h"

@interface ViewController ()
{
    IBOutlet UITextField *durationValue;
    IBOutlet UISlider *durationSlider;
    
    SeqInstrument *instrument;
    AKSequence *sequence;
    AKOrchestra *orchestra;
    NSTimer *timer;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    orchestra = [[AKOrchestra alloc] init];
    instrument = [[SeqInstrument alloc] init];
    [orchestra addInstrument:instrument];
    [[AKManager sharedAKManager] runOrchestra:orchestra];
    
}

- (float)getDuration {
    return [AKiOSTools scaleValueFromSlider:durationSlider minimum:0.05 maximum:0.2];
}

- (IBAction)playSequenceOfNotes:(id)sender
{
    float duration = [self getDuration];
    
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

- (IBAction)playSequenceOfNoteProperties:(id)sender
{
    float duration = [self getDuration];
    
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



- (IBAction)playSequenceOfInstrumentProperties:(id)sender
{
    float duration = [self getDuration];
    
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

- (IBAction)moveDurationSlider:(id)sender
{
    float duration  = [AKiOSTools scaleValueFromSlider:durationSlider minimum:0.05 maximum:0.2];
    [durationValue setText:[NSString stringWithFormat:@"%g", duration]];
}


@end
