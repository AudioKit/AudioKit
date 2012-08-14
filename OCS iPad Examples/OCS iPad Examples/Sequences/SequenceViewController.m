//
//  SequenceViewController.m
//  Objective-C Sound
//
//  Created by Aurelius Prochazka on 7/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "SequenceViewController.h"

#import "Helper.h"
#import "OCSManager.h"
#import "FMOscillator.h"
#import "SimpleOscillator.h"
#import "OCSSequence.h"

@interface SequenceViewController () {
    FMOscillator *fmOscillator;
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
    fmOscillator = [[FMOscillator alloc] init];
    [orchestra addInstrument:fmOscillator];
    [[OCSManager sharedOCSManager] runOrchestra:orchestra];
    
}

- (IBAction)playSequenceOfNotes:(id)sender 
{
    float duration  = [Helper scaleValueFromSlider:durationSlider minimum:0.05 maximum:0.2];
    
    sequence = [[OCSSequence alloc] init]; 
    for (int i = 0; i <=12 ; i++) {
        OCSEvent *temp = [[OCSEvent alloc] initWithInstrument:fmOscillator];
        [temp setNoteProperty:[fmOscillator frequency] toValue:440*(pow(2.0f,(float)i/12))];
        [sequence addEvent:temp atTime:duration*i];
        OCSEvent *temp2 = [[OCSEvent alloc] initDeactivation:temp afterDuration:duration*0.5];
        [sequence addEvent:temp2 atTime:duration*i];
    }
    
    [sequence play];
}

- (IBAction)playSequenceOfNoteProperties:(id)sender 
{
    float duration  = [Helper scaleValueFromSlider:durationSlider minimum:0.05 maximum:0.2];    
    
    sequence = [[OCSSequence alloc] init];     
    OCSEvent *noteOn = [[OCSEvent alloc] initWithInstrument:fmOscillator];
    [noteOn setNoteProperty:[fmOscillator frequency] toValue:440];
    [sequence addEvent:noteOn];
    
    for (int i = 0; i <=12 ; i++) {
        OCSEvent *update= [[OCSEvent alloc] initWithEvent:noteOn];
        [update setNoteProperty:[fmOscillator frequency] toValue:440*(pow(2.0f,(float)i/12))];
        [sequence addEvent:update atTime:duration*i];
    }
    OCSEvent *noteOff = [[OCSEvent alloc] initDeactivation:noteOn afterDuration:0];
    [sequence addEvent:noteOff atTime:duration*(13)];
    
    [sequence play];
}


- (IBAction)playSequenceOfInstrumentProperties:(id)sender 
{
    float duration  = [Helper scaleValueFromSlider:durationSlider minimum:0.05 maximum:0.2];    
    
    sequence = [[OCSSequence alloc] init];     
    OCSEvent *noteOn = [[OCSEvent alloc] initWithInstrument:fmOscillator];
    [noteOn setNoteProperty:[fmOscillator frequency] toValue:440];
    [sequence addEvent:noteOn];
    
    for (int i = 0; i <=12 ; i++) {
        OCSEvent *update= [[OCSEvent alloc] initWithInstrumentProperty:[fmOscillator modulation] value:(pow(2.0f,(float)i/12))];
        [sequence addEvent:update atTime:duration*i];
    }
    
    for (int i = 0; i <=12 ; i++) {
        OCSEvent *update= [[OCSEvent alloc] initWithInstrumentProperty:[fmOscillator modulation] value:3.0-(pow(2.0f,(float)i/12))];
        [sequence addEvent:update atTime:duration*(i+13)];
    }
    OCSEvent *noteOff = [[OCSEvent alloc] initDeactivation:noteOn afterDuration:0];
    [sequence addEvent:noteOff atTime:duration*(13)];
    
    [sequence play];
}



- (IBAction)moveDurationSlider:(id)sender 
{
    float duration  = [Helper scaleValueFromSlider:durationSlider minimum:0.05 maximum:0.2];
    [durationValue setText:[NSString stringWithFormat:@"%g", duration]];
}


- (void)viewDidUnload {
    durationValue = nil;
    [super viewDidUnload];
}
@end
