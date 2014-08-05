//
//  ViewController.m
//  Sequences
//
//  Created by Aurelius Prochazka on 6/30/14.
//  Copyright (c) 2014 Hear For Yourself. All rights reserved.
//

#import "ViewController.h"
#import "SequencesConductor.h"
#import "AKiOSTools.h"

@interface ViewController ()
{
    IBOutlet UITextField *durationValue;
    IBOutlet UISlider *durationSlider;
    
    SequencesConductor *conductor;
}
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    conductor = [[SequencesConductor alloc] init];
    
}

- (float)getDuration {
    return [AKiOSTools scaleValueFromSlider:durationSlider minimum:0.05 maximum:0.2];
}

- (IBAction)playSequenceOfNotes:(id)sender {
    [conductor playSequenceOfNotesOfDuration:[self getDuration]];
}
- (IBAction)playSequenceOfNoteProperties:(id)sender {
    [conductor playSequenceOfNotePropertiesOfDuration:[self getDuration]];
}
- (IBAction)playSequenceOfInstrumentProperties:(id)sender {
    [conductor playSequenceOfInstrumentPropertiesOfDuration:[self getDuration]];
}

- (IBAction)moveDurationSlider:(id)sender
{
    float duration  = [AKiOSTools scaleValueFromSlider:durationSlider minimum:0.05 maximum:0.2];
    [durationValue setText:[NSString stringWithFormat:@"%g", duration]];
}


@end
