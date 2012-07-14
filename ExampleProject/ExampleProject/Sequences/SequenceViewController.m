//
//  SequenceViewController.m
//  Objective-Csound
//
//  Created by Aurelius Prochazka on 7/12/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "SequenceViewController.h"

#import "Helper.h"
#import "OCSManager.h"
#import "FMGameObject.h"
#import "SoundGenerator.h"
#import "OCSSequence.h"

@interface SequenceViewController () {
    SoundGenerator  *soundGenerator;
    FMGameObject *fmGameObject;
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
    soundGenerator =  [[SoundGenerator alloc] init];
    fmGameObject = [[FMGameObject alloc] init];
    [orchestra addInstrument:soundGenerator];
    [orchestra addInstrument:fmGameObject];
    [[OCSManager sharedOCSManager] runOrchestra:orchestra];
    
}

- (IBAction)playSequenceAsProperties:(id)sender 
{
    float duration  = [Helper scaleValueFromSlider:durationSlider minimum:0.1 maximum:1.0];    
    
    sequence = [[OCSSequence alloc] initWithOrchestra:orchestra]; 
    
    OCSEvent *temp = [[OCSEvent alloc] initWithInstrument:fmGameObject duration:duration*13];
    [temp setProperty:[fmGameObject frequency] toValue:440];
    [sequence addEvent:temp];
    
    for (int i = 0; i <=12 ; i++) {
        OCSEvent *temp = [[OCSEvent alloc] init];
        [temp setProperty:[fmGameObject frequency] toValue:440*(pow(2.0f,(float)i/12))];
        [sequence addEvent:temp atTime:duration*i];
    }
    
    [sequence play];
}

- (IBAction)playSequenceAsNotes:(id)sender 
{
    float duration  = [Helper scaleValueFromSlider:durationSlider minimum:0.1 maximum:1.0];

    sequence = [[OCSSequence alloc] initWithOrchestra:orchestra]; 
    for (int i = 0; i <=12 ; i++) {
        OCSEvent *temp = [[OCSEvent alloc] initWithInstrument:soundGenerator duration:duration];
        [temp setProperty:[soundGenerator frequency] toValue:440*(pow(2.0f,(float)i/12))];
        [sequence addEvent:temp];
    }
    
    [sequence play];
}

- (IBAction)moveDurationSlider:(id)sender 
{
    float duration  = [Helper scaleValueFromSlider:durationSlider minimum:0.1 maximum:1.0];
    [durationValue setText:[NSString stringWithFormat:@"%g", duration]];
}


- (void)viewDidUnload {
    durationValue = nil;
    [super viewDidUnload];
}
@end
