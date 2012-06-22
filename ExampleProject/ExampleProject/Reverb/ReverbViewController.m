//
//  ReverbViewController.m
//  ExampleProject
//
//  Created by Aurelius Prochazka on 6/9/12.
//  Copyright (c) 2012 Hear For Yourself. All rights reserved.
//

#import "ReverbViewController.h"

@implementation ReverbViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    myOrchestra = [[OCSOrchestra alloc] init];
    toneGenerator = [[ToneGenerator alloc] initWithOrchestra:myOrchestra];
    fx = [[EffectsProcessor alloc] initWithOrchestra:myOrchestra 
                                       ToneGenerator:toneGenerator];
    [[OCSManager sharedOCSManager] runOrchestra:myOrchestra];
}

- (IBAction)hit1:(id)sender {
    [toneGenerator playNoteForDuration:1 Frequency:440];
}

- (IBAction)hit2:(id)sender {
    [toneGenerator playNoteForDuration:1 Frequency:(arc4random()%200+400)];
}

- (IBAction)startFX:(id)sender {
    [fx start];
}

@end
