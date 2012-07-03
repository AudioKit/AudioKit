//
//  ReverbViewController.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ReverbViewController.h"
#import "Helper.h"
#import "OCSManager.h"
#import "ToneGenerator.h"
#import "EffectsProcessor.h"

@interface ReverbViewController () {
    EffectsProcessor *fx;
    ToneGenerator *toneGenerator;
}
@end

@implementation ReverbViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    OCSOrchestra *orch = [[OCSOrchestra alloc] init];

    toneGenerator = [[ToneGenerator alloc] init];
    fx = [[EffectsProcessor alloc] initWithToneGenerator:toneGenerator];
    
    [orch addInstrument:toneGenerator];
    [orch addInstrument:fx];

    [[OCSManager sharedOCSManager] runOrchestra:orch];
}

- (IBAction)hit1:(id)sender {
    [toneGenerator playNoteForDuration:1 Frequency:440];
}

- (IBAction)hit2:(id)sender {
    
    float randomFrequency = [Helper randomFloatFrom:kFrequencyMin to:kFrequencyMax];
    [toneGenerator playNoteForDuration:1 Frequency:randomFrequency];
}

- (IBAction)startFX:(id)sender {
    [fx start];
}

@end
