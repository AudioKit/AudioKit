//
//  SequencesViewController.m
//  AudioKitDemo
//
//  Created by Aurelius Prochazka on 2/14/15.
//  Copyright (c) 2015 Aurelius Prochazka. All rights reserved.
//

#import "SequencesViewController.h"
#import "SequencesConductor.h"
#import "AKTools.h"

@implementation SequencesViewController
{
    IBOutlet NSTextField *durationValue;
    IBOutlet NSSlider *durationSlider;
    
    SequencesConductor *conductor;
}


- (void)viewDidAppear {
    conductor = [[SequencesConductor alloc] init];
}

- (void)viewDidDisappear {
    [[AKManager sharedManager] stop];
    [AKOrchestra reset];
}


- (float)getDuration {
    return [AKTools scaleValueFromSlider:durationSlider minimum:0.05 maximum:0.2];
}

- (IBAction)playPhrase:(id)sender
{
    [conductor playPhraseOfNotesOfDuration:[self getDuration]];
}

- (IBAction)playSequenceOfNoteProperties:(id)sender
{
    [conductor playSequenceOfNotePropertiesOfDuration:[self getDuration]];
}

- (IBAction)playSequenceOfInstrumentProperties:(id)sender
{
    [conductor playSequenceOfInstrumentPropertiesOfDuration:[self getDuration]];
}

- (IBAction)moveDurationSlider:(id)sender
{
    float duration  = [AKTools scaleValueFromSlider:durationSlider minimum:0.05 maximum:0.2];
    [durationValue setStringValue:[NSString stringWithFormat:@"%g", duration]];
}

@end
